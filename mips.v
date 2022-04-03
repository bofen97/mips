`include "controller.v"
`include "datapath.v"
module mips(

    clk,reset,
    pc,pcnext,instr,
    memwrite,
    aluout,writedata,
    readdata
);

input wire clk,reset;
input wire[31:0] instr;
input wire[31:0] readdata;

output wire[31:0] pc;
output wire memwrite;
output wire[31:0]  aluout,writedata;



//local params

/*

module controller(

    opcode,funct,
    zero,
    memtoreg,memwrite,
    pcsrc,alusrc,
    regdst,regwrite,
    jump,
    alucontrol
);

*/

wire zero,memtoreg,pcsrc , alusrc,regdst,regwrite,jump;
wire [3:0] alucontrol;
wire shamt_c;


output wire[31:0] pcnext; 
controller ct(
    instr[31:26],instr[5:0],
    zero,memtoreg,memwrite,
    pcsrc,alusrc,regdst,regwrite,
    jump,alucontrol,shamt_c
);

/*
module datapath(

    clk,reset,
    memtoreg,pcsrc,
    alusrc,regdst,
    regwrite,jump,
    alucontrol,
    zero,
    pc,
    instr,
    aluout,writedata,
    readdata
);
*/

datapath dp(
    clk,reset,
    memtoreg,pcsrc,
    alusrc,regdst,
    regwrite,jump,
    alucontrol,shamt_c,
    zero,
    pc,
    instr,
    aluout,writedata,
    readdata,pcnext
);




endmodule