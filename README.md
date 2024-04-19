# 5-Stage-Pipelined-CPU

This projects introduces the idea of the pipelining technique for building a fast CPU. 
Design implementation and testing of the five-stage pipelined CPU (Instruction Fetch, Instruction Decode ) using the Xilinx design package for Field Programmable Gate Arrays (FPGAs)

**Device: XC7Z010-CLG400-1**

**1. Pipelining**

Pipelining is an implementation technique in which multiple instructions are overlapped in execution. The five stage pipelined CPU allows overlapping execution of multiple instructions. Although an instruction takes five clock cycle to pass through the pipeline, a new instruction can enter the pipeline during every clock cycle. 

Under ideal circumstances, the pipelined CPU can produce a result in every clock cycle. Because in a pipelined CPU there are multiple operations in each clock cycle, we must save the temporary results in each pipeline stage into pipeline registers for use in the follow-up stages. 

We have five stages: IF, ID, EXE, MEM, and WB. The PC can be considered as the first pipeline register at the beginning of the first stage. We name the other pipeline registers as IF/ID, ID/EXE, EXE/MEM, and MEM/WB in sequence. In order to understand in depth how the pipelined CPU works, we will show the circuits that are required in each pipeline stage of a baseline CPU.

 
**2. Circuits of the Instruction Fetch Stage**

![Typing-Chart](https://github.com/zbl5332/5-Stage-Pipelined-CPU/blob/008a7ebafd4a2666f68b94658828cf95d161d2b6/Typing-Chart.png)

In the first clock cycle in Figure 1(b), the first lw instruction is being fetched. 

In the IF stage, there is an instruction memory module and an adder between two pipeline registers. The left most pipeline register is the PC; it holds 100. 

In the end of the first cycle (at the rising edge of clk), the instruction fetched from instruction memory is written into the IF/ID register. 

Meanwhile, the output of the adder (PC + 4, the next PC) is written into PC. 

**3. Circuits of the Instruction Decode Stage**

It is in the second cycle, the first instruction entered the ID stage. 

There are two jobs in the second cycle: to decode the first instruction in the ID stage, and to fetch the second instruction in the IF stage. The two instructions are shown on the top of the figures: the first instruction is in the ID stage, and the second instruction is in the IF stage. 

The first instruction in the ID stage comes from the IF/ID register. Two operands are read from the register file (Regfile in the figure) based on rs and rt, although the lw instruction does not use the operand in the register rt. The immediate (imm) is sign- extended into 32 bits. 

The regrt signal is used in the ID stage that selects the destination register number; all others must be written into the ID/EXE register for later use. At the end of the second cycle, all the data and control signals, except for regrt, in the ID stage are written into the ID/EXE register. At the same time, the PC and the IF/ID register are also updated.

**4. Circuits of the Execution Stage**

It is in the third cycle the first instruction entered the EXE stage. 

The ALU performs addition, and the multiplexer selects the immediate. A letter “e” is prefixed to each control signal in order to distinguish it from that in the ID stage. 

The second instruction is being decoded in the ID stage and the third instruction is being fetched in the IF stage. All the four pipeline registers are updated at the end of the cycle. 

**5. Circuits of the Memory Access Stage**

It is in the fourth cycle of the first instruction entered the MEM stage. 

The only task in this stage is to read data memory. All the control signals have a prefix “m”.

The second instruction entered the EXE stage; the third instruction is being decoded in the ID stage; and the fourth instruction is being fetched in the IF stage. All the five pipeline registers are updated at the end of the cycle.

**6. Circuits of the Write Back Stage**

It is in the fifth cycle the first instruction entered the WB stage. 

The memory data is selected and will be written into the register file at the end of the cycle. All the control signal have a prefix “w”. The second instruction entered the MEM stage; the third instruction entered the EXE stage; the fourth instruction is being decoded in the ID stage; and the fifth instruction is being fetched in the IF stage. All the six pipeline registers are updated at the end of the cycle (the destination register is considered as the six pipeline register). 

Then the first instruction is committed. In each of the forth coming clock cycles, an instruction will be commited and a new instruction will enter the pipeline. 

**We use the structure shown below as a baseline for the design of our pipelined CPU**

![Stages](https://github.com/zbl5332/5-Stage-Pipelined-CPU/blob/008a7ebafd4a2666f68b94658828cf95d161d2b6/Stages.png)

**Floor Planning**

![Floor-Planning](https://github.com/zbl5332/5-Stage-Pipelined-CPU/blob/662acf7cf58baf81e4e155c1ff2ac066337c6e9b/Floor-Planning.png)

**I/O Planning**

![I/O-Planning](https://github.com/zbl5332/5-Stage-Pipelined-CPU/blob/662acf7cf58baf81e4e155c1ff2ac066337c6e9b/I%3AO-Planning.png)

**Design Schematic**

![Design-Schematic](https://github.com/zbl5332/5-Stage-Pipelined-CPU/blob/662acf7cf58baf81e4e155c1ff2ac066337c6e9b/Design-Schematic.png)

**Waveforms**

![Waveforms](https://github.com/zbl5332/5-Stage-Pipelined-CPU/blob/662acf7cf58baf81e4e155c1ff2ac066337c6e9b/Waveforms.png)