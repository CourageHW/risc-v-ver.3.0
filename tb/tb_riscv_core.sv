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
    $display("RISC-V Core Load-Use Hazard Test Starting...");
    $display("=====================================================");

    // 1. Reset sequence
    rst_n = 0;
    #(CLK_PERIOD * 2); // Apply reset for 2 clock cycles
    rst_n = 1;
    $display("Reset released.");

    // Run enough cycles for all instructions to execute and write back
    $display("[RUN] Executing instructions from program.mem...");
    repeat (20) @(posedge clk); // Give enough cycles to reach the infinite loop

    // Check final register values
    $display("\n=====================================================");
    $display("Verifying Register File...");
    $display("=====================================================");

    // Expected values based on the program.mem:
    // x10 = 0x1000 (base address)
    // x11 = 50 (value to store)
    // x1 = 50 (loaded from memory)
    // x2 = 51 (x1 + 1, after stall)
    // x3 = 100 (filler)

    check_register_value("Base address x10", 5'd10, 32'h1000);
    check_register_value("Stored value x11", 5'd11, 32'd50);
    check_register_value("Loaded value x1",  5'd1,  32'd50);
    check_register_value("Result x2 (x1 + 1)", 5'd2,  32'd51);
    check_register_value("Filler x3",        5'd3,  32'd100);

    $display("\n=====================================================");
    if (error_count == 0) begin
      $display("All Load-Use Hazard tests passed!");
    end else begin
      $display("Load-Use Hazard tests finished with %0d error(s).", error_count);
    end
    $display("=====================================================");
    $finish;
  end

endmodule