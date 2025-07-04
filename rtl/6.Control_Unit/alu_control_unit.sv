`timescale 1ns / 1ps

import core_pkg::*;

module alu_control_unit (
  input  alu_op_e  ALUOp_i,
  input  logic [2:0] funct3_i,
  input  logic       funct7_i,
  output alu_sel_e ALUSel_o
);

  always_comb begin
    ALUSel_o = ALU_X;

    unique case (ALUOp_i)
      ALUOP_ADD:    ALUSel_o = ALU_ADD;    // For lw, sw, addi, auipc, jal, jalr
      ALUOP_SUB:    ALUSel_o = ALU_SUB;    // For branch instructions
      ALUOP_PASS_B: ALUSel_o = ALU_PASS_B; // For lui

      ALUOP_FUNCT3: begin
        unique case (funct3_i)
          FUNCT3_I_ADDI:  ALUSel_o = ALU_ADD;
          FUNCT3_I_SLTI:  ALUSel_o = ALU_SLT;
          FUNCT3_I_SLTIU: ALUSel_o = ALU_SLTU;
          FUNCT3_I_XORI:  ALUSel_o = ALU_XOR;
          FUNCT3_I_ORI:   ALUSel_o = ALU_OR;
          FUNCT3_I_ANDI:  ALUSel_o = ALU_AND;
          FUNCT3_I_SLLI:  ALUSel_o = ALU_SLL;
          default:        ALUSel_o = ALU_X;
        endcase
      end

      ALUOP_FUNCT7: begin
        unique case (funct3_i)
          FUNCT3_R_ADD_SUB: begin
            if (funct7_i == 1'b0)
              ALUSel_o = ALU_ADD; // ADD
            else
              ALUSel_o = ALU_SUB; // SUB
          end
          FUNCT3_R_SLL:     ALUSel_o = ALU_SLL;  // SLL
          FUNCT3_R_SLT:     ALUSel_o = ALU_SLT;  // SLT
          FUNCT3_R_SLTU:    ALUSel_o = ALU_SLTU; // SLTU
          FUNCT3_R_XOR:     ALUSel_o = ALU_XOR;  // XOR
          FUNCT3_R_OR:      ALUSel_o = ALU_OR;   // OR
          FUNCT3_R_AND:     ALUSel_o = ALU_AND;  // AND
          FUNCT3_R_SHIFT_R: begin
            if (funct7_i == 1'b0)
              ALUSel_o = ALU_SRL; // SRL or SRLI
            else
              ALUSel_o = ALU_SRA; // SRA or SRAI
          end
          default:          ALUSel_o = ALU_X;
        endcase
      end

      default: ALUSel_o = ALU_X;
    endcase
  end

endmodule
