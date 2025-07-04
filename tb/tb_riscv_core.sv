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
    error_count = 0;
    $display("=====================================================");
    $display("RISC-V Core Testbench (Forwarding Unit) Starting...");
    $display("=====================================================");

    // 1. Reset sequence
    rst_n = 0;
    #(CLK_PERIOD * 2);
    rst_n = 1;
    $display("Reset released.");

    // Initialize all registers to 0
    foreach (dut.ID_inst.reg_inst.registers[i]) begin
      dut.ID_inst.reg_inst.registers[i] = 32'h0;
    end
    $display("[SETUP] All registers initialized to 0.");

    // Run enough cycles for all instructions in program.mem to complete
    // There are 4 instructions, each taking 5 cycles to write back in a 5-stage pipeline.
    // Plus some extra cycles for safety and initial fetch.
    $display("[RUN] Executing instructions from program.mem...");
    repeat (20) @(posedge clk); // 4 instructions * 5 cycles/instruction = 20 cycles

    // Check final register values
    $display("\n=====================================================");
    $display("Verifying Register File...");
    $display("=====================================================");

    // Expected values based on program.mem:
    // 00A00093 // addi x1, x0, 10  (x1 = 10)
    // 00508113 // addi x2, x1, 5   (x2 = x1 + 5 = 10 + 5 = 15)
    // 01400193 // addi x3, x0, 20  (x3 = 20)
    // 00308233 // add x4, x1, x3   (x4 = x1 + x3 = 10 + 20 = 30)

    check_register_value("Final x1 value", 5'd1, 32'd10);
    check_register_value("Final x2 value", 5'd2, 32'd15);
    check_register_value("Final x3 value", 5'd3, 32'd20);
    check_register_value("Final x4 value", 5'd4, 32'd30);

    $display("\n=====================================================");
    if (error_count == 0) begin
      $display("All Forwarding Unit tests passed!");
    end else begin
      $display("Forwarding Unit tests finished with %0d error(s).", error_count);
    end
    $display("=====================================================");
    repeat(100) @(posedge clk);
    $finish;
  end

endmodule
