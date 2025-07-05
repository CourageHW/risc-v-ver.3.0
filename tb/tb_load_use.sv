`timescale 1ns / 1ps

import core_pkg::*;

module tb_load_use;

  localparam CLK_PERIOD = 10;
  localparam MEM_FILE_PATH = "mem/load_use.mem";

  logic clk = 0;
  logic rst_n;

  integer error_count = 0;

  // Instantiate the core
  riscv_core dut (
    .clk(clk),
    .rst_n(rst_n)
  );

  // Clock generator
  always #(CLK_PERIOD / 2) clk = ~clk;

  // Task to check register value
  task check_register_value;
    input string test_name;
    input logic [REG_ADDR_WIDTH-1:0] reg_addr;
    input logic [DATA_WIDTH-1:0] expected_value;
    begin
      $display("[CHECK] %s: Register x%0d", test_name, reg_addr);
      assert (dut.ID_inst.reg_inst.registers[reg_addr] === expected_value) begin
        $display("    PASS: x%0d = 0x%h", reg_addr, dut.ID_inst.reg_inst.registers[reg_addr]);
      end else begin
        $error("    FAIL: x%0d mismatch. Expected 0x%h, Got 0x%h", reg_addr, expected_value, dut.ID_inst.reg_inst.registers[reg_addr]);
        error_count++;
      end
    end
  endtask

  // Main test sequence
  initial begin
    integer i;
    error_count = 0;
    $display("=====================================================");
    $display("RISC-V Core Load-Use Hazard Test Starting...");
    $display("Memory file: %s", MEM_FILE_PATH);
    $display("=====================================================");

    // 1. Reset sequence
    rst_n = 0;
    #(CLK_PERIOD * 2); // Apply reset for 2 clock cycles
    rst_n = 1;
    $display("Reset released.");

    // Initialize all registers to 0 for predictable simulation
    $display("[SETUP] Initializing all registers to 0...");
    for (i = 0; i < NUM_REGS; i = i + 1) begin
      dut.ID_inst.reg_inst.registers[i] = 32'd0;
    end

    // Run enough cycles for all instructions to execute and write back
    $display("[RUN] Executing instructions from %s...", MEM_FILE_PATH);
    repeat (20) @(posedge clk); // Give enough cycles to reach the infinite loop

    // Check final register values based on load_use.mem
    $display("\n=====================================================");
    $display("Verifying Register File...");
    $display("=====================================================");

    check_register_value("x5 (lui)",        5'd5,  32'h80000000); // lui x5, 0x80000
    check_register_value("x6 (addi)",       5'd6,  32'd123);      // addi x6, x0, 123
    check_register_value("x7 (lw)",         5'd7,  32'd123);      // lw x7, 0(x5)
    check_register_value("x8 (addi)",       5'd8,  32'd124);      // addi x8, x7, 1
    check_register_value("x9 (addi)",       5'd9,  32'd124);      // addi x9, x0, 124
    check_register_value("x30 (failure)",   5'd30, 32'd0);        // Should not be written
    check_register_value("x31 (failure)",   5'd31, 32'd0);        // Should not be written


    $display("\n=====================================================");
    if (error_count == 0) begin
      $display("All Load-Use Hazard Test cases passed!");
    end else begin
      $display("Load-Use Hazard Test finished with %0d error(s).", error_count);
    end
    $display("=====================================================");
    #1000;
    $finish;
  end

endmodule
