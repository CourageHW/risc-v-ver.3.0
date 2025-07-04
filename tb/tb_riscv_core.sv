`timescale 1ns / 1ps

import core_pkg::*;

module tb_riscv_core;

  localparam CLK_PERIOD = 10;

  integer scenario_errors;
  // DUT Inputs
  logic clk = 0;
  logic rst_n;
  logic pc_we_tb;
  

  // WB inputs to simulate write-back to register file
  logic wb_reg_write_tb;
  logic [REG_ADDR_WIDTH-1:0] wb_wr_addr_tb;
  logic [DATA_WIDTH-1:0] wb_wr_data_tb;

  integer error_count = 0;
  
  // Instantiate the core
  riscv_core dut (
    .clk(clk),
    .rst_n(rst_n),
    .pc_we(pc_we_tb)
  );

  // Clock generator
  always #(CLK_PERIOD / 2) clk = ~clk;

  // Connect WB stage outputs to core's WB inputs (feedback to ID stage)
  assign wb_reg_write_tb = dut.wb_stage_in_bus.data.RegWrite;
  assign wb_wr_addr_tb   = dut.wb_stage_in_bus.data.rd_addr;
  assign wb_wr_data_tb   = (dut.wb_stage_in_bus.data.WBSel == WB_MEM) ? dut.wb_stage_in_bus.data.rd_data : dut.wb_stage_in_bus.data.alu_result;

  // Task to check the flow of a single instruction through IF, ID, EX, MEM, and WB stages
  task check_instruction_flow;
    input string test_name;
    input logic [DATA_WIDTH-1:0] instruction_val;
    input logic [DATA_WIDTH-1:0] expected_reg_file_val; // Expected value in destination register after WB
    input logic [REG_ADDR_WIDTH-1:0] expected_reg_file_addr; // Address of the register to check

    scenario_errors = 0;

    $display("[SCENARIO] %s", test_name);

    // Cycle 0: Setup - Set PC for the instruction to be fetched
    @(posedge clk);
    pc_we_tb = 1; 

    // Wait for 5 cycles for the instruction to pass through the pipeline
    repeat (5) @(posedge clk);
    #1; // Allow combinational logic to settle

    // Check Register File only if RegWrite is enabled for this instruction
    // This assumes that the instruction being tested will eventually write to a register if it's a R-type, I-type (non-load/store), or LUI instruction.
    // For store instructions, this check will be skipped as RegWrite is not enabled.
    // For load instructions, the expected_reg_file_val and expected_reg_file_addr should be provided.
    if (dut.wb_stage_in_bus.data.RegWrite) begin
      if (dut.ID_inst.reg_inst.registers[expected_reg_file_addr] !== expected_reg_file_val) begin
        $error("    FAIL: Register x%0d value mismatch. Expected %h, Got %h", expected_reg_file_addr, expected_reg_file_val, dut.ID_inst.reg_inst.registers[expected_reg_file_addr]);
        scenario_errors++;
      end
    end

    if (scenario_errors == 0) $display("[SUCCESS] %s passed.", test_name);
    error_count += scenario_errors;
  endtask

  // Main test sequence
  initial begin
    error_count = 0;
    $display("=====================================================");
    $display("RISC-V Core Testbench (Full Pipeline) Starting...");
    $display("=====================================================");

    // 1. Reset sequence
    rst_n = 0; pc_we_tb = 0; wb_reg_write_tb = 0; wb_wr_addr_tb = '0; wb_wr_data_tb = '0;
    #(CLK_PERIOD * 2);
    rst_n = 1;
    $display("Reset released.");

    // 2. Preload register file: x1 = 100, x2 = 50
    $display("[SETUP] Preloading Register File...");
    // 모든 레지스터를 0으로 초기화
    foreach (dut.ID_inst.reg_inst.registers[i]) begin
      dut.ID_inst.reg_inst.registers[i] = 32'h0;
    end
    dut.ID_inst.reg_inst.registers[1] = 32'd100;
    dut.ID_inst.reg_inst.registers[2] = 32'd50;
    $display("  - x1 set to 100");
    $display("  - x2 set to 50");

    // Preload data memory for LW test
    $display("[SETUP] Preloading Data Memory...");
    dut.MEM_inst.data_mem_inst.data_memory[33] = 32'hDEADBEEF; // Address 132 (100+32) -> index 33
    $display("  - data_memory[33] set to 0xDEADBEEF (for lw x5, 32(x1))");

    // --- Test Scenarios ---
    check_instruction_flow(
      .test_name("R-Type ADD (add x3, x1, x2)"),
      .instruction_val(32'h002081b3), // add x3, x1, x2
      .expected_reg_file_val(32'd150),
      .expected_reg_file_addr(5'd3)
    );

    check_instruction_flow(
      .test_name("I-Type ADDI (addi x4, x1, 100)"),
      .instruction_val(32'h06408213), // addi x4, x1, 100
      .expected_reg_file_val(32'd200),
      .expected_reg_file_addr(5'd4)
    );

    check_instruction_flow(
      .test_name("Load Word LW (lw x5, 32(x1))"),
      .instruction_val(32'h0200A283), // lw x5, 32(x1)
      .expected_reg_file_val(32'hDEADBEEF),
      .expected_reg_file_addr(5'd5)
    );

    check_instruction_flow(
      .test_name("Store Word SW (sw x2, 32(x1))"),
      .instruction_val(32'h0220A023), // sw x2, 32(x1)
      .expected_reg_file_val(32'h0), // No write-back
      .expected_reg_file_addr(5'd0) // No write-back
    );

    // Check data memory after SW instruction
    $display("[CHECK] Data Memory after Store Word (sw x2, 32(x1))...");
    if (dut.MEM_inst.data_mem_inst.data_memory[33] !== 32'd50) begin
      $error("    FAIL: Data memory at address 0x84 (index 33) mismatch. Expected %h, Got %h", 32'd50, dut.MEM_inst.data_mem_inst.data_memory[33]);
      error_count++;
    end else begin
      $display("    PASS: Data memory at address 0x84 (index 33) is 0x%h.", dut.MEM_inst.data_mem_inst.data_memory[33]);
    end

    check_instruction_flow(
      .test_name("LUI (lui x6, 0xF5)"),
      .instruction_val(32'h000F5337), // lui x6, 0xF5
      .expected_reg_file_val(32'hF5000),
      .expected_reg_file_addr(5'd6)
    );

    $display("=====================================================");
    if (error_count == 0) begin
      $display("All RISC-V Core pipeline tests passed!");
    end else begin
      $display("RISC-V Core tests finished with %0d error(s).", error_count);
    end
    $display("=====================================================");
    repeat(100) @(posedge clk);
    $finish;
  end

endmodule
