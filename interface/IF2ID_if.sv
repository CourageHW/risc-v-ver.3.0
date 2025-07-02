`timescale 1ns / 1ps

import core_pkg::*;

interface IF2ID_if;


  if_id_data_t data;

  modport SLAVE (
    input data
  );

  modport MASTER (
    output data
  );
endinterface
