`include "flopr.v"
`include "adder.v"
`include "regfile.v"
`include "signext.v"
`include "alu.v"
`include "mux2.v"
`include "sl2.v"
`include "mux3.v"
module new_datapath (
   clk,reset,PCF,pcnext,
   ImmRD,Opcode,Funct,
   RegWriteD,MemtoRegD,MemWriteD,BranchD,ALUControlD,ALUSrcD,RegDstD,
   DmmRD,MemWriteM,ALUOutM,WriteDataM,DEBUG_WriteRegW,DEBUG_RegWriteW,
   JumpD,ForwardAE,ForwardBE,RtE,RsE,WriteRegM,WriteRegW,RegWriteM,RegWriteW,
   StallF,StallD,FlushE,MemtoRegE,RsD,RtD,
   ForwardAD,ForwardBD

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

input wire StallF,StallD,FlushE;

input wire ForwardAD,ForwardBD;

input wire JumpD;
//控制信号 10 bits
input wire RegWriteD,MemtoRegD,MemWriteD,BranchD,ALUSrcD,RegDstD;
input wire [3:0] ALUControlD;

input wire [1:0] ForwardAE,ForwardBE;
//local params
output wire RegWriteW;
output wire [4:0]  WriteRegW;
wire PCSrcD;

//Fetch define
wire [31:0] PCPlus4F;
wire [63:0] FD;//流水线寄存器






flopr #(.WIDTH (32)) pcf_reg(clk,reset,StallF,1'b0,pcnext,PCF);

adder pcplus4_adder(PCF,4,PCPlus4F);

flopr #(.WIDTH (64)) fd_reg(clk,reset,StallD,PCSrcD,{ImmRD,PCPlus4F},FD); //至此，在clk的posedge 拿到了指令和pc+4
//第一个周期，完成了取指令。
//下一个clk posedge 到来。FD拿到第一个周期的指令和pc+4 ，并且开始取新的指令

// Decode stage
wire [31:0] InstrD;
wire [31:0] PCPlus4D;
wire [31:0] RD1,RD2;
wire [31:0] SignImmD;
wire [147:0] DE;

wire [31:0] JumpAddressE;
wire [31:0] JumpAddressM;
wire [31:0] pc_prenext;


wire JumpE;
wire JumpM;


assign InstrD = FD[63:32];

assign PCPlus4D = FD[31:0];
signext sg(InstrD[15:0],SignImmD);


assign Opcode = InstrD[31:26];
assign Funct = InstrD[5:0];

// pc + 4 高4位 和 instr 低26 和 2位00
flopr #(.WIDTH (32)) jumpde_reg(clk,reset,1'b0,FlushE,{PCPlus4D[31:28],InstrD[25:0],2'b00},JumpAddressE);
flopr #(.WIDTH (32)) jumpem_reg(clk,reset,1'b0,1'b0,JumpAddressE,JumpAddressM);

flopr #(.WIDTH (1)) jumpsignal_dereg(clk,reset,1'b0,FlushE,JumpD,JumpE);
flopr #(.WIDTH (1)) jumpsignal_emreg(clk,reset,1'b0,1'b0,JumpE,JumpM);

output wire [4:0] RsD,RtD;
assign RsD = InstrD[25:21];
assign RtD = InstrD[20:16];

wire [31:0] EqualSrcA,EqualSrcB;

wire [31:0] SignImmDSl2;
wire [31:0] PCBranchD;
sl2 sds_reg(SignImmD,SignImmDSl2);
adder pcbranchd_reg(PCPlus4D,SignImmDSl2,PCBranchD);

regfile regs(clk,RegWriteW,InstrD[25:21],InstrD[20:16],WriteRegW,ResultW,RD1,RD2);

mux2 #(.WIDTH (32)) choose_equalsrca(RD1,ALUOutM,ForwardAD,EqualSrcA);
mux2 #(.WIDTH (32)) choose_equalsrcb(RD2,ALUOutM,ForwardBD,EqualSrcB);


assign PCSrcD  =  BranchD && (EqualSrcA==EqualSrcB);




flopr #(.WIDTH (148)) de_reg(clk,reset,1'b0,FlushE,{RegWriteD,MemtoRegD,MemWriteD,
                BranchD,ALUControlD,ALUSrcD,RegDstD,
                RD1,RD2,InstrD[20:16],InstrD[15:11],SignImmD,PCPlus4D},DE);
// 完成译码
// Excute stage
wire RegWriteE,MemWriteE,BranchE,ALUSrcE,RegDstE;
output wire MemtoRegE;
wire [3:0] ALUControlE;

assign {RegWriteE,MemtoRegE,MemWriteE,BranchE,ALUControlE,ALUSrcE,RegDstE}=DE[147:138];

wire [31:0] SrcAE,SrcBE;
wire [31:0] WriteDataE;
wire [4:0] RdE,WriteRegE;
wire [31:0] SignImmE,PCPlus4E;
wire [31:0] ALUOutE;
wire ZeroE;
wire [31:0] SignImmESl2;
wire [31:0] PCBranchE;
wire [105:0] EM;
output wire [4:0] RtE,RsE;


flopr #(.WIDTH (5)) rse_reg(clk,reset,1'b0,FlushE,InstrD[25:21],RsE);

assign RtE = DE[73:69];
assign RdE = DE[68:64];
assign SignImmE = DE[63:32];
assign PCPlus4E = DE[31:0];




mux3 choose_srca(DE[137:106],ResultW,ALUOutM,ForwardAE,SrcAE);
mux3 choose_writedatae(DE[105:74],ResultW,ALUOutM,ForwardBE,WriteDataE);

mux2 #(.WIDTH (32)) choose_srcbe(WriteDataE,SignImmE,ALUSrcE,SrcBE);
alu alu_e(SrcAE,SrcBE,ALUControlE,ALUOutE,ZeroE);
mux2 #(.WIDTH (5)) choose_writerege(RtE,RdE,RegDstE,WriteRegE);

sl2 sl2_reg(SignImmE,SignImmESl2);
adder add_pc(PCPlus4E,SignImmESl2,PCBranchE);


flopr #(.WIDTH (106))em_reg(
      clk,reset,1'b0,1'b0,{RegWriteE,MemtoRegE,MemWriteE,BranchE,ZeroE,ALUOutE,WriteDataE,
            WriteRegE,PCBranchE},EM);

wire MemtoRegM,BranchM,ZeroM;
output wire RegWriteM;
output wire MemWriteM;
wire PCSrcM;
output wire [31:0] WriteDataM;
output wire [4:0] WriteRegM; 
wire [31:0] PCBranchM;

assign {RegWriteM,MemtoRegM,MemWriteM,BranchM,ZeroM} = EM[105:101];

assign PCSrcM = ZeroM & BranchM;
assign ALUOutM = EM[100:69];
assign WriteDataM = EM[68:37];
assign WriteRegM = EM[36:32];
assign PCBranchM = EM[31:0];





wire [70:0] MW;

flopr #(.WIDTH (71)) mw_reg(clk,reset,1'b0,1'b0,{RegWriteM,MemtoRegM,ALUOutM,DmmRD,WriteRegM},MW);

wire MemtoregW;
wire [31:0] ALUOutW;
wire [31:0] ReadDataW;
wire [31:0] ResultW;


assign  {RegWriteW,MemtoregW} = MW[70:69];


assign ALUOutW = MW[68:37];
assign ReadDataW = MW[36:5];
assign WriteRegW = MW[4:0];

mux2 #(.WIDTH (32)) choose_result(ALUOutW,ReadDataW,MemtoregW,ResultW);


mux2 #(.WIDTH (32)) choose_pcprenext(PCPlus4F,PCBranchD,PCSrcD,pc_prenext);
mux2 #(.WIDTH (32)) choose_pcnext(pc_prenext,JumpAddressM,JumpM,pcnext);


endmodule