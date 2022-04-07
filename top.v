`include "mips.v"
`include "mems.v"



module top(

    clk,reset,pc,pcnext,ImmRD,ALUOutM,DEBUG_WriteRegW,DEBUG_RegWriteW


);

input wire clk,reset;
output wire [31:0] pc,pcnext,ImmRD,ALUOutM;



//local params;



wire [31:0] DmmRD,WriteDataM;
wire MemWriteM;

output wire DEBUG_RegWriteW;
output wire [4:0] DEBUG_WriteRegW;

mips mips_(
    clk,reset,pc,pcnext,ImmRD,DmmRD,MemWriteM,ALUOutM,WriteDataM,DEBUG_WriteRegW,DEBUG_RegWriteW
);
imem imem_(pc[7:2],ImmRD);
dmem dmem_(clk,MemWriteM,ALUOutM,WriteDataM,DmmRD);


endmodule