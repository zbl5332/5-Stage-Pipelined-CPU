# 5-Stage-Pipelined-CPU
This projects introduces the idea of the pipelining technique for building a fast CPU. 
Design implementation and testing of the five-stage pipelined CPU (Instruction Fetch, Instruction Decode ) using the Xilinx design package for Field Programmable Gate Arrays (FPGAs)

**1. Pipelining**

Pipelining is an implementation technique in which multiple instructions are overlapped in execution. The fivestage pipelined CPU allows overlapping execution of multiple instructions. Although an instruction takes five clock cycle to pass through the pipeline, a new instruction can enter the pipeline during every clock cycle. 

Under ideal circumstances, the pipelined CPU can produce a result in every clock cycle. Because in a pipelined CPU there are multiple operations in each clock cycle, we must save the temporary results in each pipeline stage into pipeline registers for use in the follow-up stages. 

We have five stages: IF, ID, EXE, MEM, and WB. The PC can be considered as the first pipeline register at the beginning of the first stage. We name the other pipeline registers as IF/ID, ID/EXE, EXE/MEM, and MEM/WB in sequence. In order to understand in depth how the pipelined CPU works, we will show the circuits that are required in each pipeline stage of a baseline CPU.
 
**2. Circuits of the Instruction Fetch Stage**

The circuit in the IF stage are shown in Figure 2. Also, looking at the first clock cycle in Figure 1(b), the first lw instruction is being fetched. In the IF stage, there is an instruction memory module and an adder between two pipeline registers. The left most pipeline register is the PC; it holds 100. In the end of the first cycle (at the rising edge of clk), the instruction fetched from instruction memory is written into the IF/ID register. Meanwhile, the output of the adder (PC + 4, the next PC) is written into PC. 

**3. Circuits of the Instruction Decode Stage**

Referring to Figure 3, in the second cycle, the first instruction entered the ID stage. There are two jobs in the second cycle: to decode the first instruction in the ID stage, and to fetch the second instruction in the IF stage. The two instructions are shown on the top of the figures: the first instruction is in the ID stage, and the second instruction is in the IF stage. The first instruction in the ID stage comes from the IF/ID register. Two operands are 
read from the register file (Regfile in the figure) based on rs and rt, although the lw instruction does not use the operand in the register rt. The immediate (imm) is sign- extended into 32 bits. The regrt signal is used in the ID stage that selects the destination register number; all others must be written into the ID/EXE register for later use. 
At the end of the second cycle, all the data and control signals, except for regrt, in the ID stage are written into the ID/EXE register. At the same time, the PC and the IF/ID register are also updated.

