package core_pkg;

  // ================================== //
  //          Define Parameter          //
  // ================================== //
  parameter DATA_WIDTH          = 32;
  parameter BYTE_WIDTH          =  8;
  parameter INST_WIDTH          = 32;
  
  parameter NUM_REGS            = 32;
  parameter REG_ADDR_WIDTH      = $clog2(NUM_REGS);

  parameter DATA_MEM_DEPTH      = 1024;
  parameter DATA_MEM_ADDR_WIDTH = $clog2(DATA_MEM_DEPTH);

  parameter INST_MEM_DEPTH      = 1024;
  parameter INST_MEM_ADDR_WIDTH = $clog2(INST_MEM_DEPTH);

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
  
  typedef enum logic [2:0] {   // === FUNCT3 === //
    // Arithmetic
    FUNCT3_R_ADD_SUB   = 3'h0, // ADD / SUB
    FUNCT3_I_ADDI      = 3'h0, // ADDI

    // Logical
    FUNCT3_R_XOR       = 3'h4, // xor
    FUNCT3_I_XORI      = 3'h4, // xori
    FUNCT3_R_OR        = 3'h6, // or
    FUNCT3_I_ORI       = 3'h6, // ori
    FUNCT3_R_AND       = 3'h7, // and
    FUNCT3_I_ANDI      = 3'h7, // andi

    // Shift
    FUNCT3_R_SLL       = 3'h1, // Shift Left Logical
    FUNCT3_I_SLLI      = 3'h1, // Shift Left Arith
    FUNCT3_R_SHIFT_R   = 3'h5, // Shift Right Logical (srl, sra)
    FUNCT3_I_SHIFT_R   = 3'h5, // Shift Right Arith   (srli, srai)
    FUNCT3_R_SLT       = 3'h2, // Set Less Than
    FUNCT3_I_SLTI      = 3'h2, // Set Less Than Imm
    FUNCT3_R_SLTU      = 3'h3, // Set Less Than Unsinged
    FUNCT3_I_SLTIU     = 3'h3, // Set Less Than Imm Unsinged

    // Load
    FUNCT3_LOAD_BYTE   = 3'h0, // Load Byte
    FUNCT3_LOAD_HALF   = 3'h1, // Load Half
    FUNCT3_LOAD_WORD   = 3'h2, // Load Word
    FUNCT3_LOAD_BYTE_U = 3'h4, // Load Byte (Unsigned)
    FUNCT3_LOAD_HALF_U = 3'h5, // Load Half (Unsigned)

    // Store
    FUNCT3_STORE_BYTE  = 3'h0, // Store Byte
    FUNCT3_STORE_HALF  = 3'h1, // Store Half
    FUNCT3_STORE_WORD  = 3'h2, // Store Word

    // Branch
    FUNCT3_BRANCH_EQ   = 3'h0, // Branch ==
    FUNCT3_BRANCH_NE   = 3'h1, // Branch !=
    FUNCT3_BRANCH_LT   = 3'h4, // Branch <
    FUNCT3_BRANCH_GE   = 3'h5, // Branch >=
    FUNCT3_BRANCH_LTU  = 3'h6, // Branch < (Unsigned)
    FUNCT3_BRANCH_GEU  = 3'h7, // Branch >= (Unsigned)

    // Jump
    FUNCT3_JALR        = 3'h0, // Jump and Link Reg

    // For Debuging
    FUNCT3_INV         = 3'h0
  } funct3_e;

  typedef enum logic [6:0] {// === FUNCT7 === //
    // Arithmetic
    FUNCT7_R_ADD   = 7'h00, // ADD
    FUNCT7_R_SUB   = 7'h20, // SUB

    // Logical
    FUNCT7_R_XOR   = 7'h00, // XOR
    FUNCT7_R_OR    = 7'h00, // OR
    FUNCT7_R_AND   = 7'h00, // AND

    // Shift
    FUNCT7_R_SLL   = 7'h00, // SLL
    FUNCT7_R_SRL   = 7'h00, // SRL
    FUNCT7_R_SRA   = 7'h20, // SRA
    FUNCT7_I_SLL   = 7'h00, // SLLI imm[5:11]
    FUNCT7_I_SRL   = 7'h00, // SRLI imm[5:11]
    FUNCT7_I_SRA   = 7'h20, // SRAI imm[5:11]
    FUNCT7_R_SLT   = 7'h00, // SLT
    FUNCT7_R_SLTU  = 7'h00, // SLTU

    // For Debuging
    FUNCT7_INVALID = 7'h11
  } funct7_e;


endpackage
