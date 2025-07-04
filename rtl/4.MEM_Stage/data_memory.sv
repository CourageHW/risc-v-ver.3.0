`timescale 1ns / 1ps 

import core_pkg::*;

module data_memory (
  input logic clk,
  input logic [DATA_WIDTH-1:0] mem_addr_i,
  input logic [DATA_WIDTH-1:0] wr_data_i,
  input logic MemWrite_i,
  input logic MemRead_i,
  output logic [DATA_WIDTH-1:0] rd_data_o
);
  
  logic [DATA_WIDTH-1:0] data_memory [0:DATA_MEM_DEPTH-1];

  assign rd_data_o = data_memory[mem_addr_i[DATA_MEM_ADDR_WIDTH+1:2]];

  always_ff @(posedge clk) begin
    if (MemWrite_i) begin
      data_memory[mem_addr_i[DATA_MEM_ADDR_WIDTH+1:2]] <= wr_data_i;
    end
  end

endmodule
