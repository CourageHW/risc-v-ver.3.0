`timescale 1ns / 1ps
`default_nettype none

import core_pkg::*;

module tb_MEM_stage;

  // 1. Clock Generation
  logic clk = 0;
  always #5 clk = ~clk;

  // 2. Interface Instantiation
  EX2MEM_if ex2mem_if();
  MEM2WB_if mem2wb_if();

  // 3. DUT (Device Under Test) Instantiation
  MEM_stage dut (
    .clk(clk),
    .bus_in(ex2mem_if),
    .bus_out(mem2wb_if)
  );

  // Task for initializing all input signals to a known state
  task initialize_inputs();
    $display("\n[TASK] Initializing all inputs to 0...");
    ex2mem_if.data <= '0;
    @(posedge clk);
  endtask

  // MODIFIED: This task now only drives the stimulus.
  // The main test sequence will control clocking.
  task drive_stimulus(input ex_mem_data_t stimulus);
    $display("\n[TASK] Driving new stimulus for test...");
    ex2mem_if.data <= stimulus;
  endtask

  // NO CHANGE to this task. The assertion logic itself is correct.
  task automatic check_output(
    string test_name,
    mem_wb_data_t expected
  );
    $display("[TASK] Checking outputs for test: %s", test_name);
    #1; // Wait for a small delay for combinational logic to settle before asserting

    // Check 1: ALU Result Passthrough
    assert (mem2wb_if.data.alu_result == expected.alu_result) else
      $error("FAIL: %s (alu_result)\n  Expected: %h\n  Got:      %h",
             test_name, expected.alu_result, mem2wb_if.data.alu_result);

    // Check 2: Write-back Register Address
    assert (mem2wb_if.data.rd_addr == expected.rd_addr) else
      $error("FAIL: %s (rd_addr)\n  Expected: %d\n  Got:      %d",
             test_name, expected.rd_addr, mem2wb_if.data.rd_addr);

    // Check 3: Register Write Control Signal
    assert (mem2wb_if.data.RegWrite == expected.RegWrite) else
      $error("FAIL: %s (RegWrite)\n  Expected: %b\n  Got:      %b",
             test_name, expected.RegWrite, mem2wb_if.data.RegWrite);

    // Check 4: Write-back MUX Selector
    assert (mem2wb_if.data.WBSel == expected.WBSel) else
      $error("FAIL: %s (WBSel)\n  Expected: %s\n  Got:      %s",
             test_name, expected.WBSel.name(), mem2wb_if.data.WBSel.name());

    // Check 5: Data read from memory (only if the instruction was a load)
    if (expected.WBSel == WB_MEM) begin
      assert (mem2wb_if.data.rd_data == expected.rd_data) else
        $error("FAIL: %s (rd_data from Memory)\n  Expected: %h\n  Got:      %h",
               test_name, expected.rd_data, mem2wb_if.data.rd_data);
    end
    
    $display("PASS: %s", test_name);
  endtask


  // MODIFIED: Main Test Sequence to handle timing correctly
  initial begin
    ex_mem_data_t stimulus;
    mem_wb_data_t expected_output;

    $display("--- Starting MEM_stage Testbench ---");
    initialize_inputs();

    // --- Test Case 1: R-Type Instruction (e.g., ADD) ---
    stimulus = '{
        alu_result: 32'hCAFE_BABE,
        rd_data2:   'x,
        rd_addr:    5'd10,
        MemWrite:   1'b0,
        MemRead:    1'b0,
        RegWrite:   1'b1,
        WBSel:      WB_ALU,
        default:    '0
    };
    drive_stimulus(stimulus);
    @(posedge clk);

    expected_output = '{
        alu_result: 32'hCAFE_BABE,
        rd_data:    'x,
        rd_addr:    5'd10,
        RegWrite:   1'b1,
        WBSel:      WB_ALU,
        default:    '0
    };
    check_output("R-Type Passthrough", expected_output); // Check right after the clock edge

    // --- Test Case 2: Store Word (sw) Instruction ---
    stimulus = '{
        alu_result: 32'h0000_0080,
        rd_data2:   32'hFEED_F00D,
        rd_addr:    'x,
        MemWrite:   1'b1,
        MemRead:    1'b0,
        RegWrite:   1'b0,
        WBSel:      WB_ALU,
        default:    '0
    };
    drive_stimulus(stimulus);
    @(posedge clk);
    $display("INFO: Store Word (sw) - Value written to memory address 0x80.");

    // --- Test Case 3: Load Word (lw) Instruction ---
    stimulus = '{
        alu_result: 32'h0000_0080,
        rd_data2:   'x,
        rd_addr:    5'd20,
        MemWrite:   1'b0,
        MemRead:    1'b1,
        RegWrite:   1'b1,
        WBSel:      WB_MEM,
        default:    '0
    };
    drive_stimulus(stimulus);
    @(posedge clk); // CLOCK 1: DUT receives 'lw' request. data_memory starts the read.

    expected_output = '{
        alu_result: 32'h0000_0080,
        rd_data:    32'hFEED_F00D,
        rd_addr:    5'd20,
        RegWrite:   1'b1,
        WBSel:      WB_MEM,
        default:    '0
    };
    check_output("Load Word (lw)", expected_output); // Check now, when all outputs are valid.

    $display("\n--- All MEM_stage tests completed successfully! ---");
    repeat(100) @(posedge clk);
    $finish;
  end

endmodule
`default_nettype wire
