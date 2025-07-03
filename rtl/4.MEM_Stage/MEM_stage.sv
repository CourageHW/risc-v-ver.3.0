`timescale 1ns / 1ps

import core_pkg::*;

module MEM_stage (
  input logic clk,
  EX2MEM_if.SLAVE bus_in,
  MEM2WB_if.MASTER bus_out
);

  mem_wb_data_t mem_wb_data_w;

  data_memory data_mem_inst (
    .clk(clk),
    .mem_addr_i(bus_in.data.alu_result),
    .wr_data_i(bus_in.data.rd_data2),
    .MemWrite_i(bus_in.data.MemWrite),
    .MemRead_i(bus_in.data.MemRead),
    .rd_data_o(mem_wb_data_w.rd_data)
  );

  assign mem_wb_data_w.instruction = bus_in.data.instruction;
  assign mem_wb_data_w.pc_plus4    = bus_in.data.pc_plus4;
  assign mem_wb_data_w.alu_result  = bus_in.data.alu_result;
  assign mem_wb_data_w.rd_addr     = bus_in.data.rd_addr;
  assign mem_wb_data_w.RegWrite    = bus_in.data.RegWrite;
  assign mem_wb_data_w.WBSel       = bus_in.data.WBSel;

  assign bus_out.data = mem_wb_data_w;
endmodule
