`timescale 1ns / 1ps

import core_pkg::*;

module MEM_to_WB_Reg (
  input logic clk,
  input logic rst_n,
  MEM2WB_if.SLAVE bus_in,
  MEM2WB_if.MASTER bus_out
);

  always_ff @(posedge clk) begin
    if (!rst_n) begin
      bus_out.data <= '0;
    end else begin
      bus_out.data <= bus_in.data;
    end
  end
endmodule
