`timescale 1ns / 1ps 

import core_pkg::*;

module instruction_memory (
  inst_if.SLAVE inst_bus
);

  logic [INST_WIDTH-1:0] instruction_memory [0:INST_MEM_DEPTH-1];
  // initial begin
  //   $readmemh("program.mem", instruction_memory);
  // end
  
  assign inst_bus.instruction_o = instruction_memory[inst_bus.addr_i];
endmodule
