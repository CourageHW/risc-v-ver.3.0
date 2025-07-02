`timescale 1ns / 1ps

import core_pkg::*;

interface IF2ID_if;

  logic [DATA_WIDTH-1:0] instruction;
  logic [DATA_WIDTH-1:0] pc;
  logic [DATA_WIDTH-1:0] pc_plus4;

  modport SLAVE (
    input instruction,
    input pc,
    input pc_plus4
  );

  modport MASTER (
    output instruction,
    output pc,
    output pc_plus4
  );
endinterface
