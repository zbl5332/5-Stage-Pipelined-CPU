`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Name: Joseph Lin
// Date: 04/14/2024
// Project Name: 5-Stage-Pipelined-CPU
// Module Name: testbench
//////////////////////////////////////////////////////////////////////////////////


module testbench();
    reg clk_tb;
    
    wire [31:0] pc;
    wire [31:0] dinstOut;
    wire ewreg;
    wire em2reg;
    wire ewmem;
    wire [3:0] ealuc;
    wire ealuimm;
    wire [4:0] edestReg;
    wire [31:0] eqa;
    wire [31:0] eqb;
    wire [31:0] eimm32;
    
    wire mwreg; 
    wire mm2reg; 
    wire mwmem;
    wire [4:0] mdestReg;
    wire [31:0] mr; 
    wire [31:0] mqb;
    
    wire wwreg; 
    wire wm2reg;
    wire [4:0] wdestReg;
    wire [31:0] wr;
    wire [31:0] wdo;
    wire [31:0] wbData;
    
    Datapath Datapath_tb(clk_tb, pc, dinstOut, ewreg, em2reg, ewmem, ealuimm, ealuc, edestReg, eqa, eqb, eimm32, mwreg, mm2reg, mwmem, mdestReg, mr, mqb, wwreg, wm2reg, wdestReg, wr, wdo, wbData);
    
    initial begin
        clk_tb = 1'b0;
    end
    
    always
    begin
        #5
        clk_tb = ~clk_tb;
    end
    
endmodule
