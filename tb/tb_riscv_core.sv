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

  // Connect WB stage outputs to core's WB inputs (feedback to ID stage)
  assign wb_reg_write_tb = dut.wb_stage_in_bus.data.RegWrite;
  assign wb_wr_addr_tb   = dut.wb_stage_in_bus.data.rd_addr;
  assign wb_wr_data_tb   = (dut.wb_stage_in_bus.data.WBSel == WB_MEM) ? dut.wb_stage_in_bus.data.rd_data : dut.wb_stage_in_bus.data.alu_result;

  // Task to check the flow of a single instruction through IF, ID, EX, MEM, and WB stages
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
    input logic [REG_ADDR_WIDTH-1:0] expected_ex_rd_addr;
    input logic [DATA_WIDTH-1:0] expected_ex_rd_data2;

    // --- MEM Stage ---
    input logic [DATA_WIDTH-1:0] expected_mem_alu_result;
    input logic [REG_ADDR_WIDTH-1:0] expected_mem_rd_addr;
    input logic expected_mem_RegWrite;
    input wb_sel_e expected_mem_WBSel;
    input logic [DATA_WIDTH-1:0] expected_mem_rd_data; // For load instructions

    // --- WB Stage ---
    input logic [DATA_WIDTH-1:0] expected_wb_alu_result;
    input logic [REG_ADDR_WIDTH-1:0] expected_wb_rd_addr;
    input logic expected_wb_RegWrite;
    input wb_sel_e expected_wb_WBSel;
    input logic [DATA_WIDTH-1:0] expected_wb_rd_data; // For load instructions
    input logic [DATA_WIDTH-1:0] expected_reg_file_val; // Expected value in destination register after WB
    input logic [REG_ADDR_WIDTH-1:0] expected_reg_file_addr; // Address of the register to check

    scenario_errors = 0;

    $display("[SCENARIO] %s", test_name);

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
    if (dut.ex_stage_out_bus.data.rd_addr !== expected_ex_rd_addr) begin $error("    FAIL: EX rd_addr mismatch. Expected %d, Got %d", expected_ex_rd_addr, dut.ex_stage_out_bus.data.rd_addr); scenario_errors++; end
    if (dut.ex_stage_out_bus.data.rd_data2 !== expected_ex_rd_data2) begin $error("    FAIL: EX rd_data2 mismatch. Expected %h, Got %h", expected_ex_rd_data2, dut.ex_stage_out_bus.data.rd_data2); scenario_errors++; end

    // Cycle 4: MEM stage executes
    @(posedge clk);
    #1;
    $display("  - Checking MEM -> WB Register Input...");
    if (dut.mem_stage_out_bus.data.alu_result !== expected_mem_alu_result) begin $error("    FAIL: MEM alu_result mismatch. Expected %h, Got %h", expected_mem_alu_result, dut.mem_stage_out_bus.data.alu_result); scenario_errors++; end
    if (dut.mem_stage_out_bus.data.rd_addr !== expected_mem_rd_addr) begin $error("    FAIL: MEM rd_addr mismatch. Expected %d, Got %d", expected_mem_rd_addr, dut.mem_stage_out_bus.data.rd_addr); scenario_errors++; end
    if (dut.mem_stage_out_bus.data.RegWrite !== expected_mem_RegWrite) begin $error("    FAIL: MEM RegWrite mismatch. Expected %b, Got %b", expected_mem_RegWrite, dut.mem_stage_out_bus.data.RegWrite); scenario_errors++; end
    if (dut.mem_stage_out_bus.data.WBSel !== expected_mem_WBSel) begin $error("    FAIL: MEM WBSel mismatch. Expected %s, Got %s", expected_mem_WBSel.name(), dut.mem_stage_out_bus.data.WBSel.name()); scenario_errors++; end
    if (expected_mem_WBSel == WB_MEM && dut.mem_stage_out_bus.data.rd_data !== expected_mem_rd_data) begin $error("    FAIL: MEM rd_data mismatch. Expected %h, Got %h", expected_mem_rd_data, dut.mem_stage_out_bus.data.rd_data); scenario_errors++; end

    // Cycle 5: WB stage executes and Register File is written
    @(posedge clk);
    #1;
    $display("  - Checking WB Stage Output and Register File...");
    if (dut.wb_stage_in_bus.data.alu_result !== expected_wb_alu_result) begin $error("    FAIL: WB alu_result mismatch. Expected %h, Got %h", expected_wb_alu_result, dut.wb_stage_in_bus.data.alu_result); scenario_errors++; end
    if (dut.wb_stage_in_bus.data.rd_addr !== expected_wb_rd_addr) begin $error("    FAIL: WB rd_addr mismatch. Expected %d, Got %d", expected_wb_rd_addr, dut.wb_stage_in_bus.data.rd_addr); scenario_errors++; end
    if (dut.wb_stage_in_bus.data.RegWrite !== expected_wb_RegWrite) begin $error("    FAIL: WB RegWrite mismatch. Expected %b, Got %b", expected_wb_RegWrite, dut.wb_stage_in_bus.data.RegWrite); scenario_errors++; end
    if (dut.wb_stage_in_bus.data.WBSel !== expected_wb_WBSel) begin $error("    FAIL: WB WBSel mismatch. Expected %s, Got %s", expected_wb_WBSel.name(), dut.wb_stage_in_bus.data.WBSel.name()); scenario_errors++; end
    if (expected_wb_WBSel == WB_MEM && dut.wb_stage_in_bus.data.rd_data !== expected_wb_rd_data) begin $error("    FAIL: WB rd_data mismatch. Expected %h, Got %h", expected_wb_rd_data, dut.wb_stage_in_bus.data.rd_data); scenario_errors++; end

    // Check Register File only if RegWrite is enabled for this instruction
    if (expected_wb_RegWrite) begin
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
    rst_n = 0; pc_we_tb = 0; pc_i_tb = 32'h0; wb_reg_write_tb = 0; wb_wr_addr_tb = '0; wb_wr_data_tb = '0;
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
      .pc_val(32'h0),
      .expected_if_pc_plus4(32'h4),
      .expected_id_immediate(32'h0),
      .expected_id_ALUOp(ALUOP_FUNCT7),
      .expected_id_MemWrite(1'b0), .expected_id_MemRead(1'b0), .expected_id_RegWrite(1'b1),
      .expected_id_WBSel(WB_ALU),
      .expected_ex_alu_result(32'd150), // 100 + 50
      .expected_ex_rd_addr(5'd3),
      .expected_ex_rd_data2(32'd50),
      .expected_mem_alu_result(32'd150),
      .expected_mem_rd_addr(5'd3),
      .expected_mem_RegWrite(1'b1),
      .expected_mem_WBSel(WB_ALU),
      .expected_mem_rd_data(32'h0),
      .expected_wb_alu_result(32'd150),
      .expected_wb_rd_addr(5'd3),
      .expected_wb_RegWrite(1'b1),
      .expected_wb_WBSel(WB_ALU),
      .expected_wb_rd_data(32'h0),
      .expected_reg_file_val(32'd150),
      .expected_reg_file_addr(5'd3)
    );

    check_instruction_flow(
      .test_name("I-Type ADDI (addi x4, x1, 100)"),
      .instruction_val(32'h06408213), // addi x4, x1, 100
      .pc_val(32'h4),
      .expected_if_pc_plus4(32'h8),
      .expected_id_immediate(32'd100),
      .expected_id_ALUOp(ALUOP_FUNCT3),
      .expected_id_MemWrite(1'b0), .expected_id_MemRead(1'b0), .expected_id_RegWrite(1'b1),
      .expected_id_WBSel(WB_ALU),
      .expected_ex_alu_result(32'd200), // 100 + 100
      .expected_ex_rd_addr(5'd4),
      .expected_ex_rd_data2(32'h0),
      .expected_mem_alu_result(32'd200),
      .expected_mem_rd_addr(5'd4),
      .expected_mem_RegWrite(1'b1),
      .expected_mem_WBSel(WB_ALU),
      .expected_mem_rd_data(32'h0),
      .expected_wb_alu_result(32'd200),
      .expected_wb_rd_addr(5'd4),
      .expected_wb_RegWrite(1'b1),
      .expected_wb_WBSel(WB_ALU),
      .expected_wb_rd_data(32'h0),
      .expected_reg_file_val(32'd200),
      .expected_reg_file_addr(5'd4)
    );

    check_instruction_flow(
      .test_name("Load Word LW (lw x5, 32(x1))"),
      .instruction_val(32'h0200A283), // lw x5, 32(x1)
      .pc_val(32'h8),
      .expected_if_pc_plus4(32'hC),
      .expected_id_immediate(32'd32),
      .expected_id_ALUOp(ALUOP_ADD),
      .expected_id_MemWrite(1'b0), .expected_id_MemRead(1'b1), .expected_id_RegWrite(1'b1),
      .expected_id_WBSel(WB_MEM),
      .expected_ex_alu_result(32'd132), // 100 + 32
      .expected_ex_rd_addr(5'd5),
      .expected_ex_rd_data2(32'h0),
      .expected_mem_alu_result(32'd132),
      .expected_mem_rd_addr(5'd5),
      .expected_mem_RegWrite(1'b1),
      .expected_mem_WBSel(WB_MEM),
      .expected_mem_rd_data(32'hDEADBEEF), // Value read from memory
      .expected_wb_alu_result(32'd132),
      .expected_wb_rd_addr(5'd5),
      .expected_wb_RegWrite(1'b1),
      .expected_wb_WBSel(WB_MEM),
      .expected_wb_rd_data(32'hDEADBEEF),
      .expected_reg_file_val(32'hDEADBEEF),
      .expected_reg_file_addr(5'd5)
    );

    check_instruction_flow(
      .test_name("Store Word SW (sw x2, 32(x1))"),
      .instruction_val(32'h0220A023), // sw x2, 32(x1)
      .pc_val(32'hC),
      .expected_if_pc_plus4(32'h10),
      .expected_id_immediate(32'd32),
      .expected_id_ALUOp(ALUOP_ADD),
      .expected_id_MemWrite(1'b1), .expected_id_MemRead(1'b0), .expected_id_RegWrite(1'b0),
      .expected_id_WBSel(WB_NONE),
      .expected_ex_alu_result(32'd132), // 100 + 32
      .expected_ex_rd_addr(5'd0), // Not used for store
      .expected_ex_rd_data2(32'd50), // Value of x2
      .expected_mem_alu_result(32'd132),
      .expected_mem_rd_addr(5'd0),
      .expected_mem_RegWrite(1'b0),
      .expected_mem_WBSel(WB_NONE),
      .expected_mem_rd_data(32'h0), // Not a load
      .expected_wb_alu_result(32'd132),
      .expected_wb_rd_addr(5'd0),
      .expected_wb_RegWrite(1'b0),
      .expected_wb_WBSel(WB_NONE),
      .expected_wb_rd_data(32'h0),
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
      .pc_val(32'h10),
      .expected_if_pc_plus4(32'h14),
      .expected_id_immediate(32'hF5000),
      .expected_id_ALUOp(ALUOP_PASS_B),
      .expected_id_MemWrite(1'b0), .expected_id_MemRead(1'b0), .expected_id_RegWrite(1'b1),
      .expected_id_WBSel(WB_ALU),
      .expected_ex_alu_result(32'hF5000),
      .expected_ex_rd_addr(5'd6),
      .expected_ex_rd_data2(32'h0),
      .expected_mem_alu_result(32'hF5000),
      .expected_mem_rd_addr(5'd6),
      .expected_mem_RegWrite(1'b1),
      .expected_mem_WBSel(WB_ALU),
      .expected_mem_rd_data(32'h0),
      .expected_wb_alu_result(32'hF5000),
      .expected_wb_rd_addr(5'd6),
      .expected_wb_RegWrite(1'b1),
      .expected_wb_WBSel(WB_ALU),
      .expected_wb_rd_data(32'h0),
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
