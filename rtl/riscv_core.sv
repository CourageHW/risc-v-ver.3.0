`timescale 1ns / 1ps

import core_pkg::*;

module riscv_core (
  input logic clk,
  input logic rst_n,
  input logic [DATA_WIDTH-1:0] pc_i,
  IF2ID_if.MASTER bus_out
);

  // ===================================
  //             Interface
  // ===================================
  IF2ID_if if_stage_out_bus(); // IF -> REG
  IF2ID_if id_stage_in_bus();  // REG -> ID
  ID2EX_if id_stage_out_bus(); // ID -> REG
  ID2EX_if ex_stage_in_bus();  // REG -> EX


  // ===================================
  //               Wire
  // ===================================
  logic WB_RegWrite_w;
  logic [REG_ADDR_WIDTH-1:0] WB_wr_addr_w;
  logic [DATA_WIDTH-1:0] WB_wr_data_w;


  // ===================================
  //              Module
  // ===================================
  IF_stage IF_inst (
    .clk(clk),
    .rst_n(rst_n),
    .pc_we(1'b1), // 임시
    .pc_i(pc_i),  // 임시
    .bus_out(if_stage_out_bus.MASTER)
  );

  IF_to_ID_Reg IF2ID_inst (
    .clk(clk),
    .rst_n(rst_n),
    .bus_in(if_stage_out_bus.SLAVE),
    .bus_out(id_stage_in_bus.MASTER)
  );

  ID_stage ID_inst (
    .clk(clk),
    .bus_in(id_stage_in_bus.SLAVE),
    .WB_RegWrite_i(WB_RegWrite_w),
    .wr_addr_i(WB_wr_addr_w),
    .wr_data_i(WB_wr_data_w),
    .bus_out(id_stage_out_bus.MASTER)
  );

  ID_to_EX_Reg ID2EX_inst (
    .clk(clk),
    .rst_n(rst_n),
    .bus_in(id_stage_out_bus.SLAVE),
    .bus_out(ex_stage_in_bus.MASTER)
  );

endmodule
