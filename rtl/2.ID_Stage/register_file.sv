`timescale 1ns / 1ps

import core_pkg::*;

module register_file (
  input  logic clk,
  // read
  input  logic [REG_ADDR_WIDTH-1:0] rs1_addr_i,
  input  logic [REG_ADDR_WIDTH-1:0] rs2_addr_i,

  // write
  input  logic [REG_ADDR_WIDTH-1:0] wr_addr_i,
  input  logic [DATA_WIDTH-1:0] wr_data_i,
  input  logic WB_RegWrite_i,

  output logic [DATA_WIDTH-1:0] rd_data1_o,
  output logic [DATA_WIDTH-1:0] rd_data2_o
);

  logic [DATA_WIDTH-1:0] registers [0:NUM_REGS-1];

  always_comb begin
    if (WB_RegWrite_i && wr_addr_i != '0 && wr_addr_i == rs1_addr_i) begin
      rd_data1_o = wr_data_i;
    end else begin
      rd_data1_o = (rs1_addr_i == '0) ? '0 : registers[rs1_addr_i];
    end

    if (WB_RegWrite_i && wr_addr_i != '0 && wr_addr_i == rs2_addr_i) begin
      rd_data2_o = wr_data_i;
    end else begin
      rd_data2_o = (rs2_addr_i == '0) ? '0 : registers[rs2_addr_i];
    end
  end

  // Write
  always_ff @(posedge clk) begin
    if (WB_RegWrite_i && wr_addr_i != '0) begin
      registers[wr_addr_i] <= wr_data_i;
    end
  end
endmodule
