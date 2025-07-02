`timescale 1ns / 1ps

import core_pkg::*;

interface IF2ID_if;

  typedef struct packed {
    logic [DATA_WIDTH-1:0] instruction;
    logic [DATA_WIDTH-1:0] pc;
    logic [DATA_WIDTH-1:0] pc_plus4;
  } data_t;

  data_t data;

  modport SLAVE (
    input data
  );

  modport MASTER (
    output data
  );
endinterface
