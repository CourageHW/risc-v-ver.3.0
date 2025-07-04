`timescale 1ns / 1ps

import core_pkg::*;

module branch_determination (
  input logic BrEQ_i,
  input logic BrLT_i,
  input logic BrLTU_i,
  input logic Branch_i,
  input logic [2:0] funct3_i,

  output logic BranchTaken_o
  );

  logic BrSel_w;

  always_comb begin
    unique case (funct3_i)
      FUNCT3_BRANCH_EQ : BrSel_w = BrEQ_i;
      FUNCT3_BRANCH_NE : BrSel_w = ~BrEQ_i;
      FUNCT3_BRANCH_LT : BrSel_w = BrLT_i;
      FUNCT3_BRANCH_GE : BrSel_w = ~BrLT_i;
      FUNCT3_BRANCH_LTU: BrSel_w = BrLTU_i;
      FUNCT3_BRANCH_GEU: BrSel_w = ~BrLTU_i;
      default : BrSel_w = 0;
    endcase
  end

  assign BranchTaken_o = (Branch_i & BrSel_w);

endmodule
