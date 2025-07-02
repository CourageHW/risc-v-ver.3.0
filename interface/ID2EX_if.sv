`timescale 1ns / 1ps 

import core_pkg::*;

interface ID2EX_if;

  typedef struct packed {
    logic [DATA_WIDTH-1:0] immediate;
    logic [DATA_WIDTH-1:0] rd_data1;
    logic [DATA_WIDTH-1:0] rd_data2;
    logic [REG_ADDR_WIDTH-1:0] rd_addr;
    logic [DATA_WIDTH-1:0] pc;
    logic [DATA_WIDTH-1:0] pc_plus4;

    logic ALUSrcA;
    logic ALUSrcB;
    alu_op_e ALUOp;
    logic Branch;
    logic Jump;
    logic MemWrite;
    logic MemRead;
    logic RegWrite;
    wb_sel_e WBSel;
  } data_t;

  data_t data;

  modport MASTER (
    output data
  );

  modport SLAVE(
    input data
  );
endinterface
