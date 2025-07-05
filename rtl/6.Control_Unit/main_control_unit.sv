`timescale 1ns / 1ps

import core_pkg::*;

module main_control_unit (
  input logic [6:0] opcode_i,
  input logic [2:0] funct3_i,

  // Immediate Generator
  output imm_sel_e ImmSel_o,

  // ALU
  output logic ALUSrcA_o,
  output logic ALUSrcB_o,

  output logic Branch_o,
  output logic Jump_o,

  // Data Memory
  output logic MemWrite_o,
  output logic MemRead_o,

  // Writeback
  output logic RegWrite_o,
  output wb_sel_e WBSel_o
);


  always_comb begin
    // Default values
    ImmSel_o   = IMM_RTYPE;
    WBSel_o    = WB_NONE;
    ALUSrcA_o  = 1'b0;
    ALUSrcB_o  = 1'b0;
    Branch_o   = 1'b0;
    Jump_o     = 1'b0;
    MemWrite_o = 1'b0;
    MemRead_o  = 1'b0;
    RegWrite_o = 1'b0;

    unique case (opcode_i)
      OPCODE_R: begin
        WBSel_o    = WB_ALU;
        RegWrite_o = 1'b1;
      end

      OPCODE_I: begin
        // Default for I-type is standard sign-extended immediate
        ImmSel_o   = IMM_ITYPE;
        WBSel_o    = WB_ALU;
        ALUSrcB_o  = 1'b1;
        RegWrite_o = 1'b1;

        // Special case for logical immediates (zero-extended)
        unique case (funct3_i)
          FUNCT3_I_XORI,
          FUNCT3_I_ORI,
          FUNCT3_I_ANDI: ImmSel_o = IMM_LOGICAL;
          default: ImmSel_o = IMM_ITYPE;
        endcase
      end

      OPCODE_LOAD: begin
        ImmSel_o   = IMM_ITYPE;
        WBSel_o    = WB_MEM;
        ALUSrcB_o  = 1'b1;
        MemRead_o  = 1'b1;
        RegWrite_o = 1'b1;
      end

      OPCODE_STORE: begin
        ImmSel_o   = IMM_STYPE;
        ALUSrcB_o  = 1'b1;
        MemWrite_o = 1'b1;
      end

      OPCODE_BRANCH: begin
        ImmSel_o   = IMM_BTYPE;
        Branch_o   = 1'b1;
      end

      OPCODE_JAL: begin
        ImmSel_o   = IMM_JTYPE;
        WBSel_o    = WB_PC4;
        Jump_o     = 1'b1;
        RegWrite_o = 1'b1;
      end

      OPCODE_JALR: begin
        ImmSel_o   = IMM_ITYPE;
        WBSel_o    = WB_PC4;
        ALUSrcB_o  = 1'b1;
        Jump_o     = 1'b1;
        RegWrite_o = 1'b1;
      end

      OPCODE_LUI: begin
        ImmSel_o   = IMM_UTYPE;
        WBSel_o    = WB_ALU;
        ALUSrcB_o  = 1'b1;
        RegWrite_o = 1'b1;
      end

      OPCODE_AUIPC: begin
        ImmSel_o   = IMM_UTYPE;
        WBSel_o    = WB_ALU;
        ALUSrcA_o  = 1'b1;
        ALUSrcB_o  = 1'b1;
        RegWrite_o = 1'b1;
      end
      default:;
    endcase
  end
endmodule