`timescale 1ns / 1ps 

import core_pkg::*;

interface EX2MEM_if;


  ex_mem_data_t data;

  modport MASTER (
    output data
  );

  modport SLAVE(
    input data
  );
endinterface
