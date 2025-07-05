`timescale 1ns / 1ps

import core_pkg::*;

module top (
  input logic clk,
  input logic rst_n,
  output logic [3:0] led
);
  
  logic [26:0] clk_counter;
  logic [INST_MEM_ADDR_WIDTH-1:0] inst_addr_o;

  riscv_core riscv_core_inst (
    .clk(clk),
    .rst_n(rst_n),
    .inst_addr_o(inst_addr_o)
  );

  always_ff @(posedge clk) begin
    if (!rst_n) begin
      clk_counter <= '0;
    end else begin
      clk_counter <= clk_counter + 1;
    end
  end

  assign led[0] = clk_counter[26];
  assign led[1] = inst_addr_o[1];

endmodule
