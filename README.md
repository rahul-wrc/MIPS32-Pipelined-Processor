# MIPS32 Five-Stage Pipelined Processor

### A 32-bit Pipelined Processor Designed Using Verilog-2001 and Implemented Through the RTL-to-GDSII Flow

<p align="center">

**RTL Design** · **Computer Architecture** · **Digital Design** · **VLSI Physical Design**

</p>

<p align="center">

![Verilog](https://img.shields.io/badge/HDL-Verilog--2001-blue?style=for-the-badge)
![Yosys](https://img.shields.io/badge/Synthesis-Yosys-orange?style=for-the-badge)
![OpenROAD](https://img.shields.io/badge/Physical%20Design-OpenROAD-purple?style=for-the-badge)
![PDK](https://img.shields.io/badge/PDK-SKY130HD-green?style=for-the-badge)
![Status](https://img.shields.io/badge/Status-GDSII%20Generated-success?style=for-the-badge)

</p>

---

## 📌 Project Overview

This project presents the design and physical implementation of a **32-bit, five-stage pipelined MIPS processor** using synthesizable Verilog-2001.

The processor follows a modular architecture consisting of independent RTL components for instruction fetching, instruction decoding, execution, memory access, and write-back.

It incorporates essential pipeline mechanisms such as:

- Data forwarding and dependency resolution.
- Load-use hazard detection and pipeline stalling.
- Branch and jump handling with pipeline flushing.
- Separate instruction and data memories.
- Pipeline registers with valid-bit management.

The project goes beyond RTL development and functional simulation. The processor was synthesised using **Yosys**, physically implemented using **OpenROAD**, and taken through the RTL-to-GDSII flow using the **SKY130HD standard-cell library**.

<details>
<summary><strong>Project at a glance</strong></summary>

| Attribute | Description |
|---|---|
| Processor architecture | MIPS32 |
| Data width | 32-bit |
| Pipeline | Five stages |
| RTL language | Verilog-2001 |
| Design style | Modular RTL |
| Simulation | Icarus Verilog |
| Synthesis | Yosys |
| Physical design | OpenROAD |
| Technology | SKY130HD |
| Final output | GDSII layout |
| Top module | `mips32_pipeline` |

</details>

---

## 📚 Table of Contents

| No. | Section |
|:---:|---|
| 01 | [Architecture and Pipeline Organisation](#-1-architecture-and-pipeline-organisation) |
| 02 | [Supported Instruction Set](#-2-supported-instruction-set) |
| 03 | [Hazard Detection and Resolution](#-3-hazard-detection-and-resolution) |
| 04 | [RTL Module Organisation](#-4-rtl-module-organisation) |
| 05 | [Instruction Memory and Program Modification](#-5-instruction-memory-and-program-modification) |
| 06 | [Simulation and Verification](#-6-simulation-and-verification) |
| 07 | [Synthesis](#-7-synthesis) |
| 08 | [RTL-to-GDSII Physical Design](#-8-rtl-to-gdsii-physical-design-flow) |
|
