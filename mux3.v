module mux3(

    pcsrc,a1,a2,a3,out

);

input wire[1:0] pcsrc;
input wire[31:0] a1,a2,a3;
output reg [31:0] out;


always@(*) begin

    case(pcsrc)
        2'b00:out = a1;
        2'b01:out = a2;
        2'b10:out = a3;

        default: out = 32'b0;


    endcase


end



endmodule