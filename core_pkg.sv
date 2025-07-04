`timescale 1ns / 1ps
package core_pkg;

  // ================================== //
  //          Define localparam         //
  // ================================== //
  localparam DATA_WIDTH          = 32;
  localparam BYTE_WIDTH          =  8;
  localparam INST_WIDTH          = 32;
  
  localparam NUM_REGS            = 32;
  localparam REG_ADDR_WIDTH      = $clog2(NUM_REGS);

  localparam DATA_MEM_DEPTH      = 1024;
  localparam DATA_MEM_ADDR_WIDTH = $clog2(DATA_MEM_DEPTH);

  localparam INST_MEM_DEPTH      = 1024;
  localparam INST_MEM_ADDR_WIDTH = $clog2(INST_MEM_DEPTH);

  // ================================== //
  //         Define Instruction         //
  // ================================== //
  typedef enum logic [6:0] {     // === OPCODE === //
    OPCODE_R       = 7'b0110011, // Arithmetic
    OPCODE_I       = 7'b0010011, // Immediate
    OPCODE_LOAD    = 7'b0000011, // LOAD
    OPCODE_STORE   = 7'b0100011, // Store
    OPCODE_BRANCH  = 7'b1100011, // Branch
    OPCODE_JAL     = 7'b1101111, // Jump And Link
    OPCODE_JALR    = 7'b1100111, // Jump And Link Reg
    OPCODE_LUI     = 7'b0110111, // Load Upper Imm
    OPCODE_AUIPC   = 7'b0010111, // Add Upper Imm to PC
    OPCODE_INVALID = 7'b1111111  // For Debuging
  } opcode_e;
  
  // === FUNCT3 === //
  // Arithmetic
  localparam logic [2:0] FUNCT3_R_ADD_SUB   = 3'h0; // ADD / SUB
  localparam logic [2:0] FUNCT3_I_ADDI      = 3'h0; // ADDI

  // Logical
  localparam logic [2:0] FUNCT3_R_XOR       = 3'h4; // xor
  localparam logic [2:0] FUNCT3_I_XORI      = 3'h4; // xori
  localparam logic [2:0] FUNCT3_R_OR        = 3'h6; // or
  localparam logic [2:0] FUNCT3_I_ORI       = 3'h6; // ori
  localparam logic [2:0] FUNCT3_R_AND       = 3'h7; // and
  localparam logic [2:0] FUNCT3_I_ANDI      = 3'h7; // andi

  // Shift
  localparam logic [2:0] FUNCT3_R_SLL       = 3'h1; // Shift Left Logical
  localparam logic [2:0] FUNCT3_I_SLLI      = 3'h1; // Shift Left Arith
  localparam logic [2:0] FUNCT3_R_SHIFT_R   = 3'h5; // Shift Right Logical (srl, sra)
  localparam logic [2:0] FUNCT3_I_SHIFT_R   = 3'h5; // Shift Right Arith   (srli, srai)
  localparam logic [2:0] FUNCT3_R_SLT       = 3'h2; // Set Less Than
  localparam logic [2:0] FUNCT3_I_SLTI      = 3'h2; // Set Less Than Imm
  localparam logic [2:0] FUNCT3_R_SLTU      = 3'h3; // Set Less Than Unsinged
  localparam logic [2:0] FUNCT3_I_SLTIU     = 3'h3; // Set Less Than Imm Unsinged

  // Load
  localparam logic [2:0] FUNCT3_LOAD_BYTE   = 3'h0; // Load Byte
  localparam logic [2:0] FUNCT3_LOAD_HALF   = 3'h1; // Load Half
  localparam logic [2:0] FUNCT3_LOAD_WORD   = 3'h2; // Load Word
  localparam logic [2:0] FUNCT3_LOAD_BYTE_U = 3'h4; // Load Byte (Unsigned)
  localparam logic [2:0] FUNCT3_LOAD_HALF_U = 3'h5; // Load Half (Unsigned)

  // Store
  localparam logic [2:0] FUNCT3_STORE_BYTE  = 3'h0; // Store Byte
  localparam logic [2:0] FUNCT3_STORE_HALF  = 3'h1; // Store Half
  localparam logic [2:0] FUNCT3_STORE_WORD  = 3'h2; // Store Word

  // Branch
  localparam logic [2:0] FUNCT3_BRANCH_EQ   = 3'b000; // Branch ==
  localparam logic [2:0] FUNCT3_BRANCH_NE   = 3'b001; // Branch !=
  localparam logic [2:0] FUNCT3_BRANCH_LT   = 3'b100; // Branch <
  localparam logic [2:0] FUNCT3_BRANCH_GE   = 3'b101; // Branch >=
  localparam logic [2:0] FUNCT3_BRANCH_LTU  = 3'b110; // Branch < (Unsigned)
  localparam logic [2:0] FUNCT3_BRANCH_GEU  = 3'b111; // Branch >= (Unsigned)

  // Jump
  localparam logic [2:0] FUNCT3_JALR        = 3'h0; // Jump and Link Reg

  // For Debuging
  localparam logic [2:0] FUNCT3_INV         = 3'h0;

  // === FUNCT7 === //
  // Arithmetic
  localparam logic [6:0] FUNCT7_R_ADD   = 7'h00; // ADD
  localparam logic [6:0] FUNCT7_R_SUB   = 7'h20; // SUB

  // Logical
  localparam logic [6:0] FUNCT7_R_XOR   = 7'h00; // XOR
  localparam logic [6:0] FUNCT7_R_OR    = 7'h00; // OR
  localparam logic [6:0] FUNCT7_R_AND   = 7'h00; // AND

  // Shift
  localparam logic [6:0] FUNCT7_R_SLL   = 7'h00; // SLL
  localparam logic [6:0] FUNCT7_R_SRL   = 7'h00; // SRL
  localparam logic [6:0] FUNCT7_R_SRA   = 7'h20; // SRA
  localparam logic [6:0] FUNCT7_I_SLL   = 7'h00; // SLLI imm[5:11]
  localparam logic [6:0] FUNCT7_I_SRL   = 7'h00; // SRLI imm[5:11]
  localparam logic [6:0] FUNCT7_I_SRA   = 7'h20; // SRAI imm[5:11]
  localparam logic [6:0] FUNCT7_R_SLT   = 7'h00; // SLT
  localparam logic [6:0] FUNCT7_R_SLTU  = 7'h00; // SLTU

  // For Debuging
  localparam logic [6:0] FUNCT7_INVALID = 7'h11;

  typedef enum logic [2:0] {
  IMM_RTYPE,
  IMM_ITYPE,
  IMM_STYPE,
  IMM_BTYPE,
  IMM_UTYPE,
  IMM_JTYPE,
  IMM_LOGICAL
} imm_sel_e;

  typedef enum logic [2:0] {
    ALUOP_ADD,
    ALUOP_SUB,
    ALUOP_PASS_B,
    ALUOP_FUNCT3,
    ALUOP_FUNCT7,
    ALUOP_NONE
  } alu_op_e;

  typedef enum logic [3:0] {
    ALU_ADD,    // add, addi, lw, sw, jal, jalr
    ALU_SUB,    // sub, beq, bne, blt, bge, bltu, bgeu
    ALU_AND,    // and, andi
    ALU_XOR,    // xor, xori
    ALU_OR,     // or, ori
    ALU_SLL,    // sll, slli
    ALU_SRL,    // srl, srli
    ALU_SRA,    // sra, srai
    ALU_SLT,    // slt, slti
    ALU_SLTU,   // sltu, sltiu
    ALU_PASS_B, // lut
    ALU_X       // default
  } alu_sel_e;

  typedef enum logic [1:0] {
    WB_ALU,
    WB_MEM,
    WB_PC4,
    WB_NONE
  } wb_sel_e;

  typedef enum logic [1:0] {
    FW_NONE,
    FW_MEM_ALU,
    FW_MEM_DATA,
    FW_WB_DATA
  } fw_sel_e;


  typedef struct packed {
    logic [DATA_WIDTH-1:0] instruction;
    logic [DATA_WIDTH-1:0] pc;
    logic [DATA_WIDTH-1:0] pc_plus4;
  } if_id_data_t;
  
  typedef struct packed {
    logic [DATA_WIDTH-1:0] instruction;
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
  } id_ex_data_t;

  typedef struct packed {
    logic [DATA_WIDTH-1:0] instruction;
    logic [DATA_WIDTH-1:0] alu_result;
    logic [DATA_WIDTH-1:0] pc_plus4;
    logic [DATA_WIDTH-1:0] rd_data2;
    logic [REG_ADDR_WIDTH-1:0] rd_addr;

    logic MemWrite;
    logic MemRead;
    logic RegWrite;
    wb_sel_e WBSel;
  } ex_mem_data_t;

  typedef struct packed {
    logic [DATA_WIDTH-1:0] instruction;
    logic [DATA_WIDTH-1:0] alu_result;
    logic [DATA_WIDTH-1:0] pc_plus4;
    logic [DATA_WIDTH-1:0] rd_data;
    logic [REG_ADDR_WIDTH-1:0] rd_addr;

    logic RegWrite;
    wb_sel_e WBSel;
  } mem_wb_data_t;

endpackage
