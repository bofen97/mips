`include "flopr.v"
`include "adder.v"
`include "regfile.v"
`include "signext.v"
`include "alu.v"
`include "mux2.v"
`include "sl2.v"

module new_datapath (
   clk,reset,PCF,pcnext,
   ImmRD,Opcode,Funct,
   RegWriteD,MemtoRegD,MemWriteD,BranchD,ALUControlD,ALUSrcD,RegDstD,
   DmmRD,MemWriteM,ALUOutM,WriteDataM,DEBUG_WriteRegW,DEBUG_RegWriteW

);



//--- debug define 

output wire [4:0] DEBUG_WriteRegW;
output wire DEBUG_RegWriteW;

assign DEBUG_RegWriteW = RegWriteW;
assign DEBUG_WriteRegW  = WriteRegW;


//---

input wire clk , reset;
input wire[31:0] ImmRD;//从外部存储器输入到datapath
input wire [31:0] DmmRD;

output wire[31:0] PCF,pcnext; //地址总线访问外部存储器

output wire [5:0] Opcode,Funct;
output wire [31:0] ALUOutM;



//控制信号 10 bits
input wire RegWriteD,MemtoRegD,MemWriteD,BranchD,ALUSrcD,RegDstD;
input wire [3:0] ALUControlD;


//local params

//Fetch define
wire [31:0] PCPlus4F;
wire [63:0] FD;//流水线寄存器

//Decode define 

//10bits control signal,32 bits RD1, 32 bits Rd2,
//5 bits RtD, 5 bits RdD,32 bits signext,32 bits PCPlus4D;



// Excute define .




// Fetch stage

flopr #(.WIDTH (32)) pcf_reg(clk,reset,pcnext,PCF);

adder pcplus4_adder(PCF,32'b0100,PCPlus4F);

flopr #(.WIDTH (64)) fd_reg(clk,reset,{ImmRD,PCPlus4F},FD); //至此，在clk的posedge 拿到了指令和pc+4
//第一个周期，完成了取指令。
//下一个clk posedge 到来。FD拿到第一个周期的指令和pc+4 ，并且开始取新的指令

// Decode stage
wire [31:0] InstrD;
wire [31:0] PCPlus4D;
wire [31:0] RD1,RD2;
wire [31:0] SignImmD;
wire [147:0] DE;

assign InstrD = FD[63:32];

assign PCPlus4D = FD[31:0];
signext sg(InstrD[15:0],SignImmD);


assign Opcode = InstrD[31:26];
assign Funct = InstrD[5:0];



regfile regs(clk,RegWriteW,InstrD[25:21],InstrD[20:16],WriteRegW,ResultW,RD1,RD2);



flopr #(.WIDTH (148)) de_reg(clk,reset,{RegWriteD,MemtoRegD,MemWriteD,
                BranchD,ALUControlD,ALUSrcD,RegDstD,
                RD1,RD2,InstrD[20:16],InstrD[15:11],SignImmD,PCPlus4D},DE);
// 完成译码
// Excute stage
wire RegWriteE,MemtoRegE,MemWriteE,BranchE,ALUSrcE,RegDstE;
wire [3:0] ALUControlE;

assign {RegWriteE,MemtoRegE,MemWriteE,BranchE,ALUControlE,ALUSrcE,RegDstE}=DE[147:138];

wire [31:0] SrcAE,SrcBE;
wire [31:0] WriteDataE;
wire [4:0] RtE,RdE,WriteRegE;
wire [31:0] SignImmE,PCPlus4E;
wire [31:0] ALUOutE;
wire ZeroE;
wire [31:0] SignImmESl2;
wire [31:0] PCBranchE;
wire [105:0] EM;

assign SrcAE =  DE[137:106];
assign WriteDataE= DE[105:74];
assign RtE = DE[73:69];
assign RdE = DE[68:64];
assign SignImmE = DE[63:32];
assign PCPlus4E = DE[31:0];





mux2 #(.WIDTH (32)) choose_srcbe(WriteDataE,SignImmE,ALUSrcE,SrcBE);
alu alu_e(SrcAE,SrcBE,ALUControlE,ALUOutE,ZeroE);
mux2 #(.WIDTH (5)) choose_writerege(RtE,RdE,RegDstE,WriteRegE);

sl2 sl2_reg(SignImmE,SignImmESl2);
adder add_pc(PCPlus4E,SignImmESl2,PCBranchE);


flopr #(.WIDTH (106))em_reg(
      clk,reset,{RegWriteE,MemtoRegE,MemWriteE,BranchE,ZeroE,ALUOutE,WriteDataE,
            WriteRegE,PCBranchE},EM);

wire RegWriteM,MemtoRegM,BranchM,ZeroM;
output wire MemWriteM;
wire PCSrcM;
output wire [31:0] WriteDataM;
wire [4:0] WriteRegM; 
wire [31:0] PCBranchM;

assign {RegWriteM,MemtoRegM,MemWriteM,BranchM,ZeroM} = EM[105:101];

assign PCSrcM = ZeroM & BranchM;
assign ALUOutM = EM[100:69];
assign WriteDataM = EM[68:37];
assign WriteRegM = EM[36:32];
assign PCBranchM = EM[31:0];





wire [70:0] MW;

flopr #(.WIDTH (71)) mw_reg(clk,reset,{RegWriteM,MemtoRegM,ALUOutM,DmmRD,WriteRegM},MW);


wire RegWriteW,MemtoregW;
wire [31:0] ALUOutW;
wire [31:0] ReadDataW;
wire [4:0]  WriteRegW;
wire [31:0] ResultW;


assign  {RegWriteW,MemtoregW} = MW[70:69];


assign ALUOutW = MW[68:37];
assign ReadDataW = MW[36:5];
assign WriteRegW = MW[4:0];

mux2 #(.WIDTH (32)) choose_result(ALUOutW,ReadDataW,MemtoregW,ResultW);


mux2 #(.WIDTH (32)) choose_pcnext(PCPlus4F,PCBranchM,PCSrcM,pcnext);


endmodule