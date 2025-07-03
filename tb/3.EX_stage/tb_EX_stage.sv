`timescale 1ns / 1ps

import core_pkg::*;

module tb_EX_stage;
    logic clk = 0;
    
    // Clock generator
    always #5 clk = ~clk;

    // Instantiate interfaces
    ID2EX_if id2ex_if();
    EX2MEM_if ex2mem_if();

    // Instantiate DUT and connect interfaces
    EX_stage dut (
      .bus_in(id2ex_if.SLAVE),
      .bus_out(ex2mem_if.MASTER)
    );

    // Task to drive inputs and check outputs
    task test_scenario(
      // Inputs for the EX stage
      input logic [DATA_WIDTH-1:0]       instruction_t,
      input logic [DATA_WIDTH-1:0]       immediate_t,
      input logic [DATA_WIDTH-1:0]       rd_data1_t,
      input logic [DATA_WIDTH-1:0]       rd_data2_t,
      input logic [REG_ADDR_WIDTH-1:0]   rd_addr_t,
      input logic [DATA_WIDTH-1:0]       pc_t,
      input logic [DATA_WIDTH-1:0]       pc_plus4_t,
      input logic                        ALUSrcA_t,
      input logic                        ALUSrcB_t,
      input alu_op_e                     ALUOp_t,
      input logic                        MemWrite_t,
      input logic                        MemRead_t,
      input logic                        RegWrite_t,
      input wb_sel_e                     WBSel_t,
      // Expected outputs from the EX stage
      input logic [DATA_WIDTH-1:0]       expected_alu_result_t,
      string                           scenario_name
    );
      @(posedge clk);
      #1; // Allow combinational logic to settle
      
      // Drive inputs directly to the interface signals
      id2ex_if.data.instruction = instruction_t;
      id2ex_if.data.immediate   = immediate_t;
      id2ex_if.data.rd_data1    = rd_data1_t;
      id2ex_if.data.rd_data2    = rd_data2_t;
      id2ex_if.data.rd_addr     = rd_addr_t;
      id2ex_if.data.pc          = pc_t;
      id2ex_if.data.pc_plus4    = pc_plus4_t;
      id2ex_if.data.ALUSrcA     = ALUSrcA_t;
      id2ex_if.data.ALUSrcB     = ALUSrcB_t;
      id2ex_if.data.ALUOp       = ALUOp_t;
      id2ex_if.data.MemWrite    = MemWrite_t;
      id2ex_if.data.MemRead     = MemRead_t;
      id2ex_if.data.RegWrite    = RegWrite_t;
      id2ex_if.data.WBSel       = WBSel_t;
      
      // Give a moment for the DUT to process
      #1;

      // Assertions to check the outputs from the interface
      assert(ex2mem_if.data.alu_result == expected_alu_result_t)
        else $error("[FAIL] %s: ALU result mismatch. Expected: %h, Got: %h", scenario_name, expected_alu_result_t, ex2mem_if.data.alu_result);

      // Only check rd_data2 if it's a store operation (MemWrite is active)
      if (MemWrite_t)
        assert(ex2mem_if.data.rd_data2 == rd_data2_t)
          else $error("[FAIL] %s: rd_data2 mismatch for Store.", scenario_name);

      // Only check rd_addr if a register write is expected
      if (RegWrite_t)
        assert(ex2mem_if.data.rd_addr == rd_addr_t)
          else $error("[FAIL] %s: rd_addr mismatch.", scenario_name);

      assert(ex2mem_if.data.MemWrite == MemWrite_t)
        else $error("[FAIL] %s: MemWrite mismatch.", scenario_name);
        
      assert(ex2mem_if.data.MemRead == MemRead_t)
        else $error("[FAIL] %s: MemRead mismatch.", scenario_name);

      assert(ex2mem_if.data.RegWrite == RegWrite_t)
        else $error("[FAIL] %s: RegWrite mismatch.", scenario_name);

      assert(ex2mem_if.data.WBSel == WBSel_t)
        else $error("[FAIL] %s: WBSel mismatch.", scenario_name);
        
      $info("[PASS] %s", scenario_name);

    endtask

    // Main test sequence
    initial begin
      $info("Starting EX Stage Testbench...");
      // Initialize all inputs to a known state
      id2ex_if.data = '0;
      #10;

      // --- Test Scenario 1: R-Type (add x3, x1, x2) ---
      test_scenario(
        .instruction_t(32'h002081b3), // add x3, x1, x2
        .immediate_t(32'bx),
        .rd_data1_t(32'd100),         // x1 = 100
        .rd_data2_t(32'd200),         // x2 = 200
        .rd_addr_t(5'd3),             // rd = x3
        .pc_t(32'h1000),
        .pc_plus4_t(32'h1004),
        .ALUSrcA_t(1'b0),             // operand1 = rd_data1
        .ALUSrcB_t(1'b0),             // operand2 = rd_data2
        .ALUOp_t(ALUOP_FUNCT7),
        .MemWrite_t(1'b0),
        .MemRead_t(1'b0),
        .RegWrite_t(1'b1),
        .WBSel_t(WB_ALU),
        .expected_alu_result_t(32'd300), // 100 + 200
        .scenario_name("R-Type ADD")
      );

      // --- Test Scenario 2: I-Type (addi x5, x1, 10) ---
      test_scenario(
        .instruction_t(32'h00A08293), // addi x5, x1, 10
        .immediate_t(32'd10),
        .rd_data1_t(32'd50),          // x1 = 50
        .rd_data2_t(32'bx),
        .rd_addr_t(5'd5),             // rd = x5
        .pc_t(32'h1004),
        .pc_plus4_t(32'h1008),
        .ALUSrcA_t(1'b0),             // operand1 = rd_data1
        .ALUSrcB_t(1'b1),             // operand2 = immediate
        .ALUOp_t(ALUOP_FUNCT3),
        .MemWrite_t(1'b0),
        .MemRead_t(1'b0),
        .RegWrite_t(1'b1),
        .WBSel_t(WB_ALU),
        .expected_alu_result_t(32'd60), // 50 + 10
        .scenario_name("I-Type ADDI")
      );

      // --- Test Scenario 3: Load (lw x6, 20(x1)) ---
      test_scenario(
        .instruction_t(32'h0140A303), // lw x6, 20(x1)
        .immediate_t(32'd20),
        .rd_data1_t(32'd1000),        // x1 = 1000 (base address)
        .rd_data2_t(32'bx),
        .rd_addr_t(5'd6),             // rd = x6
        .pc_t(32'h1008),
        .pc_plus4_t(32'h100C),
        .ALUSrcA_t(1'b0),             // operand1 = rd_data1
        .ALUSrcB_t(1'b1),             // operand2 = immediate
        .ALUOp_t(ALUOP_ADD),
        .MemWrite_t(1'b0),
        .MemRead_t(1'b1),
        .RegWrite_t(1'b1),
        .WBSel_t(WB_MEM),
        .expected_alu_result_t(32'd1020), // 1000 + 20
        .scenario_name("Load LW")
      );

      // --- Test Scenario 4: Store (sw x2, 30(x1)) ---
      test_scenario(
        .instruction_t(32'h0120AC23), // sw x2, 30(x1)
        .immediate_t(32'd30),
        .rd_data1_t(32'd2000),        // x1 = 2000 (base address)
        .rd_data2_t(32'hCAFECAFE),    // x2 = data to be stored
        .rd_addr_t(5'bx),             // rd is not used
        .pc_t(32'h100C),
        .pc_plus4_t(32'h1010),
        .ALUSrcA_t(1'b0),             // operand1 = rd_data1
        .ALUSrcB_t(1'b1),             // operand2 = immediate
        .ALUOp_t(ALUOP_ADD),
        .MemWrite_t(1'b1),
        .MemRead_t(1'b0),
        .RegWrite_t(1'b0),
        .WBSel_t(WB_NONE),
        .expected_alu_result_t(32'd2030), // 2000 + 30
        .scenario_name("Store SW")
      );
      
      // --- Test Scenario 5: LUI (lui x7, 0xABCD) ---
      test_scenario(
        .instruction_t(32'h0ABCD3B7), // lui x7, 0xABCD
        .immediate_t(32'hABCD000),
        .rd_data1_t(32'bx),
        .rd_data2_t(32'bx),
        .rd_addr_t(5'd7),             // rd = x7
        .pc_t(32'h1010),
        .pc_plus4_t(32'h1014),
        .ALUSrcA_t(1'b0),             // This doesn't matter
        .ALUSrcB_t(1'b1),             // operand2 = immediate
        .ALUOp_t(ALUOP_PASS_B),
        .MemWrite_t(1'b0),
        .MemRead_t(1'b0),
        .RegWrite_t(1'b1),
        .WBSel_t(WB_ALU),
        .expected_alu_result_t(32'hABCD000),
        .scenario_name("U-Type LUI")
      );

      $info("All EX stage tests completed.");
      repeat(100) @(posedge clk);
      $finish;
    end

endmodule
