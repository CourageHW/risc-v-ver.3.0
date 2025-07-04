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
    $display("RISC-V Core Improved Testbench (Flush Verification) Starting...");
    $display("=====================================================");

    // 1. Reset sequence
    rst_n = 0;
    #(CLK_PERIOD * 2);
    rst_n = 1;
    $display("Reset released.");

    // Run enough cycles for all instructions to execute and write back
    // The program itself now initializes the registers.
    $display("[RUN] Executing instructions from program.mem...");
    repeat (30) @(posedge clk); // Give enough cycles to reach the infinite loop

    // Check final register values
    $display("\n=====================================================");
    $display("Verifying Register File...");
    $display("=====================================================");

    // Expected values based on the improved program.mem:
    check_register_value("Setup value x1",            5'd1, 32'd10);
    check_register_value("Setup value x2",            5'd2, 32'd10);
    check_register_value("BEQ flushed insn check x3", 5'd3, 32'd55);  // Should retain initial value, proving flush
    check_register_value("BEQ target x5",             5'd5, 32'd100);
    check_register_value("JAL link address x6",       5'd6, 32'h20); // jal pc+4 = 0x1C+4
    check_register_value("JAL flushed insn check x7", 5'd7, 32'd66);  // Should retain initial value, proving flush
    check_register_value("JAL target x8",             5'd8, 32'd200);

    $display("\n=====================================================");
    if (error_count == 0) begin
      $display("All Branch & Jump tests passed!");
    end else begin
      $display("Branch & Jump tests finished with %0d error(s).", error_count);
    end
    $display("=====================================================");
    $finish;
  end

endmodule
