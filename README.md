# SCP-RISCV-RV32I

This semester project implements a single cycle RISC V processor. The following instructions are effectively executed:
R-Type	add, sub, xor, or, and, sll
I-Type (ALU)	addi, xori, ori, andi, slli, srli, srai
I-Type (Jump)	jalr
I-Type Load	lb, lh, lw, lbu, lhu
B-Type (Branch)	beq, bne, blt, bge, bltu, bgeu

Datapath for RV32I processor developed:
<img width="900" height="629" alt="image" src="https://github.com/user-attachments/assets/520edefb-5e3c-4bc1-aea6-5c8af87d1aca" />

Functional verification was performed using a custom RISC-V assembly test program compiled to a hexadecimal memory image (program.hex) and loaded into the Instruction Memory at simulation time.

The simulation environment was a Verilog testbench that instantiates the SoC top-level module, applies a clock, and drives a reset signal. 

Outputs observed:
1. console (via $monitor for ease)
2. waveforms generated

A detailed report is attached, summarizing our approach.
