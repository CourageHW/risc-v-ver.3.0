`timescale 1ns / 1ps

import core_pkg::*;

module tb_add;

  localparam CLK_PERIOD = 10;

  logic clk = 0;
  logic rst_n;

  integer error_count = 0;

  // Instantiate the core
  // instruction_memory module will automatically load 'add.mem' as it is hardcoded.
  riscv_core dut (
    .clk(clk),
    .rst_n(rst_n)
  );

  // Clock generator
  always #(CLK_PERIOD / 2) clk = ~clk;

  // Task to check register value for easier testing
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
    $display("=====================================================");
    $display("RISC-V Core Test for add.mem Starting...");
    $display("=====================================================");

    // 1. Reset sequence
    rst_n = 0;
    #(CLK_PERIOD * 2);
    rst_n = 1;
    $display("Reset released.");

    // 2. Run simulation for enough cycles for the program to complete.
    // You may need to adjust this value depending on the length of the program.
    $display("[RUN] Executing instructions from add.mem...");
    repeat (100) @(posedge clk); // Run for 100 cycles

    // 3. Verify final register values
    // =================================================================
    // IMPORTANT: You need to replace these checks with the actual
    // registers and values you expect from your 'add.mem' program.
    // =================================================================
    $display("\n=====================================================");
    $display("Verifying Register File...");
    $display("=====================================================");

    // Example check:
    // check_register_value("Result Register", 5'd10, 32'h...); // Check register x10
    // check_register_value("Status Register", 5'd11, 32'h...); // Check register x11

    // 4. Report results
    $display("\n=====================================================");
    if (error_count == 0) begin
      $display("Test for add.mem Passed!");
    end else begin
      $display("Test for add.mem FAILED with %0d error(s).", error_count);
    end
    $display("=====================================================");
    $finish;
  end

endmodule