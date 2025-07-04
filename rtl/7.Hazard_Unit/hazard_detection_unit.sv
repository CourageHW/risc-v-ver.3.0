`timescale 1ns / 1ps

import core_pkg::*;

module hazard_detection_unit (
  input logic [REG_ADDR_WIDTH-1:0] rs1_addr_ID_i,
  input logic [REG_ADDR_WIDTH-1:0] rs2_addr_ID_i,
  input logic [REG_ADDR_WIDTH-1:0] rd_addr_EX_i,
  input logic MemRead_EX_i,
  output logic stall_o
);

  always_comb begin
    if (MemRead_EX_i && rd_addr_EX_i != '0 && (rd_addr_EX_i == rs1_addr_ID_i || rd_addr_EX_i == rs2_addr_ID_i)) begin
      stall_o = 1'b1;
    end else begin
      stall_o = 1'b0;
    end
  end

endmodule
