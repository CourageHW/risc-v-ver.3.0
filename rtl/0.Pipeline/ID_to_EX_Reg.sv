`timescale 1ns / 1ps 

import core_pkg::*;

module ID_to_EX_Reg (
  input logic clk,
  input logic rst_n,
  input logic flush_i,
  input logic stall_i,
  ID2EX_if.SLAVE  bus_in,
  ID2EX_if.MASTER bus_out
);

  always_ff @(posedge clk) begin
    if (!rst_n) begin
      bus_out.data <= '0;
    end else if (flush_i) begin
      bus_out.data <= '0;
    end else if (!stall_i) begin
      bus_out.data <= bus_in.data;
    end
  end

endmodule
