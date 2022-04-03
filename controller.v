/*  p239
    controller : mips控制器

    main dec : 根据6bits opcode 生成控制信号
    {MemToReg, MemWrite , Branch ,ALUop ,ALUSrc,RegDst,
    RegWrite ,Jump }
*/
module maindec (
    opcode,
    MemToReg,MemWrite,
    Branch,ALUSrc,
    RegDst,RegWrite,
    Jump,ALUop,PcsrcChoose

);
input wire [5:0] opcode;
output wire MemToReg,MemWrite,Branch,ALUSrc,RegDst,RegWrite,Jump,PcsrcChoose;
output wire[1:0] ALUop;

reg [9:0] controller_xbits;

assign {RegWrite,RegDst,ALUSrc,Branch,MemWrite,MemToReg,Jump,ALUop,PcsrcChoose} = controller_xbits;

always @(*) begin

    case (opcode)
        6'b000000: controller_xbits = 10'b1100000101;//R 
        6'b100011: controller_xbits = 10'b1010010001;//lw
        6'b101011: controller_xbits = 10'b0010100001;//sw
        6'b000100: controller_xbits = 10'b0001000011;//beq
        6'b000101: controller_xbits = 10'b0001000010;//neq
        6'b001000: controller_xbits = 10'b1010000001;//addi
        6'b000010: controller_xbits = 10'b0000001001;//j
        default: controller_xbits = 10'bxxxxxxxxxx;//illegal op
    endcase

    
end
    
endmodule



module aludec (
   funct,aluop,
   ALUcontrol_4bit,shamt_c
);

input wire [5:0] funct;
input wire [1:0] aluop;
output reg[3:0] ALUcontrol_4bit;
output reg shamt_c;

always@(*) begin
    shamt_c = 0;

    case(aluop)
    2'b00 : ALUcontrol_4bit = 4'b0010;//add
    2'b01 : ALUcontrol_4bit = 4'b0110;//sub
    //1x
    default: case(funct)
            6'b100000 : ALUcontrol_4bit = 4'b0010; //add
            6'b100010 : ALUcontrol_4bit = 4'b0110; //sub
            6'b100100 : ALUcontrol_4bit = 4'b0000; //and
            6'b100101 : ALUcontrol_4bit = 4'b0001; //or
            6'b101010 : ALUcontrol_4bit = 4'b0111; //slt
            6'b000100 : ALUcontrol_4bit = 4'b0011; //sllv;
            6'b000110 : ALUcontrol_4bit = 4'b0101; //srlv;
            6'b000111 : ALUcontrol_4bit = 4'b1000; //srav;
            
            6'b000000 : begin 
                            ALUcontrol_4bit = 4'b1011; //sll 
                            shamt_c =1;
                        end                         //sll
            
            
            6'b000010 : begin
                            ALUcontrol_4bit = 4'b1101; //srl   
                            shamt_c =1;                     //srl
                        end

            6'b000011 : begin 
                            ALUcontrol_4bit = 4'b1100; //sra
                            shamt_c =1 ;                      //sra
                        end
            default: ALUcontrol_4bit = 4'bxxxx;
            endcase
    endcase
            
end

endmodule


module controller(

    opcode,funct,
    zero,
    memtoreg,memwrite,
    pcsrc,alusrc,
    regdst,regwrite,
    jump,
    alucontrol,shamt_c
);

input wire[5:0] opcode;
input wire [5:0] funct;
input wire zero;
output wire  memtoreg,memwrite,alusrc,regdst,regwrite,jump;
output reg pcsrc;
output wire[3:0] alucontrol;
output wire shamt_c;
wire branch;
wire [1:0] aluop;
wire pcsrcchoose;

/*

module maindec (
    opcode,
    MemToReg,MemWrite,
    Branch,ALUSrc,
    RegDst,RegWrite,
    Jump,ALUop

);
*/
maindec md(opcode,memtoreg,memwrite,branch,alusrc,regdst,regwrite,jump,
            aluop,pcsrcchoose);

/*
module aludec (
   funct,aluop,
   ALUcontrol_4bit
);
*/

aludec ad(funct,aluop,alucontrol,shamt_c);


always@(*) begin
    if(pcsrcchoose)
        pcsrc = branch & zero;
    else
        pcsrc = branch & (~zero);
end

endmodule
