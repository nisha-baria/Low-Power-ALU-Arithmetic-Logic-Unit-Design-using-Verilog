# Low-Power Parameterizable ALU Design using Verilog

## 📌 Project Overview
This repository contains the hardware design of an industry-oriented, parameterizable (8/16/32-bit) Synchronous Arithmetic Logic Unit (ALU) implemented in synthesizable Verilog.The core architecture focuses on optimizing **Power-Performance-Area (PPA)** metrics by integrating advanced architectural low-power techniques:
* **Operand Isolation:** Eliminates unnecessary dynamic switching activity inside inactive functional blocks by gating their inputs.
* **RTL Clock Gating:** Utilizes explicit sequential clock-enables to infer Integrated Clock Gating (ICG) cells during synthesis.
* **Low-Power Mode Hook:** Includes an architectural hint (`lp_mode`) for execution cycles with strict power constraints (e.g., restricting shifter toggles).

The design is fully verified using an automated, self-checking Verilog testbench environment linked against a gold behavioral reference model.

## 🚀 Key Features & Specifications
* **Parameterizable Word Width:** Default configured to 32-bit, easily tunable to 8-bit or 16-bit.
* **Comprehensive Instruction Set:** Supports arithmetic operations (ADD, SUB), logical operations (AND, OR, XOR, NOR), structural shifts (SLL, SRL, SRA), and comparisons (SLT).
* **Status Flag Generation:** Real-time generation of standard status registers: Zero (Z), Sign/Negative (N), Carry-out (C), and Overflow (V).
* **Architectural Power Hooks:** Integrated operand-isolation decoders and output state registers that hold values during idle cycles to suppress downstream toggles.

## 📁 Repository Structure
```text
Low-Power-ALU-Verilog/
├── rtl/               # Synthesizable RTL Source Files (alu.v, adder.v)
├── tb/                # Self-Checking Automated Testbench (alu_tb.v)
├── waveforms/         # EPWave Simulation Waveform Captures
├── reports/           # Simulation Run Reports & Log Summaries
└── .gitignore         # Ignores tool-generated temporary file types

### 📊 ALU Core Opcode & Operation Map

| Opcode (OPC) | Operation | Core Functionality | Active Flags | Low-Power Behavior |
| :---: | :---: | :--- | :---: | :--- |
| `4'b0000` | **ADD** | Arithmetic Addition | Z, N, C, V | Activates Adder Only; Isolates Shifter/Logic |
| `4'b0001` | **SUB** | Arithmetic Subtraction | Z, N, C, V | Passes inverted operand to gated adder block |
| `4'b0010` | **AND** | Bitwise Logical AND | Z, N | Activates Logic Block Only; Adder inputs gated |
| `4'b0011` | **OR** | Bitwise Logical OR | Z, N | Activates Logic Block Only; Adder inputs gated |
| `4'b0100` | **XOR** | Bitwise Logical XOR | Z, N | Activates Logic Block Only; Adder inputs gated |
| `4'b0101` | **NOR** | Bitwise Logical NOR | Z, N | Activates Logic Block Only; Adder inputs gated |
| `4'b0110` | **SLL** | Shift Left Logical | Z, N | Masked to 1-bit shift step if `lp_mode` is active |
| `4'b0111` | **SRL** | Shift Right Logical | Z, N | Masked to 1-bit shift step if `lp_mode` is active |
| `4'b1000` | **SRA** | Shift Right Arithmetic | Z, N | Masked to 1-bit shift step if `lp_mode` is active |
| `4'b1001` | **SLT** | Signed Less Than | Z, N | Activates dedicated comparator structure |
| `4'b1010` | **PASS A** | Direct Pass Input A | Z, N | Bypasses all processing units to avoid toggling |
| `4'b1011` | **PASS B** | Direct Pass Input B | Z, N | Bypasses all processing units to avoid toggling |

## 💻 Simulation & Verification FlowThe design has been successfully simulation-verified via open-source tools using Icarus Verilog and EPWave on EDA Playground. 

How to Run Locally

If you wish to compile and simulate using an open-source local toolchain, run:

# Compile design and testbench modules
iverilog -g2012 -o alu_sim tb/alu_tb.v rtl/alu.v rtl/adder.v

# Execute the compiled binary to generate VCD dumps
vvp alu_sim

Verification Waveform Proof
Below is the verification capture from the automated validation suite:

Key Waveform Observations:
1. Clock Gating/Register Enable: When en = 0 (towards the end of execution), the output Y holds its state firmly despite inputs A and B changing, demonstrating state isolation. 
2. Dynamic Gating Verification: Functional blocks are completely silent when their respective opcodes are unselected, optimizing the average switching activity.

## 📈 Verification Status & Results

* Functional Test Vectors: 100% test coverage with randomized stimulus checking across all 12 operational modes.
* Self-Checking Status: PASSED (Verified successfully against the golden behavioral reference model without logic mismatch errors).
