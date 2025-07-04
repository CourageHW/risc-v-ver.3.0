`timescale 1ns / 1ps

import core_pkg::*;

module branch_comparator (
  input logic [DATA_WIDTH-1:0] operand1_i,
  input logic [DATA_WIDTH-1:0] operand2_i,
  output logic BrEQ_o,
  output logic BrLT_o,
  output logic BrLTU_o
);

  always_comb begin
    BrEQ_o  = (operand1_i == operand2_i);
    BrLT_o  = ($signed(operand1_i) < $signed(operand2_i));
    BrLTU_o = (operand1_i < operand2_i);
  end
endmodule
