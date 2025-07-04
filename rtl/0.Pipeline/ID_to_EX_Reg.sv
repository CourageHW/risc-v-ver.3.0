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
      bus_out.data.ALUSrcA  <= 1'b0;
      bus_out.data.ALUSrcB  <= 1'b0;
      bus_out.data.ALUOp    <= ALUOP_NONE;
      bus_out.data.Branch   <= 1'b0;
      bus_out.data.Jump     <= 1'b0;
      bus_out.data.MemWrite <= 1'b0;
      bus_out.data.MemRead  <= 1'b0;
      bus_out.data.RegWrite <= 1'b0;
      bus_out.data.WBSel    <= WB_NONE;
      bus_out.data.instruction <= 32'h00000013; // addi x0, x0, 0 (NOP)
      bus_out.data.immediate   <= '0;
      bus_out.data.rd_data1    <= '0;
      bus_out.data.rd_data2    <= '0;
      bus_out.data.rd_addr     <= '0;
      bus_out.data.pc          <= '0;
      bus_out.data.pc_plus4    <= '0;
    end else if (!stall_i) begin
      bus_out.data <= bus_in.data;
    end
  end

endmodule
