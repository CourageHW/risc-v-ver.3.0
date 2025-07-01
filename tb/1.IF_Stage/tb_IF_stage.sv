`timescale 1ns / 1ps

import core_pkg::*;

module tb_IF_stage;

  localparam CLK_PERIOD = 10; // 10ns

  logic clk;
  logic rst_n;
  logic pc_we;
  
  logic [DATA_WIDTH-1:0] inst_o;
  logic [INST_WIDTH-1:0] expected_memory [0:9];

  IF_stage dut (
    .clk(clk),
    .rst_n(rst_n),
    .pc_we(pc_we),
    .inst_o(inst_o)
  );

  // clock generator
  initial begin
    clk = 0;
    forever #(CLK_PERIOD/2) clk = ~clk;
  end

  initial begin
    for (int i = 0; i < 10; i++) begin
      expected_memory[i] = i;
      dut.inst_mem_inst.instruction_memory[i] = i;
    end
  end

  initial begin
    initialize_ports();
    reset_perform();

    read_instruction_mem();
    #1000;
    $finish;
  end

  task initialize_ports();
    rst_n = 1;
    pc_we = 0;
  endtask;

  task reset_perform();
    @(posedge clk);
    rst_n = 0;
    repeat(2) @(posedge clk);
    rst_n = 1;
    @(posedge clk);
  endtask

  task read_instruction_mem();
    $display("=== Read Instruction Memory Start ===");
    pc_we = 1'b1;

    @(posedge clk);
    for (int i = 0; i < 10; i++) begin
      assert(inst_o == expected_memory[i])
        else $error("[FAIL] Read instruction mismatch. Expected: %h, Got: %h, index: %d", 
                     expected_memory[i], inst_o, i);
      @(posedge clk);
    end

    @(posedge clk);
    $display("=== [SUCCESS] Read Instruction Memory ===");
  endtask
endmodule
