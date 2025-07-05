`timescale 1ns / 1ps

import core_pkg::*;

module hazard_detection_unit (
  input logic clk,
  input logic rst_n,
  input logic [REG_ADDR_WIDTH-1:0] rs1_addr_ID_i,
  input logic [REG_ADDR_WIDTH-1:0] rs2_addr_ID_i,
  input logic [REG_ADDR_WIDTH-1:0] rd_addr_EX_i,
  input wb_sel_e WBSel_EX_i,
  output logic stall_o
);

  logic stall_detector;
  logic [1:0] stall_counter;

  always_comb begin
    if (WBSel_EX_i == WB_MEM && rd_addr_EX_i != '0 && (rd_addr_EX_i == rs1_addr_ID_i || rd_addr_EX_i == rs2_addr_ID_i)) begin
      stall_detector = 1'b1;
    end else begin
      stall_detector = 1'b0;
    end
  end

  always_ff @(posedge clk) begin
    if (!rst_n) begin
      stall_counter <= 2'b00;
    end else if (stall_detector && stall_counter == 2'b00) begin
      stall_counter <= 2'b01;
    end else if (stall_counter > 2'b00) begin
      stall_counter <= stall_counter - 2'b01;
    end
  end

  assign stall_o = (stall_counter > 2'b00);

endmodule
