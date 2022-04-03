`include "flopr.v"
`include "adder.v"
`include "sl2.v"
`include "mux2.v"
`include "regfile.v"
`include "signext.v"
`include "alu.v"
module datapath(

    clk,reset,
    memtoreg,pcsrc,
    alusrc,regdst,
    regwrite,jump,
    alucontrol,shamt_c,
    zero,
    pc,
    instr,
    alu_result,writedata,
    readdata,pcnext
);

//in out parameters


input wire clk,reset;
input wire memtoreg,pcsrc,alusrc,regdst,regwrite,jump;
input wire[3:0] alucontrol;
input wire shamt_c; // new instr


input wire[31:0] instr;// 指令
input wire [31:0] readdata;

output wire zero;
output wire[31:0] pc,pcnext;
output wire[31:0] alu_result,writedata;




//local params

wire [4:0] wirtereg;

wire [31:0] pcnextbr,pcplus4,pcbranch;
wire [31:0] signimm,signimmsh;
wire [31:0] srca,srcb;
wire [31:0] result;
wire [31:0] regfile_rd1;


flopr #(.WIDTH (32)) pcreg(clk,reset,pcnext,pc);

adder pcadder(pc,32'b100,pcplus4);

signext sg(instr[15:0],signimm);
sl2 immsl2(signimm,signimmsh);
adder pcadd2(pcplus4,signimmsh,pcbranch);
mux2#(.WIDTH (32)) pcbranchmux(pcplus4,pcbranch,pcsrc,pcnextbr);
mux2#(.WIDTH (32)) pcmux2(pcnextbr,{pcplus4[31:28],instr[25:0],2'b00},
                    jump,pcnext);
    
/*

module regfile (

    reg_clk,regwrite,
    read_1,read_2,write_3,
    read_data_p1,read_data_p2,
    write_data_p3,


);

*/
mux2 #(5)  wirteregmux(instr[20:16],instr[15:11],regdst,wirtereg);
regfile regfile1(clk,regwrite,instr[25:21],instr[20:16],wirtereg,
                    result,regfile_rd1,writedata);
mux2 #(32) resultmux(alu_result,readdata,memtoreg,result);
mux2 #(32) alumux(writedata,signimm,alusrc,srcb);

mux2 #(32) muxkkk(regfile_rd1,{{27{instr[10]}},instr[10:6]},shamt_c,srca);

alu alu1(srca,srcb,alucontrol,alu_result,zero);

endmodule

