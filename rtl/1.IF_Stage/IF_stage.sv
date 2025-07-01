`timescale 1ns / 1ps

import core_pkg::*;

module IF_stage (
  input logic clk,
  input logic rst_n,
  input logic pc_we,
  output logic [DATA_WIDTH-1:0] inst_o
);

  inst_if inst_bus();
  pc_if pc_bus();

  program_counter pc_inst (
    .clk(clk),
    .rst_n(rst_n),
    .pc_bus(pc_bus.SLAVE)
  );

  
  instruction_memory inst_mem_inst (
    .inst_bus(inst_bus.SLAVE)
  );

  assign pc_bus.pc_i = pc_bus.pc_o + 4; // 조건 추가 예정
  assign pc_bus.pc_we = pc_we;
 
  assign inst_bus.addr_i = pc_bus.pc_o[INST_MEM_ADDR_WIDTH+1:2];
  assign inst_o = inst_bus.instruction_o;
endmodule
