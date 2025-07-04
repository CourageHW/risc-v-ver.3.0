`timescale 1ns / 1ps

import core_pkg::*;

module tb_riscv_core;

  localparam CLK_PERIOD = 10;

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
    $display("RISC-V Core Comprehensive Test 2 (Corrected) Starting...");
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
    $display("[RUN] Executing instructions from program.mem...");
    repeat (30) @(posedge clk); // Give enough cycles to reach the infinite loop

    // Check final register values based on CORRECT CPU behavior
    $display("\n=====================================================");
    $display("Verifying Register File...");
    $display("=====================================================");

    check_register_value("x5 (lui+addi)",      5'd5,  32'h10000123);
    check_register_value("x6 (andi)",          5'd6,  32'h00000123);
    check_register_value("x7 (ori)",           5'd7,  32'h00000F23); // Corrected expected value
    check_register_value("x9 (slli)",          5'd9,  32'h0000F230); // Corrected expected value
    check_register_value("x10 (srli)",         5'd10, 32'h00000F23); // Corrected expected value
    check_register_value("x11 (addi negative)",5'd11, 32'hFFFFFFFF);
    check_register_value("x13 (bne not taken)",5'd13, 32'd1);        // Should be 1
    check_register_value("x14 (blt taken, FLUSHED)", 5'd14, 32'd0);  // Should be 0
    check_register_value("x15 (blt target)",   5'd15, 32'd1);
    check_register_value("x16 (jalr return addr)", 5'd16, 32'h40);
    check_register_value("x17 (jalr, FLUSHED)",5'd17, 32'd0);
    check_register_value("x20 (auipc+addi)",   5'd20, 32'h44);
    check_register_value("x30 (unreached)",    5'd30, 32'd0);        // Should be 0


    $display("\n=====================================================");
    if (error_count == 0) begin
      $display("All Comprehensive Test 2 cases passed!");
    end else begin
      $display("Comprehensive Test 2 finished with %0d error(s).", error_count);
    end
    $display("=====================================================");
    repeat(100) @(posedge clk);
    $finish;
  end

endmodule
