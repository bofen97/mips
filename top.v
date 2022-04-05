`include "mc_mips.v"
`include "mc_mems.v"



module top(

    clk,reset,pc,pcnext

);

input wire clk,reset;
output wire[31:0] pc,pcnext;


//local params

wire[31:0] memoryRD,memoryWD,Adr;
wire MemWrite;



mc_mips mcm(clk,reset,pc,pcnext,memoryRD,Adr,memoryWD,MemWrite

);

mc_mems m_____(
    clk,MemWrite,Adr,memoryRD,memoryWD

);


endmodule