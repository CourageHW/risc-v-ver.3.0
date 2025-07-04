`timescale 1ns / 1ps

import core_pkg::*;

module riscv_core (
  input logic clk,
  input logic rst_n,
  input logic pc_we
);

  // ===================================
  //             Interface
  // ===================================
  IF2ID_if  if_stage_out_bus();  // IF -> REG
  IF2ID_if  id_stage_in_bus();   // REG -> ID
  ID2EX_if  id_stage_out_bus();  // ID -> REG
  ID2EX_if  ex_stage_in_bus();   // REG -> EX
  EX2MEM_if ex_stage_out_bus(); // EX -> REG
  EX2MEM_if mem_stage_in_bus(); // REG -> MEM
  MEM2WB_if mem_stage_out_bus(); // MEM -> REG
  MEM2WB_if wb_stage_in_bus();   // REG -> WB



  // ===================================
  //             Interface
  // ===================================
  logic [DATA_WIDTH-1:0] WB_wr_data_w;
  logic [REG_ADDR_WIDTH-1:0] WB_wr_addr_w;
  logic WB_RegWrite_w;
  



  // ===================================
  //              Module
  // ===================================
  IF_stage IF_inst (
    .clk(clk),
    .rst_n(rst_n),
    .pc_we(pc_we), // 임시
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

  EX_stage EX_inst (
    .bus_in(ex_stage_in_bus.SLAVE),
    .bus_out(ex_stage_out_bus.MASTER)
  );

  EX_to_MEM_Reg EX2MEM_inst (
    .clk(clk),
    .rst_n(rst_n),
    .bus_in(ex_stage_out_bus.SLAVE),
    .bus_out(mem_stage_in_bus.MASTER)
  );

  MEM_stage MEM_inst (
    .clk(clk),
    .bus_in(mem_stage_in_bus.SLAVE),
    .bus_out(mem_stage_out_bus.MASTER)
  );

  MEM_to_WB_Reg MEM2WB_inst (
    .clk(clk),
    .rst_n(rst_n),
    .bus_in(mem_stage_out_bus.SLAVE),
    .bus_out(wb_stage_in_bus.MASTER)
  );

  WB_stage WB_inst (
    .bus_in(wb_stage_in_bus.SLAVE),
    .wb_data_o(WB_wr_data_w),
    .instruction_o(),
    .rd_addr_o(WB_wr_addr_w),
    .RegWrite_o(WB_RegWrite_w)
  );
endmodule
