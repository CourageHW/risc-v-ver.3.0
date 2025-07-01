`timescale 1ns / 1ps 

import core_pkg::*;

module program_counter (
  input  logic clk,
  input  logic rst_n,
  pc_if.SLAVE pc_bus
);

  always_ff @(posedge clk) begin
    if (!rst_n) begin
      pc_bus.pc_o <= '0;
    end else if (pc_bus.pc_we) begin
      pc_bus.pc_o <= pc_bus.pc_i;
    end
  end
endmodule
