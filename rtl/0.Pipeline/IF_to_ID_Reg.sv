`timescale 1ns / 1ps  

import core_pkg::*;

module IF_to_ID_Reg (
  input logic clk,
  input logic rst_n,
  input logic flush_i,
  input logic stall_i,
  IF2ID_if.SLAVE bus_in,
  IF2ID_if.MASTER bus_out
  );

  always_ff @(posedge clk) begin
    if (!rst_n) begin
      bus_out.data <= '0;
    end else if (flush_i) begin
      bus_out.data.instruction <= 32'h00000013; // addi x0, x0, 0
      bus_out.data.pc <= '0;
      bus_out.data.pc_plus4 <= '0;
    end else if (!stall_i) begin
      bus_out.data <= bus_in.data;
    end
  end

endmodule
