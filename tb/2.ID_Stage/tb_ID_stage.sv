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

  // Clock generator
  always #(CLK_PERIOD / 2) clk = ~clk;

  // Main test sequence
  initial begin
    integer error_count = 0;
    integer scenario_errors;

    $display("========================================");
    $display("Testbench for ID_stage starting...");
    $display("========================================");

    // 1. Initial state
    clk = 0;
    instruction_i = '0; // NOP
    WB_RegWrite_i = 0;
    wr_addr_i = '0;
    wr_data_i = '0;
    
    #(CLK_PERIOD);

    // =================================================================
    // Scenario 1: Test ADDI
    // =================================================================
    scenario_errors = 0;
    WB_RegWrite_i = 1; wr_addr_i = 5'd1; wr_data_i = 32'd50;
    #(CLK_PERIOD); 
    WB_RegWrite_i = 0;

    instruction_i = {12'd123, 5'd1, 3'b000, 5'd2, 7'b0010011}; // addi x2, x1, 123
    #1;
    if (rd_data1_o !== 32'd50) begin $error("[FAIL] ADDI: rd_data1_o. Expected 50, Got %d", rd_data1_o); scenario_errors++; end
    if (immediate_o !== 32'd123) begin $error("[FAIL] ADDI: immediate_o. Expected 123, Got %d", immediate_o); scenario_errors++; end
    if (RegWrite_o !== 1'b1) begin $error("[FAIL] ADDI: RegWrite_o. Expected 1, Got %b", RegWrite_o); scenario_errors++; end
    if (ALUSrcB_o !== 1'b1) begin $error("[FAIL] ADDI: ALUSrcB_o. Expected 1, Got %b", ALUSrcB_o); scenario_errors++; end
    if (ALUOp_o !== ALUOP_FUNCT3) begin $error("[FAIL] ADDI: ALUOp_o. Expected ALUOP_FUNCT3, Got %s", ALUOp_o.name()); scenario_errors++; end
    if (WBSel_o !== WB_ALU) begin $error("[FAIL] ADDI: WBSel_o. Expected WB_ALU, Got %s", WBSel_o.name()); scenario_errors++; end
    if (scenario_errors == 0) $display("[SUCCESS] Scenario 1: Test ADDI");
    error_count += scenario_errors;
    #(CLK_PERIOD);

    // =================================================================
    // Scenario 2: Test ADD
    // =================================================================
    scenario_errors = 0;
    WB_RegWrite_i = 1; wr_addr_i = 5'd2; wr_data_i = 32'd25;
    #(CLK_PERIOD);
    WB_RegWrite_i = 0;

    instruction_i = {7'b0000000, 5'd2, 5'd1, 3'b000, 5'd3, 7'b0110011}; // add x3, x1, x2
    #1;
    if (rd_data1_o !== 32'd50) begin $error("[FAIL] ADD: rd_data1_o. Expected 50, Got %d", rd_data1_o); scenario_errors++; end
    if (rd_data2_o !== 32'd25) begin $error("[FAIL] ADD: rd_data2_o. Expected 25, Got %d", rd_data2_o); scenario_errors++; end
    if (RegWrite_o !== 1'b1) begin $error("[FAIL] ADD: RegWrite_o. Expected 1, Got %b", RegWrite_o); scenario_errors++; end
    if (ALUSrcB_o !== 1'b0) begin $error("[FAIL] ADD: ALUSrcB_o. Expected 0, Got %b", ALUSrcB_o); scenario_errors++; end
    if (ALUOp_o !== ALUOP_FUNCT7) begin $error("[FAIL] ADD: ALUOp_o. Expected ALUOP_FUNCT7, Got %s", ALUOp_o.name()); scenario_errors++; end
    if (WBSel_o !== WB_ALU) begin $error("[FAIL] ADD: WBSel_o. Expected WB_ALU, Got %s", WBSel_o.name()); scenario_errors++; end
    if (scenario_errors == 0) $display("[SUCCESS] Scenario 2: Test ADD");
    error_count += scenario_errors;
    #(CLK_PERIOD);

    // =================================================================
    // Scenario 3: Test LW
    // =================================================================
    scenario_errors = 0;
    instruction_i = {12'd8, 5'd1, 3'b010, 5'd5, 7'b0000011}; // lw x5, 8(x1)
    #1;
    if (MemRead_o !== 1'b1) begin $error("[FAIL] LW: MemRead_o. Expected 1, Got %b", MemRead_o); scenario_errors++; end
    if (WBSel_o !== WB_MEM) begin $error("[FAIL] LW: WBSel_o. Expected WB_MEM, Got %s", WBSel_o.name()); scenario_errors++; end
    if (ALUOp_o !== ALUOP_ADD) begin $error("[FAIL] LW: ALUOp_o. Expected ALUOP_ADD, Got %s", ALUOp_o.name()); scenario_errors++; end
    if (scenario_errors == 0) $display("[SUCCESS] Scenario 3: Test LW");
    error_count += scenario_errors;
    #(CLK_PERIOD);

    // =================================================================
    // Scenario 4: Test SW
    // =================================================================
    scenario_errors = 0;
    instruction_i = {7'b0000000, 5'd2, 5'd1, 3'b010, 5'b01100, 7'b0100011}; // sw x2, 12(x1)
    #1;
    if (MemWrite_o !== 1'b1) begin $error("[FAIL] SW: MemWrite_o. Expected 1, Got %b", MemWrite_o); scenario_errors++; end
    if (RegWrite_o !== 1'b0) begin $error("[FAIL] SW: RegWrite_o. Expected 0, Got %b", RegWrite_o); scenario_errors++; end
    if (scenario_errors == 0) $display("[SUCCESS] Scenario 4: Test SW");
    error_count += scenario_errors;
    #(CLK_PERIOD);

    // =================================================================
    // Scenario 5: Test BEQ
    // =================================================================
    scenario_errors = 0;
    instruction_i = {7'b0, 5'd2, 5'd1, 3'b000, 5'b0, 7'b1100011}; // beq x1, x2, offset
    #1;
    if (Branch_o !== 1'b1) begin $error("[FAIL] BEQ: Branch_o. Expected 1, Got %b", Branch_o); scenario_errors++; end
    if (ALUOp_o !== ALUOP_SUB) begin $error("[FAIL] BEQ: ALUOp_o. Expected ALUOP_SUB, Got %s", ALUOp_o.name()); scenario_errors++; end
    if (RegWrite_o !== 1'b0) begin $error("[FAIL] BEQ: RegWrite_o. Expected 0, Got %b", RegWrite_o); scenario_errors++; end
    if (scenario_errors == 0) $display("[SUCCESS] Scenario 5: Test BEQ");
    error_count += scenario_errors;
    #(CLK_PERIOD);

    // =================================================================
    // Scenario 6: Test LUI
    // =================================================================
    scenario_errors = 0;
    instruction_i = {20'hABCDE, 5'd6, 7'b0110111}; // lui x6, 0xABCDE
    #1;
    if (immediate_o !== 32'hABCDE000) begin $error("[FAIL] LUI: immediate_o. Expected 32'hABCDE000, Got %h", immediate_o); scenario_errors++; end
    if (ALUSrcA_o !== 1'b1) begin $error("[FAIL] LUI: ALUSrcA_o. Expected 1, Got %b", ALUSrcA_o); scenario_errors++; end
    if (ALUOp_o !== ALUOP_PASS_B) begin $error("[FAIL] LUI: ALUOp_o. Expected ALUOP_PASS_B, Got %s", ALUOp_o.name()); scenario_errors++; end
    if (WBSel_o !== WB_ALU) begin $error("[FAIL] LUI: WBSel_o. Expected WB_ALU, Got %s", WBSel_o.name()); scenario_errors++; end
    if (scenario_errors == 0) $display("[SUCCESS] Scenario 6: Test LUI");
    error_count += scenario_errors;
    #(CLK_PERIOD);

    // =================================================================
    // Scenario 7: Test AUIPC
    // =================================================================
    scenario_errors = 0;
    instruction_i = {20'hFEDCB, 5'd7, 7'b0010111}; // auipc x7, 0xFEDCB
    #1;
    if (immediate_o !== 32'hFEDCB000) begin $error("[FAIL] AUIPC: immediate_o. Expected 32'hFEDCB000, Got %h", immediate_o); scenario_errors++; end
    if (ALUSrcA_o !== 1'b1) begin $error("[FAIL] AUIPC: ALUSrcA_o. Expected 1, Got %b", ALUSrcA_o); scenario_errors++; end
    if (ALUOp_o !== ALUOP_ADD) begin $error("[FAIL] AUIPC: ALUOp_o. Expected ALUOP_ADD, Got %s", ALUOp_o.name()); scenario_errors++; end
    if (scenario_errors == 0) $display("[SUCCESS] Scenario 7: Test AUIPC");
    error_count += scenario_errors;
    #(CLK_PERIOD);

    // =================================================================
    // Scenario 8: Test JAL
    // =================================================================
    scenario_errors = 0;
    instruction_i = {1'b0, 10'd12, 1'b0, 8'd1, 5'd10, 7'b1101111}; // jal x10, offset
    #1;
    if (Jump_o !== 1'b1) begin $error("[FAIL] JAL: Jump_o. Expected 1, Got %b", Jump_o); scenario_errors++; end
    if (RegWrite_o !== 1'b1) begin $error("[FAIL] JAL: RegWrite_o. Expected 1, Got %b", RegWrite_o); scenario_errors++; end
    if (WBSel_o !== WB_PC4) begin $error("[FAIL] JAL: WBSel_o. Expected WB_PC4, Got %s", WBSel_o.name()); scenario_errors++; end
    if (scenario_errors == 0) $display("[SUCCESS] Scenario 8: Test JAL");
    error_count += scenario_errors;
    #(CLK_PERIOD);


    $display("========================================");
    if (error_count == 0) begin
      $display("All tests passed!");
    end else begin
      $display("Testbench finished with %0d error(s).", error_count);
    end
    $display("========================================");

    repeat(100) @(posedge clk);
    $finish;
  end

endmodule
