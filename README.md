# 5-Stage Pipelined RISC-V Processor

This project is an implementation of a 32-bit RISC-V processor with a classic 5-stage pipeline architecture. The processor is written in SystemVerilog and is designed for educational and research purposes. It supports a significant portion of the RV32I base instruction set and includes mechanisms for handling data hazards through forwarding and stalling.

## Key Features

-   **5-Stage Pipeline**: The core is structured with five distinct pipeline stages:
    1.  **IF (Instruction Fetch)**
    2.  **ID (Instruction Decode)**
    3.  **EX (Execute)**
    4.  **MEM (Memory Access)**
    5.  **WB (Write Back)**
-   **RV32I Instruction Set**: Implements a wide range of the base integer instructions, including:
    -   **R-Type**: `ADD`, `SUB`, `SLL`, `SLT`, `SLTU`, `XOR`, `SRL`, `SRA`, `OR`, `AND`
    -   **I-Type**: `ADDI`, `SLTI`, `SLTIU`, `XORI`, `ORI`, `ANDI`, `SLLI`, `SRLI`, `SRAI`, `JALR`, `LW`
    -   **S-Type**: `SW`
    -   **B-Type**: `BEQ`, `BNE`, `BLT`, `BGE`, `BLTU`, `BGEU`
    -   **U-Type**: `LUI`, `AUIPC`
    -   **J-Type**: `JAL`
-   **Hazard Management**:
    -   **Forwarding Unit**: Implements data forwarding from the EX and MEM stages back to the EX stage to minimize data hazard stalls.
    -   **Hazard Detection Unit**: Stalls the pipeline (pipeline bubble) upon detecting a load-use data hazard (`LW` followed by an instruction that uses the loaded value).
-   **Modular Design**: The design is highly modular, with clear separation between pipeline stages, control units, and pipeline registers, enhancing readability and maintainability.

## Project Structure

The project is organized into the following directories:

```
.
├── interface/      # SystemVerilog interfaces for pipeline stage communication
├── mem/            # Memory initialization files for test programs
├── rtl/            # All synthesizable RTL source code
│   ├── 0.Pipeline/ # Pipeline registers
│   ├── 1.IF_Stage/
│   ├── 2.ID_Stage/
│   ├── 3.EX_Stage/
│   ├── 4.MEM_Stage/
│   ├── 5.WB_Stage/
│   ├── 6.Control_Unit/
│   └── 7.Hazard_Unit/
├── tb/             # Testbenches for the core and individual modules
├── core_pkg.sv     # Central package with definitions (opcodes, etc.)
├── run_vivado.sh   # Script to launch the simulation
└── simulate.tcl    # Tcl script for Vivado simulation
```

## Getting Started

### Prerequisites

-   [Xilinx Vivado Design Suite](https://www.xilinx.com/products/design-tools/vivado.html)

### Running a Simulation

1.  **Choose a Test Program**:
    To select which program to run, you need to edit the `simulate.tcl` file. Find the following line:
    ```tcl
    set_property top tb_load_use [get_filesets sim_1]
    ```
    And change `tb_load_use` to the testbench you want to simulate (e.g., `tb_add`, `tb_branch_test`).

2.  **Execute the Run Script**:
    Open a terminal in the project root directory and run the following command:
    ```sh
    ./run_vivado.sh
    ```
    This will start the simulation in batch mode. Vivado will compile the sources and run the testbench.

3.  **GUI Mode**:
    To run the simulation and open the Vivado GUI for debugging, use the `-gui` flag:
    ```sh
    ./run_vivado.sh -gui
    ```
