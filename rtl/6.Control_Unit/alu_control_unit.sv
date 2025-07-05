`timescale 1ns / 1ps

import core_pkg::*;

module alu_control_unit (
  input logic [6:0] opcode_i,
  input logic [2:0] funct3_i,
  input logic       funct7_i,
  output alu_sel_e ALUSel_o
);

  always_comb begin
    ALUSel_o = ALU_X; // Default value

    unique case (opcode_i)
      OPCODE_R: begin // R-Type
        unique case (funct3_i)
          FUNCT3_R_ADD_SUB: ALUSel_o = funct7_i ? ALU_SUB : ALU_ADD;
          FUNCT3_R_SLL:     ALUSel_o = ALU_SLL;
          FUNCT3_R_SLT:     ALUSel_o = ALU_SLT;
          FUNCT3_R_SLTU:    ALUSel_o = ALU_SLTU;
          FUNCT3_R_XOR:     ALUSel_o = ALU_XOR;
          FUNCT3_R_SHIFT_R: ALUSel_o = funct7_i ? ALU_SRA : ALU_SRL;
          FUNCT3_R_OR:      ALUSel_o = ALU_OR;
          FUNCT3_R_AND:     ALUSel_o = ALU_AND;
          default:        ALUSel_o = ALU_X;
        endcase
      end

      OPCODE_I: begin // I-Type (ALU immediate)
        unique case (funct3_i)
          FUNCT3_I_ADDI:    ALUSel_o = ALU_ADD;
          FUNCT3_I_SLTI:    ALUSel_o = ALU_SLT;
          FUNCT3_I_SLTIU:   ALUSel_o = ALU_SLTU;
          FUNCT3_I_XORI:    ALUSel_o = ALU_XOR;
          FUNCT3_I_ORI:     ALUSel_o = ALU_OR;
          FUNCT3_I_ANDI:    ALUSel_o = ALU_AND;
          FUNCT3_I_SLLI:    ALUSel_o = ALU_SLL;
          FUNCT3_I_SHIFT_R: ALUSel_o = funct7_i ? ALU_SRA : ALU_SRL;
          default:          ALUSel_o = ALU_X;
        endcase
      end

      OPCODE_BRANCH: begin // B-Type
        unique case (funct3_i)
          FUNCT3_BRANCH_EQ:  ALUSel_o = ALU_SUB;
          FUNCT3_BRANCH_NE:  ALUSel_o = ALU_SUB;
          FUNCT3_BRANCH_LT:  ALUSel_o = ALU_SLT;
          FUNCT3_BRANCH_GE:  ALUSel_o = ALU_SLT;
          FUNCT3_BRANCH_LTU: ALUSel_o = ALU_SLTU;
          FUNCT3_BRANCH_GEU: ALUSel_o = ALU_SLTU;
          default:           ALUSel_o = ALU_X;
        endcase
      end

      // Other opcodes that use ALU
      OPCODE_LOAD:  ALUSel_o = ALU_ADD;
      OPCODE_STORE: ALUSel_o = ALU_ADD;
      OPCODE_JALR:  ALUSel_o = ALU_ADD;
      OPCODE_LUI:   ALUSel_o = ALU_PASS_B;
      OPCODE_AUIPC: ALUSel_o = ALU_ADD;
      OPCODE_JAL:   ALUSel_o = ALU_ADD;

      default: ALUSel_o = ALU_X;
    endcase
  end

endmodule