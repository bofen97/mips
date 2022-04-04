`include "flopr.v"
`include "mems.v"
`include "mux2.v"
`include "regfile.v"
`include "signext.v"
`include "sl2.v"
`include "mux4.v"
`include "alu.v"
module mc_datapath(

    clk,reset,
    pc,pcnext,PCEn,
    memoryRD,IRWrite,
    opcode,funct,
    RegWrite,
    RegDst,
    ALUSrcA,
    ALUSrcB,
    ALUControl,
    PCSrc,
    MemToReg,
    IorD,
    Adr,
    memoryWD,
    Zero
    
);

input wire clk,reset;
input wire PCEn ;//pc寄存器写入信号
output wire[31:0] pc,pcnext; //外部需要使用pc pcnext

input wire[31:0] memoryRD; //从指令/数据寄存器写入
input wire IRWrite ; //指令寄存器写入信号

output wire [5:0] opcode,funct; //给外部控制器生成控制信号
input wire RegWrite;
input wire RegDst;//用于选择目的寄存器。 
/*
    对于lw和sw ,lw a b imm,a 是目的寄存器，  sw a b imm，a 是第二个源寄存器
    所以需要dst来选择
*/
input wire ALUSrcA; //用于选择 pc or A
input wire [1:0] ALUSrcB;//用于选择 B 4 signimm signimmsl2
input wire [3:0] ALUControl;
input wire PCSrc;
input wire MemToReg;
input wire IorD;
output wire [31:0] Adr;
output wire [31:0] memoryWD;
output wire Zero;


//local params 
wire [31:0] Instr; //指令寄存器
wire [31:0] Data; //数据寄存器
wire [31:0] WD3,RD1,RD2;//WD3是写入寄存器的数据
wire [4:0] A3;  //写寄存器号
wire [31:0] A,B;
wire [31:0] srcA;
wire [31:0] SignImm; //符号扩展寄存器
wire [31:0] SignImmSl2;//符号扩展左移2位
wire [31:0] srcB;
wire [31:0] ALUResult;
wire [31:0] ALUOut;


flopr_with_signal #(.WIDTH (32)) pc_reg(clk,reset,PCEn,pcnext,pc);

flopr_with_signal #(.WIDTH (32)) instr_reg(clk,reset,IRWrite,memoryRD,Instr);
flopr #(.WIDTH (32)) data_reg(clk,reset,memoryRD,Data);

/*
    在这个设计中，将memory 移动到datapath的外部，这里会准备好A WD 
    clk，mem write信号外部准备，为了测试才选择让pc和pcnext作为输出，
    实际上作为输出Adr就足够去数据/指令存储器来选择指令了。
*/

//从Instr解码

assign opcode = Instr[31:26];
assign funct = Instr[5:0];

//Instr [15:0]
signext signimm_reg(Instr[15:0],SignImm);
sl2 signimmsl2_reg(SignImm,SignImmSl2);



//
mux2 #(.WIDTH (5)) chooseA3(Instr[20:16],Instr[15:11],RegDst,A3);
regfile regfile_main(clk,RegWrite,Instr[25:21],Instr[20:16],A3,WD3,RD1,RD2);
/*
    WD3 的数据来源是Data or ALUOut的计算结果 
*/


flopr #(.WIDTH (32)) a_reg(clk,reset,RD1,A);
flopr #(.WIDTH (32)) b_reg(clk,reset,RD2,B);

/*
srcA 有两个输入，A 或者  pc  。
*/
mux2 #(.WIDTH (32)) choosesrcA(pc,A,ALUSrcA,srcA);

//srcB

mux4 choosesrcB(ALUSrcB,B,32'b0100,SignImm,SignImmSl2,srcB);

//根据alu control 计算结果
//Zero是输出，用于计算控制信号
alu alu_main(srcA,srcB,ALUControl,ALUResult,Zero);

flopr #(.WIDTH (32)) aluout_reg(clk,reset,ALUResult,ALUOut);

mux2#(.WIDTH (32)) choosepcnext(ALUResult,ALUOut,PCSrc,pcnext);



mux2#(.WIDTH (32)) chooseWd3(ALUOut,Data,MemToReg,WD3);


mux2#(.WIDTH (32)) chooseid(pc,ALUOut,IorD,Adr);

assign memoryWD = B;


endmodule