`timescale 1ns / 1ps

import core_pkg::*;

module immediate_generator (
  input logic [DATA_WIDTH-1:0] instruction_i,
  input imm_sel_e ImmSel_i,
  output logic [DATA_WIDTH-1:0] immediate_o
  );


  always_comb begin
    unique case (ImmSel_i)
      IMM_ITYPE: immediate_o = { {20{instruction_i[31]}}, instruction_i[31:20] };
      IMM_STYPE: immediate_o = { {20{instruction_i[31]}}, instruction_i[31:25], instruction_i[11:7] };
      IMM_BTYPE: immediate_o = { {19{instruction_i[31]}}, instruction_i[31], instruction_i[7], instruction_i[30:25], instruction_i[11:8], 1'b0 };
      IMM_UTYPE: immediate_o = { instruction_i[31:12], 12'b0};
      IMM_JTYPE: immediate_o = { {12{instruction_i[31]}}, instruction_i[19:12], instruction_i[20], instruction_i[30:21], 1'b0 };
      default  : immediate_o = '0;
    endcase
  end

endmodule
