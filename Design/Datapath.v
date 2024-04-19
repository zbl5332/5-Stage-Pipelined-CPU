`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Name: Joseph Lin
// Date: 04/18/2024
// Project Name: 5-Stage-Pipelined-CPU
// Module Name: Datapath
//////////////////////////////////////////////////////////////////////////////////


module Datapath(
    input clk,
    
    output wire [31:0] pc,
    output wire [31:0] dinstOut,
    output wire ewreg,
    output wire em2reg,
    output wire ewmem,
    output wire ealuimm,
    output wire [3:0] ealuc,
    output wire [4:0] edestReg,
    output wire [31:0] eqa,
    output wire [31:0] eqb,
    output wire [31:0] eimm32,
    
    output wire mwreg,
    output wire mm2reg, 
    output wire mwmem,
    output wire [4:0] mdestReg,
    output wire [31:0] mr, 
    output wire [31:0] mqb,
    
    output wire wwreg, 
    output wire wm2reg, 
    output wire [4:0] wdestReg,
    output wire [31:0] wr, 
    output wire [31:0] wdo,
    output wire [31:0] wbData
);
    
    wire [31:0] nextPc;
    ProgramCounter ProgramCounter(nextPc, clk, pc);
    
    PcAdder PcAdder(pc, nextPc);
    
    wire [31:0] instOut;
    InstructionMemory InstructionMemory(pc, instOut);
    
    IfidPipelineReg IfidPipelineReg(instOut, clk, dinstOut);
    
    wire [5:0] op = dinstOut[31:26];
    wire [5:0] func = dinstOut[5:0];
    wire wreg;
    wire m2reg;
    wire wmem;
    wire aluimm;
    wire regrt;
    wire [3:0] aluc;
    ControlUnit ControlUnit(op, func, wreg, m2reg, wmem, aluc, aluimm, regrt);
    
    wire [4:0] rs = dinstOut[25:21];
    wire [4:0] rt = dinstOut[20:16];
    wire [4:0] rd = dinstOut[15:11];
    wire [4:0] destReg;
    RegrtMux RegrtMux(rt, rd, regrt, destReg);
    
    wire [31:0] qa;
    wire [31:0] qb;
    RegFile RegFile(rs, rt, wdestReg, wbData, wwreg, clk, qa, qb);
    
    wire [15:0] imm = dinstOut[15:0];
    wire [31:0] imm32;
    ImmediateExtender ImmediateExtender(imm, imm32);
    
    IDEXEPipelineReg IDEXEPipelineReg(wreg, m2reg, wmem, aluc, aluimm, destReg, qa, qb, imm32, clk, ewreg, em2reg, ewmem, ealuc, ealuimm, edestReg, eqa, eqb, eimm32);
    
    wire [31:0] b;
    AluMux AluMux(eqb, eimm32, ealuimm, b);
    
    wire [31:0] r;
    Alu Alu(eqa, b, ealuc, r);
    
    EXEMEMPipelineReg EXEMEMPipelineReg(ewreg, em2reg, ewmem, edestReg, r, eqb, clk, mwreg, mm2reg, mwmem, mdestReg, mr, mqb);
    
    wire [31:0] mdo;
    DataMemory DataMemory(mr, mqb, mwmem, clk, mdo);
    
    MEMWBPipelineReg MEMWBPipelineReg(mwreg, mm2reg, mdestReg, mr, mdo, clk, wwreg, wm2reg, wdestReg, wr, wdo); 
    
    WbMux WbMux(wr, wdo, wm2reg, wbData);
    
endmodule


module ProgramCounter(

    input [31:0] nextPc,
    input clk,
    output reg [31:0] pc
);
    
    initial begin
        pc = 32'd100;   
    end      
    
    always @(posedge clk)
    begin
        pc = nextPc;
    end
    
endmodule


module InstructionMemory(

    input [31:0] pc,
    output reg [31:0] instOut
);
    reg[31:0] memory[63:0];
    
    initial begin
        memory[25] <= {6'b100011, 5'b00001, 5'b00010, 5'b00000, 5'b00000, 6'b000000};
        memory[26] <= {6'b100011, 5'b00001, 5'b00011, 5'b00000, 5'b00000, 6'b000100};
    
    end
    
    always @(*)
    begin
        instOut = memory[pc[7:2]];
    end
    
endmodule


module PcAdder(

    input [31:0] pc,
    output reg [31:0] nextPc
);

    always @(*)
    begin
        nextPc = pc + 4;
    end
    
endmodule


module IfidPipelineReg(

    input [31:0]instOut,
    input clk,
    output reg [31:0] dinstOut
); 
    
    always @(posedge clk)
    begin
        dinstOut <= instOut;
    end
    
endmodule


module ControlUnit(
    
    input [5:0] op, 
    input [5:0] func,
    output reg wreg, 
    output reg m2reg, 
    output reg wmem, 
    output reg [3:0] aluc, 
    output reg aluimm, 
    output reg regrt
);


    always @(*)
    begin
        case(op)
            6'b000000: //r-type
            begin
                wreg = 1'b1;
                m2reg = 1'b0;
                wmem = 1'b0;
                aluimm = 1'b0;
                regrt = 1'b0;
                case(func)
                    6'b100000: //add instruction
                    begin
                        aluc = 4'b0010;
                    end
                    6'b100010: //sub instruction
                    begin
                        aluc = 4'b0110;
                    end
                endcase
            end
            6'b100011: //lw
            begin
                wreg   = 1'b1;
                m2reg  = 1'b1;
                wmem   = 1'b0;
                aluc   = 4'b0010;
                aluimm = 1'b1;
                regrt  = 1'b1;
            end
        endcase
    end
    
endmodule    
    
    
module RegrtMux(

    input [4:0] rt,
    input [4:0] rd,
    input regrt,
    output reg [4:0] destReg
);

    always @(*)
    begin
        if(regrt == 0) begin
            destReg = rd;
        end
        else begin
            destReg = rt;
        end
    end

endmodule


module RegFile(

    input [4:0] rs,
    input [4:0] rt,
    input [4:0] wdestReg,
    input [31:0] wbData,
    input wwreg,
    input clk,
    
    output reg [31:0] qa,
    output reg [31:0] qb
);

    reg [31:0] registers[0:31];
    
    integer i; 

    initial begin
        // Initialize all registers to 0
        for(i = 0; i < 32; i = i + 1) 
        begin
            registers[i] = 32'b0;
        end
    end
    
    always @(*)
    begin
        qa = registers[rs];
        qb = registers[rt];
    end
    
    always @(negedge clk)
    begin
        if (wwreg == 1)
            registers[wdestReg] = wbData;
    end
    
endmodule


module ImmediateExtender(

    input [15:0] imm,
    output reg [31:0] imm32
);

    always @(*)
    begin
        imm32 = {{16{imm[15]}}, imm};
    end
    
endmodule

   
module IDEXEPipelineReg(
    input wreg,
    input m2reg,
    input wmem,
    input [3:0] aluc,
    input aluimm,
    input [4:0] destReg,
    input [31:0] qa,
    input [31:0] qb,
    input [31:0] imm32,
    input clk,
    
    output reg ewreg,
    output reg em2reg,
    output reg ewmem,
    output reg [3:0] ealuc,
    output reg ealuimm,
    output reg [4:0] edestReg,
    output reg [31:0] eqa,
    output reg [31:0] eqb,
    output reg [31:0] eimm32
);    
    
    always @(posedge clk)
    begin
        ewreg = wreg;
        em2reg = m2reg;
        ewmem = wmem;
        ealuc = aluc;
        ealuimm = aluimm;
        edestReg = destReg;
        eqa = qa;
        eqb = qb;
        eimm32 = imm32;
    end
    
endmodule

module AluMux(
    input [31:0] eqb,
    input [31:0] eimm32,
    input ealuimm,
    
    output reg [31:0] b
);
    
    always @(*)
    begin
        if (ealuimm == 0)
            b = eqb;
        else
            b = eimm32;
    end

endmodule    


module Alu(
    input [31:0] eqa,
    input [31:0] b,
    input [3:0] ealuc,
    
    output reg [31:0] r 
);
    
    always @(*)
    begin
       // 0000 = Addition
       // 0001 = Subtraction
       // 0010 = Bitwise AND
       // 0011 = Bitwise OR 
       case (ealuc)
            4'b0000: 
                r = eqa + b; // Addition
            4'b0001: 
                r = eqa - b; // Subtraction
            4'b0010: 
                r = eqa & b; // Bitwise AND
            4'b0011: 
                r = eqa | b; // Bitwise OR
       endcase
    end

endmodule


module EXEMEMPipelineReg(
    input ewreg,
    input em2reg,
    input ewmem,
    input [4:0] edestReg,
    input [31:0] r,
    input [31:0] eqb,
    input clk,
    
    output reg mwreg,
    output reg mm2reg,
    output reg mwmem,
    output reg [4:0] mdestReg,
    output reg [31:0] mr,
    output reg [31:0] mqb 
);
    
    always @(posedge clk)
    begin
       mwreg = ewreg;
       mm2reg = em2reg;
       mwmem = ewmem;
       mdestReg = edestReg;
       mr = r;
       mqb = eqb;
    end

endmodule


module DataMemory(
    input [31:0] mr,
    input [31:0] mqb,
    input mwmem,
    input clk,
    
    output reg [31:0] mdo
);
    reg [31:0] memory[0:31];
    
    initial begin
        memory[0] = 'hA00000AA;
        memory[1] = 'h10000011;
        memory[2] = 'h20000022;
        memory[3] = 'h30000033;
        memory[4] = 'h40000044;
        memory[5] = 'h50000055;
        memory[6] = 'h60000066;
        memory[7] = 'h70000077;
        memory[8] = 'h80000088;
        memory[9] = 'h90000099; 
     end
    
    always @(*)
        mdo = memory[mr[7:2]];
        
    always @(negedge clk)
    begin
        if (mwmem == 1)
        begin
            memory[mr[7:2]] = mqb;
        end
    end

endmodule


module MEMWBPipelineReg (
    input mwreg, 
    input mm2reg,
    input [4:0] mdestReg,
    input [31:0] mr, 
    input [31:0] mdo,
    input clk, 
    
    output reg wwreg, 
    output reg wm2reg, 
    output reg [4:0] wdestReg,
    output reg [31:0] wr, 
    output reg [31:0] wdo
);

    always @(posedge clk)
    begin
        wwreg    = mwreg;
        wm2reg   = mm2reg;
        wdestReg = mdestReg;
        wr       = mr;
        wdo      = mdo;
    end
    
endmodule

module WbMux (
    input [31:0] wr,
    input [31:0] wdo,
    input wm2reg,

    output reg [31:0] wbData
);

    always @(*)
    begin
        if (wm2reg == 0)
            wbData = wr;
        else
            wbData = wdo;
    end
    
endmodule


