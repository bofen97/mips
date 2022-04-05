
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








module fms_controller(
    clk,reset,
    Opcode,
    IorD,MemWrite,IRWrite ,PCWrite ,Branch,
    PCSrc ,ALUOp,ALUSrcB ,ALUSrcA ,RegWrite,
    RegDst,MemToReg

);

input wire clk,reset;
input wire[5:0] Opcode;

output wire IorD,MemWrite,IRWrite ,PCWrite ,Branch,PCSrc,ALUSrcA ,RegWrite,RegDst,MemToReg;
output wire [1:0] ALUSrcB ;
output wire [1:0] ALUOp;
// local params 



parameter S0 = 4'b0000 ,
          S1 = 4'b0001,
          S2 = 4'b0010,
          S3 = 4'b0011,
          S4 = 4'b0100,
          S5 = 4'b0101,
          S6 = 4'b0110,
          S7 = 4'b0111,
          S8 = 4'b1000;

reg [3:0] state,state_nxt;



always@(posedge clk or posedge reset) begin


    if(reset)
        state <=  S0;
    else
        state <= state_nxt; 

end

/*
        6'b000000 //R 
        6'b100011 //lw
        6'b101011 //sw
        6'b000100 //beq
        6'b000101 //neq
        6'b001000 //addi
        6'b000010 //j
*/
always@(*) begin

    case(state)
    S0: state_nxt = S1;
    S1: if(Opcode == 6'b100011 || Opcode == 6'b101011) 
            state_nxt = S2;
        else if (Opcode == 6'b000000 )
            state_nxt = S6;
        else if (Opcode ==  6'b000100) 
            state_nxt = S8;
        else
            state_nxt = S0;
    
    
    S2: if(Opcode == 6'b100011) 
            state_nxt = S3;
        else if (Opcode == 6'b101011)
            state_nxt = S5;
        else
            state_nxt = S0;

    S3: state_nxt = S4;
    S4: state_nxt = S0;
    S5: state_nxt = S0;
    S6: state_nxt = S7;
    S7: state_nxt = S0;
    S8: state_nxt = S0;

    default :state_nxt = S0;

    endcase



end

reg [13:0] fmsc;
assign {IorD,MemWrite,IRWrite,PCWrite,Branch ,PCSrc ,ALUOp,ALUSrcB,ALUSrcA ,RegWrite,RegDst,MemToReg} = fmsc;


always@(*) begin

    case(state)
        S0: fmsc = 14'b00110000010000;
        S1: fmsc = 14'b00000000110000;
        S2: fmsc = 14'b00000000101000;
        S3: fmsc = 14'b10000000000000; 
        S5: fmsc = 14'b11000000000000;
        S4: fmsc = 14'b00000000000101;
        S6: fmsc = 14'b00000010001000;
        S7: fmsc = 14'b00000000000110;
        S8: fmsc = 14'b00001101001000;
    default:
            fmsc = 14'b00000000000000;
    endcase
end
endmodule




module mc_controller(
    clk,reset,
    Opcode,Funct,Zero,
    IorD,MemWrite,IRWrite,
    PCSrc,ALUSrcB ,ALUSrcA ,RegWrite,
    RegDst,MemToReg,ALUControl,PCEn

);


input wire clk,reset;

input wire [5:0] Opcode,Funct;
input wire Zero;

output wire IorD,MemWrite,IRWrite,PCSrc ,ALUSrcA ,RegWrite,RegDst,MemToReg;
output wire [1:0] ALUSrcB;
output wire [3:0] ALUControl;
output wire PCEn;
wire [1:0] ALUOp;
wire PCWrite ,Branch;
wire shamt_c;

/*
module fms_controller(
    clk,reset,
    Opcode,
    IorD,MemWrite,IRWrite ,PCWrite ,Branch,
    PCSrc ,ALUOp,ALUSrcB ,ALUSrcA ,RegWrite,
    RegDst,MemToReg

);
*/
fms_controller fms(
    clk,reset,Opcode,IorD,MemWrite,IRWrite ,PCWrite ,Branch,PCSrc ,ALUOp,ALUSrcB ,ALUSrcA ,RegWrite,
    RegDst,MemToReg
);


aludec alu_(Funct,ALUOp,ALUControl,shamt_c);


assign PCEn = ((Zero & Branch) | PCWrite);


endmodule