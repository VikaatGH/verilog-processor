# Verilog-Processor
This project implements a 32-bit single-cycle RISC-V processor using Verilog. The processor supports a standard subset of RISC-V instructions and includes a custom instruction, floor_log, which computes the floor of the base-2 logarithm of a register's value. To demonstrate the functionality of the processor and the custom instruction, the project also includes an Assembly language program that calculates the floor_log of each element in an array.

## Features
- 32-bit instruction set
- Support for RISC-V base instructions (I-type, R-type, S-type, B-type, U-type, and J-type) and floor_log
- Single-cycle execution
- Memory-mapped I/O support for load/store operations

## Modules Implemented
1. PC Register (program counter)
2. 32-bit Register Array
3. ALU (Arithmetic Logic Unit)
4. Control Unit
5. Multiplexers
6. Immediate Decode Module, extracts and extends immediate values from instructions.

## Instruction Set Table

|  Instruction    |  Operace                                                       |  Encoding                                        |
|-----------------|----------------------------------------------------------------|--------------------------------------------------|
|  **add**        |  rd ← [rs1] + [rs2]                                            |  0000000	rs2	rs1	000	rd	0110011                 |
|                 |                                                                |                                                  |
|  **addi**       |  rd ← [rs1] + imm11:0                                          |  imm[11:0]	rs1	000	rd	0010011                   |
|                 |                                                                |                                                  |
|  **and**        |  rd ← [rs1] & [rs2]                                            |  0000000	rs2	rs1	111	rd	0110011                 |
|                 |                                                                |                                                  |
|  **sub**        |  rd ← [rs1] - [rs2]                                            |  0100000	rs2	rs1	000	rd	0110011                 |
|                 |                                                                |                                                  |
|  **srl**        |  rd ← (unsigned)[rs1] >> [rs2]                                 |  0000000	rs2	rs1	101	rd	0110011                 |
|                 |                                                                |                                                  |
|  **beq**        |  if [rs1] == [rs2] go to [PC]+{imm12:1,'0'}; else go to [PC]+4 |  imm[12\|10:5]	rs2	rs1	000	imm[4:1\|11]	1100011   | 
|                 |                                                                |                                                  |
|  **blt**        |  if [rs1] < [rs2] go to [PC]+{imm12:1,'0'}; else go to [PC]+4  |  imm[12\|10:5]	rs2	rs1	100	imm[4:1\|11]	1100011   |
|                 |                                                                |                                                  |
|  **lw**         |  rd ← Memory[[rs1] + imm11:0]                                  |  imm[11:0]	rs1	010	rd	0000011                   |
|                 |                                                                |                                                  |
|  **sw**         |  Memory[[rs1] + imm11:0] ← [rs2]                               |  imm[11:5]	rs2	rs1	010	imm[4:0]	0100011         |
|                 |                                                                |                                                  |
|  **lui**        |  rd ← {imm31:12,'0000 0000 0000'}                              |  imm[31:12]	rd	0110111                         |
|                 |                                                                |                                                  |
|  **jal**        |  rd ← [PC]+4; go to [PC] +{imm20:1,'0'}                        |  imm[20\|10:1\|11\|19:12]	rd	1101111               |
|                 |                                                                |                                                  |
|  **jalr**       |  rd ← [PC]+4; go to [rs1]+imm11:0                              |  imm[11:0]	rs1	000	rd	1100111                   |
|                 |                                                                |                                                  |
|  **floor_log**  |  rd ← (int)floor(log2(rs1))                                    |  000000000000	rs1	000	rd	0001011               |

## Floor_log
The floor_log instruction calculates the floor of the base-2 logarithm of a register value. It uses the exponent from the floating-point format, specifically subtracting 127 (the bias in IEEE 754 single-precision).

## Program Description
This program takes an array of floating-point numbers and calculates the floor of the base-2 logarithm (floor(log2(x))) for each number. The results are saved back in the same array. It follows RISC-V rules for function calls.
