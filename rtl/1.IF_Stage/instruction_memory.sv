`timescale 1ns / 1ps 

import core_pkg::*;

module instruction_memory (
  input logic [INST_MEM_ADDR_WIDTH-1:0] addr_i,
  output logic [DATA_WIDTH-1:0] instruction_o
);
  
  (* ram_style = "block" *)
  logic [DATA_WIDTH-1:0] instruction_memory [0:INST_MEM_DEPTH-1];
  
  initial begin
    $readmemh("program.mem", instruction_memory);
  end
  
  assign instruction_o = instruction_memory[addr_i];
endmodule
