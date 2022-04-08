
module maindec (
    opcode,RegWrite,
    MemToReg,MemWrite,
    Branch,ALUSrc,
    RegDst,
    Jump,ALUop

);
input wire [5:0] opcode;
output wire MemToReg,MemWrite,Branch,ALUSrc,RegDst,RegWrite,Jump;
output wire[1:0] ALUop;

reg [8:0] controller_9bits;

assign {RegWrite,RegDst,ALUSrc,Branch,MemWrite,MemToReg,Jump,ALUop} = controller_9bits;

always @(*) begin

    case (opcode)
        6'b000000: controller_9bits = 9'b110000010;//R 
        6'b100011: controller_9bits = 9'b101001000;//lw
        6'b101011: controller_9bits = 9'b001010000;//sw
        6'b000100: controller_9bits = 9'b000100001;//beq
        6'b001000: controller_9bits = 9'b101000000;//addi
        6'b000010: controller_9bits = 9'b000000100;//j
        default: controller_9bits = 9'bxxxxxxxxx;//illegal op
    endcase

    
end
    
endmodule



module aludec (
   funct,aluop,
   ALUcontrol_4bit
);

input wire [5:0] funct;
input wire [1:0] aluop;
output reg[3:0] ALUcontrol_4bit;

always@(*) begin

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
            default: ALUcontrol_4bit = 4'bxxxx;
            endcase
    endcase
            
end

endmodule


module controller(
    opcode,funct,

    RegWriteD,MemtoRegD,MemWriteD,BranchD,ALUControlD,ALUSrcD,RegDstD,JumpD

    
);

input wire[5:0] opcode,funct;
output wire RegWriteD,MemtoRegD,MemWriteD,BranchD,ALUSrcD,RegDstD;
output wire  [3:0] ALUControlD;

output wire JumpD;
wire [1:0] ALUopD;


maindec md(
    opcode,RegWriteD,MemtoRegD,MemWriteD,BranchD,ALUSrcD,RegDstD,JumpD,ALUopD
);

aludec ad(
    funct,ALUopD,ALUControlD

);


endmodule
