
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

output reg IorD,MemWrite,IRWrite ,PCWrite ,Branch,PCSrc,ALUSrcA ,RegWrite,RegDst,MemToReg;
output reg [1:0] ALUSrcB ;
output reg [1:0] ALUOp;
// local params 



parameter S0 = 0 ,
          S1 = 1,
          S2 = 2,
          S3 = 3,
          S4 = 4,
          S5 = 5,
          S6 = 6,
          S7 = 7,
          S8 = 8;
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
    
    
    S2: if(Opcode == 6'b100011) 
            state_nxt = S3;
        else if (Opcode == 6'b101011)
            state_nxt = S5;


    S3: state_nxt = S4;
    S4: state_nxt = S0;
    S5: state_nxt = S0;
    S6: state_nxt = S7;
    S7: state_nxt = S0;
    S8: state_nxt = S0;




    default :state_nxt = S0;

    endcase



end


always@(*) begin

    case(state)

    S0:begin

        IorD = 0 ;
        MemWrite = 0; 
        IRWrite = 1;
        PCWrite = 1;
        Branch = 0 ;
        PCSrc  = 0 ;
        ALUOp = 2'b00;
        ALUSrcB = 2'b01;
        ALUSrcA = 0;
        RegWrite = 0;
        RegDst = 0;
        MemToReg = 0;
        end
    S1:begin
        IorD = 0 ;
        MemWrite = 0 ;
        IRWrite = 0;
        PCWrite = 0;
        Branch = 0 ;
        PCSrc  = 0 ;
        ALUOp = 2'b00;
        ALUSrcB = 2'b11;
        ALUSrcA = 0;
        RegWrite = 0;
        RegDst = 0;
        MemToReg = 0;

        end
    
    S2:begin

        IorD = 0 ;
        MemWrite = 0 ;
        IRWrite = 0;
        PCWrite = 0;
        Branch = 0 ;
        PCSrc  = 0 ;
        ALUOp = 2'b00;
        ALUSrcB = 2'b10;
        ALUSrcA = 1;
        RegWrite = 0;
        RegDst = 0;
        MemToReg = 0;
         end

    
    S3:begin 

        IorD = 1  ;      
        MemWrite = 0 ;
        IRWrite = 0;
        PCWrite = 0;
        Branch = 0 ;
        PCSrc  = 0 ;
        ALUOp = 2'b00;
        ALUSrcB = 2'b00; 
        ALUSrcA = 0;
        RegWrite = 0;
        RegDst = 0;
        MemToReg = 0;
        end

    S5:begin


        IorD = 1 ;          
        MemWrite = 1; 
        IRWrite = 0;
        PCWrite = 0;
        Branch = 0 ;
        PCSrc  = 0 ;
        ALUOp =  2'b00;
        ALUSrcB = 2'b00; 
        ALUSrcA =0;
        RegWrite = 0;
        RegDst = 0;
        MemToReg = 0;
    end

    S4:begin


        IorD = 0;
        MemWrite = 0; 
        IRWrite = 0;
        PCWrite = 0;
        Branch = 0 ;
        PCSrc  = 0 ;
        ALUOp =  2'b00;
        ALUSrcB = 2'b00; 
        ALUSrcA = 0;
        RegWrite = 1;
        RegDst = 0;
        MemToReg = 1;
    end

    S6:begin
        IorD = 0 ;
        MemWrite = 0 ;
        IRWrite = 0;
        PCWrite = 0;
        Branch = 0 ;
        PCSrc  = 0 ;
        ALUOp =  2'b10;
        ALUSrcB = 2'b00;
        ALUSrcA = 1;
        RegWrite = 0;
        RegDst = 0;
        MemToReg = 0;
    end

    S7:begin
        IorD = 0 ;
        MemWrite = 0 ;
        IRWrite = 0;
        PCWrite = 0;
        Branch = 0 ;
        PCSrc  = 0 ;
        ALUOp =  2'b00;
        ALUSrcB = 2'b00;
        ALUSrcA = 0;
        RegWrite = 1;
        RegDst = 1;
        MemToReg = 0;
    end

    S8:begin

        IorD = 0 ;
        MemWrite = 0 ;
        IRWrite = 0;
        PCWrite = 0;
        Branch = 1;
        PCSrc  = 1 ;
        ALUOp =  2'b01; 
        ALUSrcB = 2'b00;
        ALUSrcA = 1;
        RegWrite = 0;
        RegDst = 0;
        MemToReg = 0;
    end



    default:begin

        IorD = 0 ;
        MemWrite = 0 ;
        IRWrite = 0;
        PCWrite = 0;
        Branch = 0;
        PCSrc  = 0 ;
        ALUOp =  2'b00; 
        ALUSrcB = 2'b00;
        ALUSrcA = 0;
        RegWrite = 0;
        RegDst = 0;
        MemToReg = 0;
    end



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

fms_controller fms(
    clk,reset,Opcode,IorD,MemWrite,IRWrite ,PCWrite ,Branch,PCSrc ,ALUOp,ALUSrcB ,ALUSrcA ,RegWrite,
    RegDst,MemToReg
);


aludec alu_(Funct,ALUOp,ALUControl,shamt_c);


assign PCEn = ((Zero & Branch) | PCWrite);


endmodule