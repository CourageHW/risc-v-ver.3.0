`timescale 1ns / 1ps

import core_pkg::*;

module tb_riscv_core;

  localparam CLK_PERIOD = 10;

  integer scenario_errors;
  // DUT Inputs
  logic clk = 0;
  logic rst_n;
  logic pc_we_tb;
  logic [DATA_WIDTH-1:0] pc_i_tb;

  // WB inputs to simulate write-back to register file
  logic wb_reg_write_tb;
  logic [REG_ADDR_WIDTH-1:0] wb_wr_addr_tb;
  logic [DATA_WIDTH-1:0] wb_wr_data_tb;

  integer error_count = 0;
  
  // Instantiate the core
  riscv_core dut (
    .clk(clk),
    .rst_n(rst_n),
    .pc_we(pc_we_tb),
    .pc_i(pc_i_tb),
    .WB_RegWrite_w(wb_reg_write_tb),
    .WB_wr_addr_w(wb_wr_addr_tb),
    .WB_wr_data_w(wb_wr_data_tb)
  );

  // Clock generator
  always #(CLK_PERIOD / 2) clk = ~clk;

  // Task to check the flow of a single instruction through IF, ID, and EX stages
  task check_instruction_flow;
    input string test_name;
    input logic [DATA_WIDTH-1:0] instruction_val;
    input logic [DATA_WIDTH-1:0] pc_val;

    // Expected outputs for each stage
    // --- IF Stage ---
    input logic [DATA_WIDTH-1:0] expected_if_pc_plus4;
    // --- ID Stage ---
    input logic [DATA_WIDTH-1:0] expected_id_immediate;
    input alu_op_e expected_id_ALUOp;
    input logic expected_id_MemWrite;
    input logic expected_id_MemRead;
    input logic expected_id_RegWrite;
    input wb_sel_e expected_id_WBSel;
    // --- EX Stage ---
    input logic [DATA_WIDTH-1:0] expected_ex_alu_result;

    scenario_errors = 0;

    $display("\n[SCENARIO] %s", test_name);

    // Cycle 0: Setup - Inject instruction into memory and set PC
    @(posedge clk);
    dut.IF_inst.inst_mem_inst.instruction_memory[pc_val / 4] = instruction_val;
    pc_i_tb = pc_val;
    pc_we_tb = 1; 

    // Cycle 1: IF stage executes
    @(posedge clk);
    pc_we_tb = 0; // De-assert PC write enable
    #1; // Allow combinational logic to settle

    $display("  - Checking IF -> ID Register Input...");
    if (dut.if_stage_out_bus.data.instruction !== instruction_val) begin $error("    FAIL: Instruction mismatch"); scenario_errors++; end
    if (dut.if_stage_out_bus.data.pc !== pc_val) begin $error("    FAIL: PC mismatch"); scenario_errors++; end
    if (dut.if_stage_out_bus.data.pc_plus4 !== expected_if_pc_plus4) begin $error("    FAIL: PC+4 mismatch"); scenario_errors++; end

    // Cycle 2: ID stage executes
    @(posedge clk);
    #1;
    $display("  - Checking ID -> EX Register Input...");
    if (dut.id_stage_out_bus.data.immediate !== expected_id_immediate) begin $error("    FAIL: Immediate mismatch"); scenario_errors++; end
    if (dut.id_stage_out_bus.data.ALUOp !== expected_id_ALUOp) begin $error("    FAIL: ALUOp mismatch"); scenario_errors++; end
    if (dut.id_stage_out_bus.data.MemWrite !== expected_id_MemWrite) begin $error("    FAIL: MemWrite mismatch"); scenario_errors++; end
    if (dut.id_stage_out_bus.data.MemRead !== expected_id_MemRead) begin $error("    FAIL: MemRead mismatch"); scenario_errors++; end
    if (dut.id_stage_out_bus.data.RegWrite !== expected_id_RegWrite) begin $error("    FAIL: RegWrite mismatch"); scenario_errors++; end
    if (dut.id_stage_out_bus.data.WBSel !== expected_id_WBSel) begin $error("    FAIL: WBSel mismatch"); scenario_errors++; end

    // Cycle 3: EX stage executes
    @(posedge clk);
    #1;
    $display("  - Checking EX -> MEM Register Input...");
    if (dut.ex_stage_out_bus.data.alu_result !== expected_ex_alu_result) begin $error("    FAIL: ALU Result mismatch. Expected %h, Got %h", expected_ex_alu_result, dut.ex_stage_out_bus.data.alu_result); scenario_errors++; end
    if (expected_id_RegWrite && (dut.ex_stage_out_bus.data.rd_addr !== instruction_val[11:7])) begin $error("    FAIL: rd_addr mismatch"); scenario_errors++; end
    if (expected_id_MemWrite && (dut.ex_stage_out_bus.data.rd_data2 !== dut.ID_inst.reg_inst.registers[instruction_val[24:20]])) begin $error("    FAIL: rd_data2 for store mismatch"); scenario_errors++; end

    if (scenario_errors == 0) $display("[SUCCESS] %s passed.", test_name);
    error_count += scenario_errors;
  endtask

  // Main test sequence
  initial begin
    error_count = 0;
    $display("=====================================================");
    $display("RISC-V Core Testbench (IF-ID-EX) Starting...");
    $display("=====================================================");

    // 1. Reset sequence
    rst_n = 0; pc_we_tb = 0; pc_i_tb = 32'h0; wb_reg_write_tb = 0; wb_wr_addr_tb = '0; wb_wr_data_tb = '0;
    #(CLK_PERIOD * 2);
    rst_n = 1;
    $display("Reset released.");

    // 2. Preload register file: x1 = 100, x2 = 50
    $display("\n[SETUP] Preloading Register File...");
    dut.ID_inst.reg_inst.registers[1] = 32'd100;
    dut.ID_inst.reg_inst.registers[2] = 32'd50;
    $display("  - x1 set to 100");
    $display("  - x2 set to 50");

    // --- Test Scenarios ---
    check_instruction_flow(
      .test_name("R-Type ADD"),
      .instruction_val(32'h002081b3), // add x3, x1, x2
      .pc_val(32'h0),
      .expected_if_pc_plus4(32'h4),
      .expected_id_immediate(32'h0),
      .expected_id_ALUOp(ALUOP_FUNCT7),
      .expected_id_MemWrite(1'b0), .expected_id_MemRead(1'b0), .expected_id_RegWrite(1'b1),
      .expected_id_WBSel(WB_ALU),
      .expected_ex_alu_result(32'd150) // 100 + 50
    );

    check_instruction_flow(
      .test_name("I-Type ADDI"),
      .instruction_val(32'h06408213), // addi x4, x1, 100
      .pc_val(32'h4),
      .expected_if_pc_plus4(32'h8),
      .expected_id_immediate(32'd100),
      .expected_id_ALUOp(ALUOP_FUNCT3),
      .expected_id_MemWrite(1'b0), .expected_id_MemRead(1'b0), .expected_id_RegWrite(1'b1),
      .expected_id_WBSel(WB_ALU),
      .expected_ex_alu_result(32'd200) // 100 + 100
    );

    check_instruction_flow(
      .test_name("Load Word LW"),
      .instruction_val(32'h0200A283), // lw x5, 32(x1)
      .pc_val(32'h8),
      .expected_if_pc_plus4(32'hC),
      .expected_id_immediate(32'd32),
      .expected_id_ALUOp(ALUOP_ADD),
      .expected_id_MemWrite(1'b0), .expected_id_MemRead(1'b1), .expected_id_RegWrite(1'b1),
      .expected_id_WBSel(WB_MEM),
      .expected_ex_alu_result(32'd132) // 100 + 32
    );

    check_instruction_flow(
      .test_name("Store Word SW"),
      .instruction_val(32'h0220A023), // sw x2, 32(x1) -> Corrected instruction for imm=32
      .pc_val(32'hC),
      .expected_if_pc_plus4(32'h10),
      .expected_id_immediate(32'd32), // S-type immediate is 32
      .expected_id_ALUOp(ALUOP_ADD),
      .expected_id_MemWrite(1'b1), .expected_id_MemRead(1'b0), .expected_id_RegWrite(1'b0),
      .expected_id_WBSel(WB_NONE),
      .expected_ex_alu_result(32'd132) // 100 + 32
    );

    check_instruction_flow(
      .test_name("LUI"),
      .instruction_val(32'h000F5337), // lui x6, 0xF5
      .pc_val(32'h10),
      .expected_if_pc_plus4(32'h14),
      .expected_id_immediate(32'hF5000),
      .expected_id_ALUOp(ALUOP_PASS_B),
      .expected_id_MemWrite(1'b0), .expected_id_MemRead(1'b0), .expected_id_RegWrite(1'b1),
      .expected_id_WBSel(WB_ALU),
      .expected_ex_alu_result(32'hF5000)
    );

    $display("\n=====================================================");
    if (error_count == 0) begin
      $display("All RISC-V Core pipeline tests passed!");
    end else begin
      $display("RISC-V Core tests finished with %0d error(s).", error_count);
    end
    $display("=====================================================");
    $finish;
  end

endmodule
