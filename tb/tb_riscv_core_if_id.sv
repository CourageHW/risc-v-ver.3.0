`timescale 1ns / 1ps

import core_pkg::*;

module tb_riscv_core_if_id;

  localparam CLK_PERIOD = 10;

  // DUT Inputs
  logic clk;
  logic rst_n;
  logic [DATA_WIDTH-1:0] pc_i_tb;

  // Testbench controlled inputs for other stages
  logic wb_reg_write_tb;
  logic [REG_ADDR_WIDTH-1:0] wb_wr_addr_tb;
  logic [DATA_WIDTH-1:0] wb_wr_data_tb;

  integer error_count;
  
  // Instantiate the core
  riscv_core dut (
    .clk(clk),
    .rst_n(rst_n),
    .WB_RegWrite_w(wb_reg_write_tb),
    .WB_wr_addr_w(wb_wr_addr_tb),
    .WB_wr_data_w(wb_wr_data_tb),
    .pc_i(pc_i_tb)
  );

  // Clock generator
  always #(CLK_PERIOD / 2) clk = ~clk;

  // Helper task to inject instruction and check outputs
  task check_pipeline_outputs;
    input string test_name;
    input logic [DATA_WIDTH-1:0] instruction_val;
    input logic [DATA_WIDTH-1:0] pc_val;

    // Expected outputs for IF stage
    input logic [DATA_WIDTH-1:0] expected_if_instruction;
    input logic [DATA_WIDTH-1:0] expected_if_pc;
    input logic [DATA_WIDTH-1:0] expected_if_pc_plus4;

    // Expected outputs for ID stage
    input logic [DATA_WIDTH-1:0] expected_id_rd_data1;
    input logic [DATA_WIDTH-1:0] expected_id_rd_data2;
    input logic [DATA_WIDTH-1:0] expected_id_immediate;
    input logic expected_id_ALUSrcA;
    input logic expected_id_ALUSrcB;
    input alu_op_e expected_id_ALUOp;
    input logic expected_id_Branch;
    input logic expected_id_Jump;
    input logic expected_id_MemWrite;
    input logic expected_id_MemRead;
    input logic expected_id_RegWrite;
    input wb_sel_e expected_id_WBSel;
    input logic [REG_ADDR_WIDTH-1:0] expected_id_rd_addr;

    integer scenario_errors = 0;

    $display("\n[Scenario] %s", test_name);

    // Inject instruction into memory and set PC
    dut.IF_inst.inst_mem_inst.instruction_memory[pc_val / 4] = instruction_val;
    pc_i_tb = pc_val;
    #(CLK_PERIOD); // Wait for IF stage to fetch

    // Check IF stage outputs (after 1 cycle)
    #1; // Let combinational logic settle
    $display("  - Checking IF stage outputs...");
    if (dut.IF_inst.bus_out.data.instruction !== expected_if_instruction) begin $error("  %s FAIL: IF_instruction. Expected %h, Got %h", test_name, expected_if_instruction, dut.IF_inst.bus_out.data.instruction); scenario_errors++; end
    if (dut.IF_inst.bus_out.data.pc !== expected_if_pc) begin $error("  %s FAIL: IF_pc. Expected %h, Got %h", test_name, expected_if_pc, dut.IF_inst.bus_out.data.pc); scenario_errors++; end
    if (dut.IF_inst.bus_out.data.pc_plus4 !== expected_if_pc_plus4) begin $error("  %s FAIL: IF_pc_plus4. Expected %h, Got %h", test_name, expected_if_pc_plus4, dut.IF_inst.bus_out.data.pc_plus4); scenario_errors++; end

    #(CLK_PERIOD); // Wait for ID stage to process

    // Check ID stage outputs (after 2 cycles total)
    #1; // Let combinational logic settle
    $display("  - Checking ID stage outputs...");
    if (dut.ID_inst.bus_out.data.rd_data1 !== expected_id_rd_data1) begin $error("  %s FAIL: ID_rd_data1. Expected %d, Got %d", test_name, expected_id_rd_data1, dut.ID_inst.bus_out.data.rd_data1); scenario_errors++; end
    if (dut.ID_inst.bus_out.data.rd_data2 !== expected_id_rd_data2) begin $error("  %s FAIL: ID_rd_data2. Expected %d, Got %d", test_name, expected_id_rd_data2, dut.ID_inst.bus_out.data.rd_data2); scenario_errors++; end
    if (dut.ID_inst.bus_out.data.immediate !== expected_id_immediate) begin $error("  %s FAIL: ID_immediate. Expected %h, Got %h", test_name, expected_id_immediate, dut.ID_inst.bus_out.data.immediate); scenario_errors++; end
    if (dut.ID_inst.bus_out.data.ALUSrcA !== expected_id_ALUSrcA) begin $error("  %s FAIL: ID_ALUSrcA. Expected %b, Got %b", test_name, expected_id_ALUSrcA, dut.ID_inst.bus_out.data.ALUSrcA); scenario_errors++; end
    if (dut.ID_inst.bus_out.data.ALUSrcB !== expected_id_ALUSrcB) begin $error("  %s FAIL: ID_ALUSrcB. Expected %b, Got %b", test_name, expected_id_ALUSrcB, dut.ID_inst.bus_out.data.ALUSrcB); scenario_errors++; end
    if (dut.ID_inst.bus_out.data.ALUOp !== expected_id_ALUOp) begin $error("  %s FAIL: ID_ALUOp. Expected %s, Got %s", test_name, expected_id_ALUOp.name(), dut.ID_inst.bus_out.data.ALUOp.name()); scenario_errors++; end
    if (dut.ID_inst.bus_out.data.Branch !== expected_id_Branch) begin $error("  %s FAIL: ID_Branch. Expected %b, Got %b", test_name, expected_id_Branch, dut.ID_inst.bus_out.data.Branch); scenario_errors++; end
    if (dut.ID_inst.bus_out.data.Jump !== expected_id_Jump) begin $error("  %s FAIL: ID_Jump. Expected %b, Got %b", test_name, expected_id_Jump, dut.ID_inst.bus_out.data.Jump); scenario_errors++; end
    if (dut.ID_inst.bus_out.data.MemWrite !== expected_id_MemWrite) begin $error("  %s FAIL: ID_MemWrite. Expected %b, Got %b", test_name, expected_id_MemWrite, dut.ID_inst.bus_out.data.MemWrite); scenario_errors++; end
    if (dut.ID_inst.bus_out.data.MemRead !== expected_id_MemRead) begin $error("  %s FAIL: ID_MemRead. Expected %b, Got %b", test_name, expected_id_MemRead, dut.ID_inst.bus_out.data.MemRead); scenario_errors++; end
    if (dut.ID_inst.bus_out.data.RegWrite !== expected_id_RegWrite) begin $error("  %s FAIL: ID_RegWrite. Expected %b, Got %b", test_name, expected_id_RegWrite, dut.ID_inst.bus_out.data.RegWrite); scenario_errors++; end
    if (dut.ID_inst.bus_out.data.WBSel !== expected_id_WBSel) begin $error("  %s FAIL: ID_WBSel. Expected %s, Got %s", test_name, expected_id_WBSel.name(), dut.ID_inst.bus_out.data.WBSel.name()); scenario_errors++; end
    if (dut.ID_inst.bus_out.data.rd_addr !== expected_id_rd_addr) begin $error("  %s FAIL: ID_rd_addr. Expected %d, Got %d", test_name, expected_id_rd_addr, dut.ID_inst.bus_out.data.rd_addr); scenario_errors++; end

    if (scenario_errors == 0) $display("[SUCCESS] %s", test_name);
    error_count += scenario_errors;
  endtask

  // Main test sequence
  initial begin
    error_count = 0;
    $display("=====================================================");
    $display("Testbench for IF-ID Pipeline starting...");
    $display("=====================================================");

    // 1. Reset sequence
    clk = 0;
    rst_n = 0;
    pc_i_tb = 32'h00000000; // Initial PC
    wb_reg_write_tb = 0;
    wb_wr_addr_tb = '0;
    wb_wr_data_tb = '0;
    #(CLK_PERIOD * 2);
    rst_n = 1;
    $display("Reset released.");

    // Prepare environment: Write values to x1 and x2 for read tests
    $display("\n[Setup] Writing 50 to x1 and 25 to x2...");
    wb_reg_write_tb = 1; 
    wb_wr_addr_tb = 5'd1; 
    wb_wr_data_tb = 32'd50;
    #(CLK_PERIOD);
    wb_wr_addr_tb = 5'd2; 
    wb_wr_data_tb = 32'd25;
    #(CLK_PERIOD);
    wb_reg_write_tb = 0;

    // =================================================================
    // Scenario 1: ADDI (addi x2, x1, 123)
    // =================================================================
    check_pipeline_outputs(
      "ADDI: addi x2, x1, 123",
      {12'd123, 5'd1, 3'b000, 5'd2, 7'b0010011}, // instruction_val
      32'h00000000, // pc_val
      // Expected IF outputs
      {12'd123, 5'd1, 3'b000, 5'd2, 7'b0010011}, // expected_if_instruction
      32'h00000000, // expected_if_pc
      32'h00000004, // expected_if_pc_plus4
      // Expected ID outputs
      32'd50, // expected_id_rd_data1 (value of x1)
      32'dx,  // expected_id_rd_data2 (not used by ADDI, should be 0 or don't care)
      32'd123, // expected_id_immediate
      1'b0, // expected_id_ALUSrcA (rs1)
      1'b1, // expected_id_ALUSrcB (immediate)
      ALUOP_FUNCT3, // expected_id_ALUOp
      1'b0, // expected_id_Branch
      1'b0, // expected_id_Jump
      1'b0, // expected_id_MemWrite
      1'b0, // expected_id_MemRead
      1'b1, // expected_id_RegWrite
      WB_ALU, // expected_id_WBSel
      5'd2  // expected_id_rd_addr (x2)
    );

    // =================================================================
    // Scenario 2: ADD (add x3, x1, x2)
    // =================================================================
    check_pipeline_outputs(
      "ADD: add x3, x1, x2",
      {7'b0000000, 5'd2, 5'd1, 3'b000, 5'd3, 7'b0110011}, // instruction_val
      32'h00000004, // pc_val (next instruction)
      // Expected IF outputs
      {7'b0000000, 5'd2, 5'd1, 3'b000, 5'd3, 7'b0110011}, // expected_if_instruction
      32'h00000004, // expected_if_pc
      32'h00000008, // expected_if_pc_plus4
      // Expected ID outputs
      32'd50, // expected_id_rd_data1 (value of x1)
      32'd25, // expected_id_rd_data2 (value of x2)
      32'd0,  // expected_id_immediate (not used by ADD)
      1'b0, // expected_id_ALUSrcA (rs1)
      1'b0, // expected_id_ALUSrcB (rs2)
      ALUOP_FUNCT7, // expected_id_ALUOp
      1'b0, // expected_id_Branch
      1'b0, // expected_id_Jump
      1'b0, // expected_id_MemWrite
      1'b0, // expected_id_MemRead
      1'b1, // expected_id_RegWrite
      WB_ALU, // expected_id_WBSel
      5'd3  // expected_id_rd_addr (x3)
    );

    // =================================================================
    // Scenario 3: LW (lw x5, 8(x1))
    // =================================================================
    check_pipeline_outputs(
      "LW: lw x5, 8(x1)",
      {12'd8, 5'd1, 3'b010, 5'd5, 7'b0000011}, // instruction_val
      32'h00000008, // pc_val
      // Expected IF outputs
      {12'd8, 5'd1, 3'b010, 5'd5, 7'b0000011}, // expected_if_instruction
      32'h00000008, // expected_if_pc
      32'h0000000C, // expected_if_pc_plus4
      // Expected ID outputs
      32'd50, // expected_id_rd_data1 (value of x1)
      32'dx,  // expected_id_rd_data2 (not used)
      32'd8,  // expected_id_immediate
      1'b0, // expected_id_ALUSrcA (rs1)
      1'b1, // expected_id_ALUSrcB (immediate)
      ALUOP_ADD, // expected_id_ALUOp
      1'b0, // expected_id_Branch
      1'b0, // expected_id_Jump
      1'b0, // expected_id_MemWrite
      1'b1, // expected_id_MemRead
      1'b1, // expected_id_RegWrite
      WB_MEM, // expected_id_WBSel
      5'd5  // expected_id_rd_addr (x5)
    );

    // =================================================================
    // Scenario 4: SW (sw x2, 12(x1))
    // =================================================================
    check_pipeline_outputs(
      "SW: sw x2, 12(x1)",
      {7'b0000000, 5'd2, 5'd1, 3'b010, 5'b01100, 7'b0100011}, // instruction_val
      32'h0000000C, // pc_val
      // Expected IF outputs
      {7'b0000000, 5'd2, 5'd1, 3'b010, 5'b01100, 7'b0100011}, // expected_if_instruction
      32'h0000000C, // expected_if_pc
      32'h00000010, // expected_if_pc_plus4
      // Expected ID outputs
      32'd50, // expected_id_rd_data1 (value of x1)
      32'd25, // expected_id_rd_data2 (value of x2)
      32'd12, // expected_id_immediate (SW immediate is 12)
      1'b0, // expected_id_ALUSrcA (rs1)
      1'b1, // expected_id_ALUSrcB (immediate)
      ALUOP_ADD, // expected_id_ALUOp
      1'b0, // expected_id_Branch
      1'b0, // expected_id_Jump
      1'b1, // expected_id_MemWrite
      1'b0, // expected_id_MemRead
      1'b0, // expected_id_RegWrite (SW does not write to reg file)
      WB_NONE, // expected_id_WBSel (SW does not write to reg file)
      5'd0  // expected_id_rd_addr (not used, should be 0)
    );

    // =================================================================
    // Scenario 5: BEQ (beq x1, x2, offset)
    // =================================================================
    check_pipeline_outputs(
      "BEQ: beq x1, x2, offset",
      {7'b0, 5'd2, 5'd1, 3'b000, 5'b0, 7'b1100011}, // instruction_val (offset is 0 for simplicity)
      32'h00000010, // pc_val
      // Expected IF outputs
      {7'b0, 5'd2, 5'd1, 3'b000, 5'b0, 7'b1100011}, // expected_if_instruction
      32'h00000010, // expected_if_pc
      32'h00000014, // expected_if_pc_plus4
      // Expected ID outputs
      32'd50, // expected_id_rd_data1 (value of x1)
      32'd25, // expected_id_rd_data2 (value of x2)
      32'd0,  // expected_id_immediate (BEQ immediate is 0 for simplicity)
      1'b0, // expected_id_ALUSrcA (rs1)
      1'b0, // expected_id_ALUSrcB (rs2)
      ALUOP_SUB, // expected_id_ALUOp
      1'b1, // expected_id_Branch
      1'b0, // expected_id_Jump
      1'b0, // expected_id_MemWrite
      1'b0, // expected_id_MemRead
      1'b0, // expected_id_RegWrite (BEQ does not write to reg file)
      WB_NONE, // expected_id_WBSel (BEQ does not write to reg file)
      5'd0  // expected_id_rd_addr (not used, should be 0)
    );

    // =================================================================
    // Scenario 6: LUI (lui x6, 0xABCD)
    // =================================================================
    check_pipeline_outputs(
      "LUI: lui x6, 0xABCD",
      {20'hABCDE, 5'd6, 7'b0110111}, // instruction_val
      32'h00000014, // pc_val
      // Expected IF outputs
      {20'hABCDE, 5'd6, 7'b0110111}, // expected_if_instruction
      32'h00000014, // expected_if_pc
      32'h00000018, // expected_if_pc_plus4
      // Expected ID outputs
      32'dx,  // expected_id_rd_data1 (not used)
      32'dx,  // expected_id_rd_data2 (not used)
      32'hABCDE000, // expected_id_immediate
      1'b1, // expected_id_ALUSrcA (PC or 0 for LUI)
      1'b1, // expected_id_ALUSrcB (immediate)
      ALUOP_PASS_B, // expected_id_ALUOp
      1'b0, // expected_id_Branch
      1'b0, // expected_id_Jump
      1'b0, // expected_id_MemWrite
      1'b0, // expected_id_MemRead
      1'b1, // expected_id_RegWrite
      WB_ALU, // expected_id_WBSel
      5'd6  // expected_id_rd_addr (x6)
    );

    // =================================================================
    // Scenario 7: AUIPC (auipc x7, 0xFEDCB)
    // =================================================================
    check_pipeline_outputs(
      "AUIPC: auipc x7, 0xFEDCB",
      {20'hFEDCB, 5'd7, 7'b0010111}, // instruction_val
      32'h00000018, // pc_val
      // Expected IF outputs
      {20'hFEDCB, 5'd7, 7'b0010111}, // expected_if_instruction
      32'h00000018, // expected_if_pc
      32'h0000001C, // expected_if_pc_plus4
      // Expected ID outputs
      32'dx,  // expected_id_rd_data1 (not used)
      32'dx,  // expected_id_rd_data2 (not used)
      32'hFEDCB000, // expected_id_immediate
      1'b1, // expected_id_ALUSrcA (PC)
      1'b1, // expected_id_ALUSrcB (immediate)
      ALUOP_ADD, // expected_id_ALUOp
      1'b0, // expected_id_Branch
      1'b0, // expected_id_Jump
      1'b0, // expected_id_MemWrite
      1'b0, // expected_id_MemRead
      1'b1, // expected_id_RegWrite
      WB_ALU, // expected_id_WBSel
      5'd7  // expected_id_rd_addr (x7)
    );

    // =================================================================
    // Scenario 8: JAL (jal x10, offset)
    // =================================================================
    check_pipeline_outputs(
      "JAL: jal x10, offset",
      {1'b0, 10'd12, 1'b0, 8'd1, 5'd10, 7'b1101111}, // instruction_val (offset is 0 for simplicity)
      32'h0000001C, // pc_val
      // Expected IF outputs
      {1'b0, 10'd12, 1'b0, 8'd1, 5'd10, 7'b1101111}, // expected_if_instruction
      32'h0000001C, // expected_if_pc
      32'h00000020, // expected_if_pc_plus4
      // Expected ID outputs
      32'd0,  // expected_id_rd_data1 (not used, should be 0)
      32'dx,  // expected_id_rd_data2 (not used, should be x)
      32'h00001018,  // expected_id_immediate (JAL immediate is 0x1018)
      1'b0, // expected_id_ALUSrcA (not used by JAL for ALU)
      1'b0, // expected_id_ALUSrcB (not used by JAL for ALU)
      ALUOP_ADD, // expected_id_ALUOp (for PC+4 calculation)
      1'b0, // expected_id_Branch
      1'b1, // expected_id_Jump
      1'b0, // expected_id_MemWrite
      1'b0, // expected_id_MemRead
      1'b1, // expected_id_RegWrite
      WB_PC4, // expected_id_WBSel (PC+4 is written to rd)
      5'd10 // expected_id_rd_addr (x10)
    );

    // =================================================================
    // Scenario 9: JALR (jalr x11, x1, 0)
    // =================================================================
    check_pipeline_outputs(
      "JALR: jalr x11, x1, 0",
      {12'd0, 5'd1, 3'b000, 5'd11, 7'b1100111}, // instruction_val
      32'h00000020, // pc_val
      // Expected IF outputs
      {12'd0, 5'd1, 3'b000, 5'd11, 7'b1100111}, // expected_if_instruction
      32'h00000020, // expected_if_pc
      32'h00000024, // expected_if_pc_plus4
      // Expected ID outputs
      32'd50, // expected_id_rd_data1 (value of x1)
      32'd0,  // expected_id_rd_data2 (not used, should be 0)
      32'd0,  // expected_id_immediate (JALR immediate is 0)
      1'b0, // expected_id_ALUSrcA (rs1)
      1'b1, // expected_id_ALUSrcB (immediate)
      ALUOP_ADD, // expected_id_ALUOp (for address calculation)
      1'b0, // expected_id_Branch
      1'b1, // expected_id_Jump
      1'b0, // expected_id_MemWrite
      1'b0, // expected_id_MemRead
      1'b1, // expected_id_RegWrite
      WB_PC4, // expected_id_WBSel (PC+4 is written to rd)
      5'd11 // expected_id_rd_addr (x11)
    );

    $display("\n=====================================================");
    if (error_count == 0) begin
      $display("All IF-ID pipeline tests passed!");
    end else begin
      $display("IF-ID pipeline tests finished with %0d error(s).", error_count);
    end
    $display("=====================================================");
    repeat(100) @(posedge clk);
    $finish;
  end

endmodule
