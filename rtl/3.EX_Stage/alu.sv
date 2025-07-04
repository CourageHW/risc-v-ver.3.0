`timescale 1ns / 1ps

import core_pkg::*;

module alu (
  input  logic [DATA_WIDTH-1:0] operand1_i,
  input  logic [DATA_WIDTH-1:0] operand2_i,
  input  alu_sel_e              ALUSel_i,
  output logic [DATA_WIDTH-1:0] alu_result_o
);

  always_comb begin
    unique case (ALUSel_i)
      ALU_ADD    : alu_result_o = operand1_i + operand2_i;
      ALU_SUB    : alu_result_o = operand1_i - operand2_i;
      ALU_XOR    : alu_result_o = operand1_i ^ operand2_i;
      ALU_OR     : alu_result_o = operand1_i | operand2_i;
      ALU_AND    : alu_result_o = operand1_i & operand2_i;
      ALU_SLL    : alu_result_o = operand1_i << operand2_i[4:0];
      ALU_SRL    : alu_result_o = operand1_i >> operand2_i[4:0];
      ALU_SRA    : alu_result_o = $signed(operand1_i) >>> operand2_i[4:0];
      ALU_SLT    : alu_result_o = ($signed(operand1_i) < $signed(operand2_i)) ? 32'd1 : 32'd0;
      ALU_SLTU   : alu_result_o = (operand1_i < operand2_i) ? 32'd1 : 32'd0;
      ALU_PASS_B : alu_result_o = operand2_i;
      default    : alu_result_o = '0;
    endcase
  end
endmodule
