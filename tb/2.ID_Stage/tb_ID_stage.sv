`timescale 1ns / 1ps

import core_pkg::*;

module tb_ID_stage;

  localparam CLK_PERIOD = 10;
  
  logic clk;
  logic [DATA_WIDTH-1:0] instruction_i;
  logic WB_RegWrite_i;
  logic [REG_ADDR_WIDTH-1:0] wr_addr_i;
  logic [DATA_WIDTH-1:0] wr_data_i;

  logic [DATA_WIDTH-1:0] immediate_o;
  logic [DATA_WIDTH-1:0] rd_data1_o;
  logic [DATA_WIDTH-1:0] rd_data2_o;
                                      
  logic ALUSrcA_o;
  logic ALUSrcB_o;
  alu_op_e ALUOp_o;
  logic Branch_o;
  logic Jump_o;
  logic MemWrite_o;
  logic MemRead_o;
  logic RegWrite_o;
  wb_sel_e WBSel_o;

  ID_stage dut (
    .clk(clk),
    .instruction_i(instruction_i),
    .WB_RegWrite_i(WB_RegWrite_i),
    .wr_addr_i(wr_addr_i),
    .wr_data_i(wr_data_i),
    .immediate_o(immediate_o),
    .rd_data1_o(rd_data1_o),
    .rd_data2_o(rd_data2_o),
    .ALUSrcA_o(ALUSrcA_o),
    .ALUSrcB_o(ALUSrcB_o),
    .ALUOp_o(ALUOp_o),
    .Branch_o(Branch_o),
    .Jump_o(Jump_o),
    .MemWrite_o(MemWrite_o),
    .MemRead_o(MemRead_o),
    .RegWrite_o(RegWrite_o),
    .WBSel_o(WBSel_o)
  );

  initial begin
    clk = 0;
    forever #(CLK_PERIOD/2) clk = ~clk;
  end

  initial begin
    initialize_ports();
  end

  task initialize_ports();
    instruction_i = '0;
    WB_RegWrite_i = 0;
    wr_addr_i = '0;
    wr_data_i = '0;
  endtask



endmodule
