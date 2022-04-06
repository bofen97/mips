`include "controller.v"
`include "new_datapath.v"

module mips(
    clk,reset,PCF,pcnext,ImmRD,DmmRD,MemWriteM,ALUOutM,WriteDataM
);

input wire clk,reset;
input wire [31:0] ImmRD,DmmRD;

output wire [31:0] PCF,pcnext;
output wire [31:0] ALUOutM,WriteDataM;
output wire MemWriteM;


wire [5:0] opcode,funct;
wire RegWriteD,MemtoRegD,MemWriteD,BranchD,ALUSrcD,RegDstD;
wire [3:0] ALUControlD;





controller c(
    opcode,funct,
    RegWriteD,MemtoRegD,MemWriteD,BranchD,ALUControlD,ALUSrcD,RegDstD
);




new_datapath nd(
   clk,reset,PCF,pcnext,
   ImmRD,opcode,funct,
   RegWriteD,MemtoRegD,MemWriteD,BranchD,ALUControlD,ALUSrcD,RegDstD,
   DmmRD,MemWriteM,ALUOutM,WriteDataM,

);






endmodule