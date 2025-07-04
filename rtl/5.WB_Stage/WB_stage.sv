`timescale 1ns / 1ps 

import core_pkg::*;

module WB_stage (
  MEM2WB_if.SLAVE bus_in,

  output logic [DATA_WIDTH-1:0] wb_data_o,
  output logic [DATA_WIDTH-1:0] instruction_o,
  output logic [REG_ADDR_WIDTH-1:0] rd_addr_o,
  output logic RegWrite_o
);

  always_comb begin
     unique case (bus_in.data.WBSel)
       WB_ALU: wb_data_o = bus_in.data.alu_result;
       WB_MEM: wb_data_o = bus_in.data.rd_data;
       WB_PC4: wb_data_o = bus_in.data.pc_plus4;
       default: wb_data_o = '0;
     endcase
  end

  assign instruction_o = bus_in.data.instruction;
  assign rd_addr_o     = bus_in.data.rd_addr;
  assign RegWrite_o    = bus_in.data.RegWrite;
endmodule
