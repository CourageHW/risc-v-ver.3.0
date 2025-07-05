`timescale 1ns / 1ps

import core_pkg::*;

module tb_branch_test;

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
      if (dut.ID_inst.reg_inst.registers[reg_addr] === expected_value) begin
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
    $display("RISC-V Core Branch Hazard Test Starting...");
    $display("=====================================================");

    // 1. Reset sequence
    rst_n = 0;
    #(CLK_PERIOD * 2);
    rst_n = 1;
    $display("Reset released.");

    // Initialize all registers to 0 for predictable simulation
    for (integer i = 0; i < NUM_REGS; i = i + 1) begin
      dut.ID_inst.reg_inst.registers[i] = 32'd0;
    end

    // 2. Run simulation for enough cycles
    $display("[RUN] Executing instructions from branch_test.mem...");
    repeat (15) @(posedge clk);

    // 3. Verify register values
    $display("\n=====================================================");
    $display("Verifying Register File...");
    $display("=====================================================");

    // This instruction should have been flushed and never executed.
    check_register_value("Flushed Instruction (x14)", 5'd14, 32'd0);

    // This instruction should be executed as the branch target.
    check_register_value("Branch Target (x15)", 5'd15, 32'd1);

    // 4. Report results
    $display("\n=====================================================");
    if (error_count == 0) begin
      $display("Branch Hazard Test Passed!");
    end else begin
      $display("Branch Hazard Test FAILED with %0d error(s).", error_count);
    end
    $display("=====================================================");
    $finish;
  end

endmodule
