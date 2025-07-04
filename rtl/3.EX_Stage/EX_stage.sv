`timescale 1ns / 1ps 

import core_pkg::*;

module EX_stage (
  input fw_sel_e forwardA,
  input fw_sel_e forwardB,
  input logic [DATA_WIDTH-1:0] alu_result_MEM_i,
  input logic [DATA_WIDTH-1:0] wb_data_WB_i,
  ID2EX_if.SLAVE bus_in,
  EX2MEM_if.MASTER bus_out
);

ex_mem_data_t ex_mem_data_w;

alu_sel_e ALUSel_w;

logic [DATA_WIDTH-1:0] rd_data1_w;
logic [DATA_WIDTH-1:0] rd_data2_w;

logic [DATA_WIDTH-1:0] operand1_w;
logic [DATA_WIDTH-1:0] operand2_w;


alu_control_unit alu_ctrl_inst (
  .ALUOp_i(bus_in.data.ALUOp),
  .funct3_i(bus_in.data.instruction[14:12]),
  .funct7_i(bus_in.data.instruction[30]),
  .ALUSel_o(ALUSel_w)
);

alu alu_inst (
  .operand1_i(operand1_w),
  .operand2_i(operand2_w),
  .ALUSel_i(ALUSel_w),
  .alu_result_o(ex_mem_data_w.alu_result)
);



always_comb begin
  unique case (forwardA)
    FW_NONE    : rd_data1_w = bus_in.data.rd_data1;
    FW_MEM_ALU : rd_data1_w = alu_result_MEM_i;
    FW_WB_DATA : rd_data1_w = wb_data_WB_i;
    default    : rd_data1_w = bus_in.data.rd_data1;
  endcase
end

always_comb begin
  unique case (forwardB)
    FW_NONE    : rd_data2_w = bus_in.data.rd_data2;
    FW_MEM_ALU : rd_data2_w = alu_result_MEM_i;
    FW_WB_DATA : rd_data2_w = wb_data_WB_i;
    default    : rd_data2_w = bus_in.data.rd_data2;
  endcase
end

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
