`timescale 1ns / 1ps 

import core_pkg::*;

module EX_stage (
  ID2EX_if.SLAVE bus_in,
  EX2MEM_if.MASTER bus_out
);

ex_mem_data_t ex_mem_data_w;

alu_sel_e ALUSel_w;
alu_op_e ALUOp_w;
logic [2:0] funct3_w;
logic       funct7_w;

logic [DATA_WIDTH-1:0] rd_data1_w;
logic [DATA_WIDTH-1:0] rd_data2_w;

logic [DATA_WIDTH-1:0] operand1_w;
logic [DATA_WIDTH-1:0] operand2_w;


alu_control_unit alu_ctrl_inst (
  .ALUOp_i(ALUOp_w),
  .funct3_i(funct3_w),
  .funct7_i(funct7_w),
  .ALUSel_o(ALUSel_w)
);

alu alu_inst (
  .operand1_i(operand1_w),
  .operand2_i(operand2_w),
  .ALUSel_i(ALUSel_w),
  .alu_result_o(ex_mem_data_w.alu_result)
);


// Branch, Jump, Forwarding 기능은 추후 추가 예정
assign ALUOp_w  = bus_in.data.ALUOp;
assign funct3_w = bus_in.data.instruction[14:12];
assign funct7_w = bus_in.data.instruction[30];

assign rd_data1_w = bus_in.data.rd_data1;
assign rd_data2_w = bus_in.data.rd_data2;

assign operand1_w = (bus_in.data.ALUSrcA) ? bus_in.data.pc : rd_data1_w;
assign operand2_w = (bus_in.data.ALUSrcB) ? bus_in.data.immediate : rd_data2_w;

assign ex_mem_data_w.instruction = bus_in.data.instruction;
assign ex_mem_data_w.pc_plus4    = bus_in.data.pc_plus4;
assign ex_mem_data_w.rd_addr     = bus_in.data.rd_addr;
assign ex_mem_data_w.rd_data2    = bus_in.data.rd_data2;

assign ex_mem_data_w.RegWrite    = bus_in.data.RegWrite;
assign ex_mem_data_w.MemWrite    = bus_in.data.MemWrite;
assign ex_mem_data_w.MemRead     = bus_in.data.MemRead;
assign ex_mem_data_w.WBSel       = bus_in.data.WBSel;

assign bus_out.data = ex_mem_data_w;
endmodule
