`timescale 1ns / 1ps 

import core_pkg::*;

interface MEM2WB_if;


  mem_wb_data_t data;

  modport MASTER (
    output data
  );

  modport SLAVE(
    input data
  );
endinterface
