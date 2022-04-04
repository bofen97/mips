module mux4(
    muxop,R1,R2,R3,R4,dst
);

input wire[1:0] muxop;
input wire[31:0] R1,R2,R3,R4;
output reg[31:0] dst;

always@(*) begin

    case (muxop)
       2'b00 : dst = R1;
       2'b01 : dst = R2;
       2'b10 : dst = R3;
       2'b11 : dst = R4;
        
        default:dst = 32'b0;
    endcase



end



endmodule
