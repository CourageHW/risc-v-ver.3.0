`timescale 1ns / 1ps 

import core_pkg::*;

interface ID2EX_if;


  id_ex_data_t data;

  modport MASTER (
    output data
  );

  modport SLAVE(
    input data
  );
endinterface
