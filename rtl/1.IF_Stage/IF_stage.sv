`timescale 1ns / 1ps

import core_pkg::*;

module IF_stage (
  input logic clk,
  input logic rst_n,
  input logic pc_we,
  output logic [DATA_WIDTH-1:0] inst_o
);
  
  logic [INST_MEM_ADDR_WIDTH-1:0] addr_w;

  program_counter pc_inst (
    .clk(clk),
    .rst_n(rst_n),
    .pc_we(pc_we),
    .pc_i(pc_i),
    .pc_o(pc_o)
  );

  
  instruction_memory inst_mem_inst (
    .addr_i(addr_w),
    .instruction_o(inst_o)
  );

  assign pc_i = pc_o + 4; // 조건 추가 예정
 
  assign addr_w = pc_o[INST_MEM_ADDR_WIDTH+1:2];
endmodule
