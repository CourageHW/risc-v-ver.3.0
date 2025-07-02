`timescale 1ns / 1ps

import core_pkg::*;

module ID_stage (
  input  logic clk,
  IF2ID_if.SLAVE bus_in,

  // from Write back
  input  logic WB_RegWrite_i,
  input  logic [REG_ADDR_WIDTH-1:0] wr_addr_i,
  input  logic [DATA_WIDTH-1:0] wr_data_i,

  output logic [DATA_WIDTH-1:0] immediate_o,
  output logic [DATA_WIDTH-1:0] rd_data1_o,
  output logic [DATA_WIDTH-1:0] rd_data2_o,
  
  output logic ALUSrcA_o,
  output logic ALUSrcB_o,
  output alu_op_e ALUOp_o,
  output logic Branch_o,
  output logic Jump_o,
  output logic MemWrite_o,
  output logic MemRead_o,
  output logic RegWrite_o,
  output wb_sel_e WBSel_o
);

  
  logic [6:0] opcode_w;

  logic [REG_ADDR_WIDTH-1:0] rs1_addr_w;
  logic [REG_ADDR_WIDTH-1:0] rs2_addr_w;

  imm_sel_e ImmSel_w;


  main_control_unit main_ctrl_inst (
    .opcode_i(opcode_w),
    .ImmSel_o(ImmSel_w),
    .ALUSrcA_o(ALUSrcA_o),
    .ALUSrcB_o(ALUSrcB_o),
    .ALUOp_o(ALUOp_o),
    .Branch_o(Branch_o),
    .Jump_o(Jump_o),
    .MemWrite_o(MemWrite_o),
    .MemRead_o(MemRead_o),
    .RegWrite_o(RegWrite_o),
    .WBSel_o(WBSel_o)
  );

  register_file reg_inst (
    .clk(clk),
    .WB_RegWrite_i(WB_RegWrite_i),
    .rs1_addr_i(rs1_addr_w),
    .rs2_addr_i(rs2_addr_w),
    .wr_addr_i(wr_addr_i),
    .wr_data_i(wr_data_i),
    .rd_data1_o(rd_data1_o),
    .rd_data2_o(rd_data2_o)
  );

  immediate_generator imm_gen_inst (
    .instruction_i(bus_in.instruction),
    .ImmSel_i(ImmSel_w),
    .immediate_o(immediate_o)
  );

  assign opcode_w   = bus_in.instruction[6:0];
  assign rs1_addr_w = bus_in.instruction[19:15];
  assign rs2_addr_w = bus_in.instruction[24:20];
endmodule
