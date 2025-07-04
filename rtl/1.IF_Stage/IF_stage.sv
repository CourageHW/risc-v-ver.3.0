`timescale 1ns / 1ps

import core_pkg::*;

module IF_stage (
  input logic clk,
  input logic rst_n,
  input logic pc_we,
  IF2ID_if.MASTER bus_out
);
  
  logic [INST_MEM_ADDR_WIDTH-1:0] addr_w;

  if_id_data_t if_id_data_w;

  program_counter pc_inst (
    .clk(clk),
    .rst_n(rst_n),
    .pc_we(pc_we),
    .pc_i(if_id_data_w.pc + 32'd4), // pc_i에 직접 다음 PC 값 연결
    .pc_o(if_id_data_w.pc)
  );

  
  instruction_memory inst_mem_inst (
    .addr_i(addr_w),
    .instruction_o(if_id_data_w.instruction)
  );

  assign addr_w                = if_id_data_w.pc[INST_MEM_ADDR_WIDTH+1:2];
  assign if_id_data_w.pc_plus4 = if_id_data_w.pc + 32'd4;
  
  assign bus_out.data          = if_id_data_w;
endmodule
