`timescale 1ns / 1ps

import core_pkg::*;

module EX_to_MEM_Reg (
  input logic clk,
  input logic rst_n,

  EX2MEM_if.SLAVE  bus_in,
  EX2MEM_if.MASTER bus_out
);

  always_ff @(posedge clk) begin
    if (!rst_n) begin
      bus_out.data <= '0;
    end else begin
      bus_out.data <= bus_in.data;
    end
  end

endmodule
