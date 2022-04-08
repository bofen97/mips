module flopr #(parameter WIDTH = 8 )(
    clk,reset,en_,clr,
    d,q
);

input wire clk,reset;
input wire en_,clr;
input wire[WIDTH-1:0] d;
output reg[WIDTH-1:0] q;

always@(posedge clk or posedge reset) begin
    
    if(reset || clr)
        q <= 0;
    else if(!en_)
        q <=d;


end

endmodule