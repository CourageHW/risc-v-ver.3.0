`timescale 1ns / 1ps

import core_pkg::*;

module ID_stage (
  input  logic clk,
  IF2ID_if.SLAVE bus_in,

  // from Write back
  input  logic WB_RegWrite_i,
  input  logic [REG_ADDR_WIDTH-1:0] wr_addr_i,
  input  logic [DATA_WIDTH-1:0] wr_data_i,

  ID2EX_if.MASTER bus_out
);

  ID2EX_if.data_t id_ex_data_w;

  
  logic [6:0] opcode_w;

  logic [REG_ADDR_WIDTH-1:0] rs1_addr_w;
  logic [REG_ADDR_WIDTH-1:0] rs2_addr_w;
  logic [REG_ADDR_WIDTH-1:0] rd_addr_w;

  imm_sel_e ImmSel_w;


  main_control_unit main_ctrl_inst (
    .opcode_i(opcode_w),
    .ImmSel_o(ImmSel_w),
    .ALUSrcA_o(id_ex_data_w.ALUSrcA),
    .ALUSrcB_o(id_ex_data_w.ALUSrcB),
    .ALUOp_o(id_ex_data_w.ALUOp),
    .Branch_o(id_ex_data_w.Branch),
    .Jump_o(id_ex_data_w.Jump),
    .MemWrite_o(id_ex_data_w.MemWrite),
    .MemRead_o(id_ex_data_w.MemRead),
    .RegWrite_o(id_ex_data_w.RegWrite),
    .WBSel_o(id_ex_data_w.WBSel)
  );

  register_file reg_inst (
    .clk(clk),
    .WB_RegWrite_i(WB_RegWrite_i),
    .rs1_addr_i(rs1_addr_w),
    .rs2_addr_i(rs2_addr_w),
    .wr_addr_i(wr_addr_i),
    .wr_data_i(wr_data_i),
    .rd_data1_o(id_ex_data_w.rd_data1),
    .rd_data2_o(id_ex_data_w.rd_data2)
  );

  immediate_generator imm_gen_inst (
    .instruction_i(bus_in.instruction),
    .ImmSel_i(ImmSel_w),
    .immediate_o(id_ex_data_w.immediate)
  );

  assign opcode_w              = bus_in.data.instruction[6:0];
  assign rs1_addr_w            = bus_in.data.instruction[19:15];
  assign rs2_addr_w            = bus_in.data.instruction[24:20];

  assign id_ex_data_w.pc       = bus_in.data.pc;
  assign id_ex_data_w.pc_plus4 = bus_in.data.pc_plus4;
  assign id_ex_data_w.rd_addr  = bus_in.data.instruction[11:7];

  assign bus_out.data          = id_ex_data_w;
endmodule
