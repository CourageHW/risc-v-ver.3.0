`timescale 1ns / 1ps  

import core_pkg::*;

module IF_to_ID_Reg (
  input logic clk,
  input logic rst_n,
  
  input logic [DATA_WIDT0-1:0] IF_instructio_i,
  input logic [DATA_WIDTH-1:0] IF_pc_i,
  input logic [DATA_WIDTH-1:0] IF_pc_plus4_i,

  IF2ID_if.MASTER bus_out
  );

  always_ff@(posedge clk) begin
    if (!rst_n) begin
      bus_out.instruction <= '0;
      bus_out.pc          <= '0;
      bus_out.pc_plus4    <= '0;
    end else begin
      bus_out.instruction <= IF_instruction_i;
      bus_out.pc          <= IF_pc_i;
      bus_out.pc_plus4    <= IF_pc_plus4_i;
    end
  end

endmodule
