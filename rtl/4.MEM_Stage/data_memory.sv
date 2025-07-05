`timescale 1ns / 1ps 

import core_pkg::*;

module data_memory (
  input logic clk,
  input logic [DATA_WIDTH-1:0] mem_addr_i,
  input logic [DATA_WIDTH-1:0] wr_data_i,
  input logic [2:0] funct3_i,
  input logic MemWrite_i,
  input logic MemRead_i,
  output logic [DATA_WIDTH-1:0] rd_data_o
);
  
  (* ram_style = "block" *)
  logic [DATA_WIDTH-1:0] data_memory [0:DATA_MEM_DEPTH-1];
  logic [DATA_MEM_ADDR_WIDTH-1:0] word_addr_w;

  assign word_addr_w = mem_addr_i[DATA_MEM_ADDR_WIDTH+1:2];
  assign rd_data_o = data_memory[word_addr_w];

  always_ff @(posedge clk) begin
    if (MemWrite_i) begin
      unique case (funct3_i)
        FUNCT3_STORE_BYTE: begin
          unique case (mem_addr_i[1:0])
            2'b00: data_memory[word_addr_w][7:0]   <= wr_data_i[7:0];
            2'b01: data_memory[word_addr_w][15:8]  <= wr_data_i[7:0];
            2'b10: data_memory[word_addr_w][23:16] <= wr_data_i[7:0];
            2'b11: data_memory[word_addr_w][31:24] <= wr_data_i[7:0];
          endcase
        end

        FUNCT3_STORE_HALF: begin
          if (mem_addr_i[1] == 1'b0) begin
            data_memory[word_addr_w][15:0]  <= wr_data_i[15:0];
          end else begin
            data_memory[word_addr_w][31:16] <= wr_data_i[15:0];
          end
        end

        FUNCT3_STORE_WORD: data_memory[word_addr_w] <= wr_data_i;

        default:data_memory[word_addr_w] <= '0;
      endcase
    end
  end

endmodule
