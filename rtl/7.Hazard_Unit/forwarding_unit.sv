`timescale 1ns / 1ps

import core_pkg::*;

module forwarding_unit (
  input logic RegWrite_MEM_i,
  input logic RegWrite_WB_i,

  input logic [REG_ADDR_WIDTH-1:0] rd_addr_MEM_i,
  input logic [REG_ADDR_WIDTH-1:0] rd_addr_WB_i,

  input logic [REG_ADDR_WIDTH-1:0] rs1_addr_EX_i,
  input logic [REG_ADDR_WIDTH-1:0] rs2_addr_EX_i,

  output fw_sel_e forwardA,
  output fw_sel_e forwardB
);

  always_comb begin
    forwardA = FW_NONE;
    forwardB = FW_NONE;

    if (RegWrite_MEM_i && rd_addr_MEM_i != '0 && rd_addr_MEM_i == rs1_addr_EX_i) begin
      forwardA = FW_MEM_ALU;
    end else if (RegWrite_WB_i && rd_addr_WB_i != '0 && rd_addr_WB_i == rs1_addr_EX_i) begin
      forwardA = FW_WB_DATA;
    end

    if (RegWrite_MEM_i && rd_addr_MEM_i != '0 && rd_addr_MEM_i == rs2_addr_EX_i) begin
      forwardB = FW_MEM_ALU;
    end else if (RegWrite_WB_i && rd_addr_WB_i != '0 && rd_addr_WB_i == rs2_addr_EX_i) begin
      forwardB = FW_WB_DATA;
    end
  end
endmodule
