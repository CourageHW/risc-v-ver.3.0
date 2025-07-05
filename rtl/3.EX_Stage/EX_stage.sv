`timescale 1ns / 1ps 

import core_pkg::*;

module EX_stage (
  input fw_sel_e forwardA,
  input fw_sel_e forwardB,
  input logic [DATA_WIDTH-1:0] alu_result_MEM_i,
  input logic [DATA_WIDTH-1:0] wb_data_WB_i,
  input logic [DATA_WIDTH-1:0] mem_data_MEM_i,
  ID2EX_if.SLAVE bus_in,

  output logic PCSrc_o,
  output logic flush_pipeline_o,
  output logic [DATA_WIDTH-1:0] branch_target_addr_o,
  EX2MEM_if.MASTER bus_out
);

ex_mem_data_t ex_mem_data_w;

alu_sel_e ALUSel_w;

logic [DATA_WIDTH-1:0] rd_data1_w;
logic [DATA_WIDTH-1:0] rd_data2_w;

logic [DATA_WIDTH-1:0] operand1_w;
logic [DATA_WIDTH-1:0] operand2_w;

logic BrEQ_w, BrLT_w, BrLTU_w;
logic BranchTaken_w;

branch_comparator branch_comp_inst (
  .operand1_i(operand1_w),
  .operand2_i(operand2_w),
  .BrEQ_o(BrEQ_w),
  .BrLT_o(BrLT_w),
  .BrLTU_o(BrLTU_w)
);

branch_determination branch_det_inst (
  .BrEQ_i(BrEQ_w),
  .BrLT_i(BrLT_w),
  .BrLTU_i(BrLTU_w),
  .Branch_i(bus_in.data.Branch),
  .funct3_i(bus_in.data.instruction[14:12]),
  .BranchTaken_o(BranchTaken_w)
);

alu_control_unit alu_ctrl_inst (
  .opcode_i(bus_in.data.instruction[6:0]),
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
    FW_MEM_DATA: rd_data1_w = mem_data_MEM_i;
    default    : rd_data1_w = bus_in.data.rd_data1;
  endcase
end

always_comb begin
  unique case (forwardB)
    FW_NONE    : rd_data2_w = bus_in.data.rd_data2;
    FW_MEM_ALU : rd_data2_w = alu_result_MEM_i;
    FW_WB_DATA : rd_data2_w = wb_data_WB_i;
    FW_MEM_DATA: rd_data2_w = mem_data_MEM_i;
    default    : rd_data2_w = bus_in.data.rd_data2;
  endcase
end

assign operand1_w = (bus_in.data.ALUSrcA) ? bus_in.data.pc : rd_data1_w;
assign operand2_w = (bus_in.data.ALUSrcB) ? bus_in.data.immediate : rd_data2_w;

assign PCSrc_o                   = (BranchTaken_w | bus_in.data.Jump);
assign flush_pipeline_o          = (BranchTaken_w | bus_in.data.Jump);
assign branch_target_addr_o      = (bus_in.data.pc + bus_in.data.immediate);

assign ex_mem_data_w.instruction = bus_in.data.instruction;
assign ex_mem_data_w.pc_plus4    = bus_in.data.pc_plus4;
assign ex_mem_data_w.rd_addr     = bus_in.data.rd_addr;
assign ex_mem_data_w.rd_data2    = rd_data2_w;

assign ex_mem_data_w.RegWrite    = bus_in.data.RegWrite;
assign ex_mem_data_w.MemWrite    = bus_in.data.MemWrite;
assign ex_mem_data_w.MemRead     = bus_in.data.MemRead;
assign ex_mem_data_w.WBSel       = bus_in.data.WBSel;

assign bus_out.data = ex_mem_data_w;
endmodule
