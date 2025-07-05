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

  id_ex_data_t id_ex_data_w;

  imm_sel_e ImmSel_w;
  logic ALUSrcA_w, ALUSrcB_w, Branch_w, Jump_w, MemWrite_w, MemRead_w, RegWrite_w;
  wb_sel_e WBSel_w;


  main_control_unit main_ctrl_inst (
    .opcode_i(bus_in.data.instruction[6:0]),
    .funct3_i(bus_in.data.instruction[14:12]),
    .ImmSel_o(ImmSel_w),
    .ALUSrcA_o(ALUSrcA_w),
    .ALUSrcB_o(ALUSrcB_w),
    .Branch_o(Branch_w),
    .Jump_o(Jump_w),
    .MemWrite_o(MemWrite_w),
    .MemRead_o(MemRead_w),
    .RegWrite_o(RegWrite_w),
    .WBSel_o(WBSel_w)
  );

  register_file reg_inst (
    .clk(clk),
    .WB_RegWrite_i(WB_RegWrite_i),
    .rs1_addr_i(bus_in.data.instruction[19:15]),
    .rs2_addr_i(bus_in.data.instruction[24:20]),
    .wr_addr_i(wr_addr_i),
    .wr_data_i(wr_data_i),
    .rd_data1_o(id_ex_data_w.rd_data1),
    .rd_data2_o(id_ex_data_w.rd_data2)
  );

  immediate_generator imm_gen_inst (
    .instruction_i(bus_in.data.instruction),
    .ImmSel_i(ImmSel_w),
    .immediate_o(id_ex_data_w.immediate)
  );


  assign id_ex_data_w.instruction = bus_in.data.instruction;
  assign id_ex_data_w.pc       = bus_in.data.pc;
  assign id_ex_data_w.pc_plus4 = bus_in.data.pc_plus4;
  assign id_ex_data_w.rd_addr  = RegWrite_w ? bus_in.data.instruction[11:7] : 5'b0;

  assign id_ex_data_w.ALUSrcA  = ALUSrcA_w;
  assign id_ex_data_w.ALUSrcB  = ALUSrcB_w;
  assign id_ex_data_w.Branch   = Branch_w;
  assign id_ex_data_w.Jump     = Jump_w;
  assign id_ex_data_w.MemWrite = MemWrite_w;
  assign id_ex_data_w.MemRead  = MemRead_w;
  assign id_ex_data_w.RegWrite = RegWrite_w;
  assign id_ex_data_w.WBSel    = WBSel_w;
  
  assign bus_out.data          = id_ex_data_w;
endmodule
