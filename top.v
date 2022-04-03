`include "mips.v"
`include "mems.v"



module top(

    clk,reset,pc,pcnext,instr,
    writedata,dataadr,
    memwrite

);

input wire clk,reset;

output wire[31:0] writedata,dataadr,pcnext;
output wire memwrite;
output wire[31:0] pc;


//local params;

wire [31:0] readdata;

output wire[31:0] instr;

/*
module mips(

    clk,reset,
    pc,instr,
    memwrite,
    aluout,writedata,
    readdata
);
*/
mips mips_(clk,reset,pc,pcnext,instr,memwrite,dataadr,writedata,readdata);
imem imem_(pc[7:2],instr);
dmem dmem_(clk,memwrite,dataadr,writedata,readdata);


endmodule