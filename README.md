# MIPS32 Five-Stage Pipelined Processor
### Synthesizable Verilog RTL | Yosys | OpenROAD | SKY130HD

<p align="center">
  <strong>A modular 32-bit MIPS processor implementing a five-stage pipeline, hazard detection, data forwarding, and a complete RTL-to-GDSII physical-design flow.</strong>
</p>

---

## Overview

This project implements a **32-bit, five-stage pipelined MIPS processor** using synthesizable Verilog-2001. The processor is organised into independent RTL modules, making the design easier to understand, simulate, debug, and synthesise.

The processor follows the classical five-stage pipeline architecture:

1. **IF – Instruction Fetch**
2. **ID – Instruction Decode and Register Read**
3. **EX – Execute and Address Calculation**
4. **MEM – Memory Access**
5. **WB – Write Back**

The design incorporates data forwarding, load-use hazard detection, pipeline stalling, and branch/jump flushing to handle common pipeline dependencies.

Beyond RTL development and simulation, the project was taken through a physical-design implementation flow using **Yosys, OpenROAD, and the SKY130 High-Density standard-cell library**, producing a final GDSII layout.

## Key Features

- 32-bit MIPS processor architecture.
- Five-stage instruction pipeline.
- Modular Verilog-2001 RTL implementation.
- Separate instruction and data memories.
- 32 × 32-bit general-purpose register file.
- ALU supporting arithmetic and logical operations.
- EX/MEM and MEM/WB data forwarding.
- Load-use hazard detection with one-cycle pipeline stall.
- Branch and jump handling with pipeline flushing.
- Pipeline valid-bit management.
- Synthesizable instruction ROM generated from a memory file.
- Simulation-based integration verification.
- Yosys synthesis and OpenROAD physical implementation.
- SKY130HD standard-cell technology.
- Final GDSII generation.

---

## 1. Processor Architecture

The processor uses a five-stage pipeline in which multiple instructions can be processed simultaneously.

| Stage | Name | Main operations |
|---|---|---|
| IF | Instruction Fetch | Fetch instruction and update PC |
| ID | Instruction Decode | Decode instruction and read registers |
| EX | Execute | ALU operations, address calculation, branch decisions |
| MEM | Memory Access | Read or write data memory |
| WB | Write Back | Write results into the register file |

### Pipeline organisation

**IF → ID → EX → MEM → WB**

Pipeline registers separate the stages:

- IF/ID
- ID/EX
- EX/MEM
- MEM/WB

These registers carry instruction information, control signals, operands, and intermediate results between pipeline stages.

## 2. Supported Instruction Set

The implementation supports the following MIPS instruction subset.

| Instruction | Operation | Type |
|---|---|---|
| ADD | Register addition | R-type |
| SUB | Register subtraction | R-type |
| AND | Bitwise AND | R-type |
| OR | Bitwise OR | R-type |
| XOR | Bitwise XOR | R-type |
| SLT | Set on less than | R-type |
| ADDI | Immediate addition | I-type |
| LW | Load word | I-type |
| SW | Store word | I-type |
| BEQ | Branch if equal | I-type |
| BNE | Branch if not equal | I-type |
| J | Jump | J-type |

This is a defined instruction subset, not a complete implementation of the MIPS ISA.

## 3. Pipeline Hazard Management

Pipeline dependencies are handled using forwarding, stalling, and flushing mechanisms.

### 3.1 Data Forwarding

The forwarding unit checks whether an instruction currently in the EX stage depends on a result produced by an earlier instruction.

Forwarding paths:

- EX/MEM → EX
