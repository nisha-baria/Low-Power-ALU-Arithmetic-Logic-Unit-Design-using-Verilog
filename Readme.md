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

## 📊 ALU Core Opcode & Operation Map

<table style="width:100%; border-collapse: collapse; text-align: left; font-family: sans-serif;">
  <thead>
    <tr style="background-color: #1f4287; color: white;">
      <th style="padding: 12px; border: 1px solid #ddd;">Opcode (OPC)</th>
      <th style="padding: 12px; border: 1px solid #ddd;">Operation</th>
      <th style="padding: 12px; border: 1px solid #ddd;">Core Functionality</th>
      <th style="padding: 12px; border: 1px solid #ddd;">Active Flags</th>
      <th style="padding: 12px; border: 1px solid #ddd;">Low-Power Behavior</th>
    </tr>
  </thead>
  <tbody>
    <tr style="background-color: #f8f9fa;">
      <td style="padding: 10px; border: 1px solid #ddd;"><b>4'b0000</b></td>
      <td style="padding: 10px; border: 1px solid #ddd; color: #007bff;"><b>ADD</b></td>
      <td style="padding: 10px; border: 1px solid #ddd;">Arithmetic Addition</td>
      <td style="padding: 10px; border: 1px solid #ddd;">Z, N, C, V</td>
      <td style="padding: 10px; border: 1px solid #ddd; color: #28a745;">Activates Adder Only; Isolates Shifter/Logic</td>
    </tr>
    <tr>
      <td style="padding: 10px; border: 1px solid #ddd;"><b>4'b0001</b></td>
      <td style="padding: 10px; border: 1px solid #ddd; color: #007bff;"><b>SUB</b></td>
      <td style="padding: 10px; border: 1px solid #ddd;">Arithmetic Subtraction</td>
      <td style="padding: 10px; border: 1px solid #ddd;">Z, N, C, V</td>
      <td style="padding: 10px; border: 1px solid #ddd; color: #28a745;">Passes inverted operand to gated adder block</td>
    </tr>
    <tr style="background-color: #f8f9fa;">
      <td style="padding: 10px; border: 1px solid #ddd;"><b>4'b0010</b></td>
      <td style="padding: 10px; border: 1px solid #ddd; color: #e83e8c;"><b>AND</b></td>
      <td style="padding: 10px; border: 1px solid #ddd;">Bitwise Logical AND</td>
      <td style="padding: 10px; border: 1px solid #ddd;">Z, N</td>
      <td style="padding: 10px; border: 1px solid #ddd; color: #28a745;">Activates Logic Block Only; Adder inputs gated</td>
    </tr>
    <tr>
      <td style="padding: 10px; border: 1px solid #ddd;"><b>4'b0011</b></td>
      <td style="padding: 10px; border: 1px solid #ddd; color: #e83e8c;"><b>OR</b></td>
      <td style="padding: 10px; border: 1px solid #ddd;">Bitwise Logical OR</td>
      <td style="padding: 10px; border: 1px solid #ddd;">Z, N</td>
      <td style="padding: 10px; border: 1px solid #ddd; color: #28a745;">Activates Logic Block Only; Adder inputs gated</td>
    </tr>
    <tr style="background-color: #f8f9fa;">
      <td style="padding: 10px; border: 1px solid #ddd;"><b>4'b0100</b></td>
      <td style="padding: 10px; border: 1px solid #ddd; color: #e83e8c;"><b>XOR</b></td>
      <td style="padding: 10px; border: 1px solid #ddd;">Bitwise Logical XOR</td>
      <td style="padding: 10px; border: 1px solid #ddd;">Z, N</td>
      <td style="padding: 10px; border: 1px solid #ddd; color: #28a745;">Activates Logic Block Only; Adder inputs gated</td>
    </tr>
    <tr>
      <td style="padding: 10px; border: 1px solid #ddd;"><b>4'b0101</b></td>
      <td style="padding: 10px; border: 1px solid #ddd; color: #e83e8c;"><b>NOR</b></td>
      <td style="padding: 10px; border: 1px solid #ddd;">Bitwise Logical NOR</td>
      <td style="padding: 10px; border: 1px solid #ddd;">Z, N</td>
      <td style="padding: 10px; border: 1px solid #ddd; color: #28a745;">Activates Logic Block Only; Adder inputs gated</td>
    </tr>
    <tr style="background-color: #f8f9fa;">
      <td style="padding: 10px; border: 1px solid #ddd;"><b>4'b0110</b></td>
      <td style="padding: 10px; border: 1px solid #ddd; color: #fd7e14;"><b>SLL</b></td>
      <td style="padding: 10px; border: 1px solid #ddd;">Shift Left Logical</td>
      <td style="padding: 10px; border: 1px solid #ddd;">Z, N</td>
      <td style="padding: 10px; border: 1px solid #ddd; color: #dc3545;">Masked to 1-bit shift step if lp_mode is active</td>
    </tr>
    <tr>
      <td style="padding: 10px; border: 1px solid #ddd;"><b>4'b0111</b></td>
      <td style="padding: 10px; border: 1px solid #ddd; color: #fd7e14;"><b>SRL</b></td>
      <td style="padding: 10px; border: 1px solid #ddd;">Shift Right Logical</td>
      <td style="padding: 10px; border: 1px solid #ddd;">Z, N</td>
      <td style="padding: 10px; border: 1px solid #ddd; color: #dc3545;">Masked to 1-bit shift step if lp_mode is active</td>
    </tr>
    <tr style="background-color: #f8f9fa;">
      <td style="padding: 10px; border: 1px solid #ddd;"><b>4'b1000</b></td>
      <td style="padding: 10px; border: 1px solid #ddd; color: #fd7e14;"><b>SRA</b></td>
      <td style="padding: 10px; border: 1px solid #ddd;">Shift Right Arithmetic</td>
      <td style="padding: 10px; border: 1px solid #ddd;">Z, N</td>
      <td style="padding: 10px; border: 1px solid #ddd; color: #dc3545;">Masked to 1-bit shift step if lp_mode is active</td>
    </tr>
    <tr>
      <td style="padding: 10px; border: 1px solid #ddd;"><b>4'b1001</b></td>
      <td style="padding: 10px; border: 1px solid #ddd; color: #6f42c1;"><b>SLT</b></td>
      <td style="padding: 10px; border: 1px solid #ddd;">Signed Less Than Comparison</td>
      <td style="padding: 10px; border: 1px solid #ddd;">Z, N</td>
      <td style="padding: 10px; border: 1px solid #ddd; color: #28a745;">Activates dedicated comparator structure</td>
    </tr>
    <tr style="background-color: #f8f9fa;">
      <td style="padding: 10px; border: 1px solid #ddd;"><b>4'b1010</b></td>
      <td style="padding: 10px; border: 1px solid #ddd; color: #6c757d;"><b>PASS A</b></td>
      <td style="padding: 10px; border: 1px solid #ddd;">Direct Pass Input A</td>
      <td style="padding: 10px; border: 1px solid #ddd;">Z, N</td>
      <td style="padding: 10px; border: 1px solid #ddd; color: #dc3545;">Bypasses all processing units to avoid toggling</td>
    </tr>
    <tr>
      <td style="padding: 10px; border: 1px solid #ddd;"><b>4'b1011</b></td>
      <td style="padding: 10px; border: 1px solid #ddd; color: #6c757d;"><b>PASS B</b></td>
      <td style="padding: 10px; border: 1px solid #ddd;">Direct Pass Input B</td>
      <td style="padding: 10px; border: 1px solid #ddd;">Z, N</td>
      <td style="padding: 10px; border: 1px solid #ddd; color: #dc3545;">Bypasses all processing units to avoid toggling</td>
    </tr>
  </tbody>
</table>

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