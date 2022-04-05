`include "mc_datapath.v"
`include "controller.v"


module mc_mips(

    clk,reset,pc,pcnext,memoryRD,Adr,memoryWD,MemWrite
    

);

input clk,reset;

wire [5:0] Opcode,Funct;
wire Zero,IorD,IRWrite,PCSrc,RegWrite,RegDst,MemToReg,PCEn,ALUSrcA;
wire [1:0] ALUSrcB ;
wire [3:0] ALUControl;
output wire MemWrite;
output wire [31:0] pc,pcnext;
input wire [31:0] memoryRD;
output wire [31:0] Adr,memoryWD;

mc_controller mcc(
    clk,reset,Opcode,Funct,Zero,IorD,MemWrite,IRWrite,PCSrc,ALUSrcB ,ALUSrcA ,RegWrite,
    RegDst,MemToReg,ALUControl,PCEn
);


mc_datapath mcd(
    clk,reset,
    pc,pcnext,PCEn,
    memoryRD,IRWrite,
    Opcode,Funct,RegWrite,
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


endmodule
