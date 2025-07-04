`timescale 1ns / 1ps

import core_pkg::*;

module riscv_core (
  input logic clk,
  input logic rst_n
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
  
  fw_sel_e forwardA, forwardB;

  logic PCSrc_w;
  logic flush_pipeline_w;
  logic stall_w;
  logic [DATA_WIDTH-1:0] branch_target_addr_w;


  // ===================================
  //              Module
  // ===================================
  
  forwarding_unit fw_unit_inst (
    .RegWrite_MEM_i(mem_stage_in_bus.data.RegWrite),
    .RegWrite_WB_i(wb_stage_in_bus.data.RegWrite),
    .rd_addr_MEM_i(mem_stage_in_bus.data.rd_addr),
    .rd_addr_WB_i(wb_stage_in_bus.data.rd_addr),
    .rs1_addr_EX_i(ex_stage_in_bus.data.instruction[19:15]),
    .rs2_addr_EX_i(ex_stage_in_bus.data.instruction[24:20]),
    .forwardA(forwardA),
    .forwardB(forwardB)
  );

  hazard_detection_unit hazard_detect_inst (
    .rs1_addr_ID_i(id_stage_in_bus.data.instruction[19:15]),
    .rs2_addr_ID_i(id_stage_in_bus.data.instruction[24:20]),
    .rd_addr_EX_i(ex_stage_in_bus.data.rd_addr),
    .MemRead_EX_i(ex_stage_in_bus.data.MemRead),
    .stall_o(stall_w)
  );

  IF_stage IF_inst (
    .clk(clk),
    .rst_n(rst_n),
    .pc_we(~flush_pipeline_w && ~stall_w),
    .PCSrc_i(PCSrc_w),
    .branch_target_addr_i(branch_target_addr_w),
    .bus_out(if_stage_out_bus.MASTER)
  );

  IF_to_ID_Reg IF2ID_inst (
    .clk(clk),
    .rst_n(rst_n),
    .flush_i(flush_pipeline_w),
    .stall_i(stall_w),
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
    .flush_i(flush_pipeline_w),
    .stall_i(stall_w),
    .bus_in(id_stage_out_bus.SLAVE),
    .bus_out(ex_stage_in_bus.MASTER)
  );

  EX_stage EX_inst (
    .forwardA(forwardA),
    .forwardB(forwardB),
    .alu_result_MEM_i(mem_stage_in_bus.data.alu_result),
    .wb_data_WB_i(WB_wr_data_w),
    .bus_in(ex_stage_in_bus.SLAVE),

    .PCSrc_o(PCSrc_w),
    .flush_pipeline_o(flush_pipeline_w),
    .branch_target_addr_o(branch_target_addr_w),
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
