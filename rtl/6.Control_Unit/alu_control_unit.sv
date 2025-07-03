`timescale 1ns / 1ps

import core_pkg::*;

module alu_control_unit (
  input  alu_op_e  ALUOp_i,
  input  logic [2:0] funct3_i,
  input  logic       funct7_i, // Corresponds to instruction[30]
  output alu_sel_e ALUSel_o
);

  // Combinational logic to determine the ALU operation
  always_comb begin
    // Default to ALU_X to easily catch undefined behavior during simulation
    ALUSel_o = ALU_X;

    unique case (ALUOp_i)
      // Direct ALU operations determined by the main control unit
      ALUOP_ADD:    ALUSel_o = ALU_ADD;    // For lw, sw, addi, auipc, jal, jalr
      ALUOP_SUB:    ALUSel_o = ALU_SUB;    // For branch instructions
      ALUOP_PASS_B: ALUSel_o = ALU_PASS_B; // For lui

      // For I-type instructions where the operation is determined by funct3.
      ALUOP_FUNCT3: begin
        unique case (funct3_i)
          FUNCT3_I_ADDI:  ALUSel_o = ALU_ADD;
          FUNCT3_I_SLTI:  ALUSel_o = ALU_SLT;
          FUNCT3_I_SLTIU: ALUSel_o = ALU_SLTU;
          FUNCT3_I_XORI:  ALUSel_o = ALU_XOR;
          FUNCT3_I_ORI:   ALUSel_o = ALU_OR;
          FUNCT3_I_ANDI:  ALUSel_o = ALU_AND;
          FUNCT3_I_SLLI:  ALUSel_o = ALU_SLL;
          // Note: SRLI/SRAI are handled under ALUOP_FUNCT7 as they need funct7
          default:        ALUSel_o = ALU_X;
        endcase
      end

      // For R-type instructions and I-type shifts (SRLI/SRAI)
      // where both funct3 and funct7[5] (funct7_i) are required for decoding
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

      // Default case for ALUOp_i to prevent latches
      default: ALUSel_o = ALU_X;
    endcase
  end

endmodule
