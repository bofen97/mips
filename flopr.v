module flopr #(parameter WIDTH = 8 )(
    clk,reset,
    d,q
);

input wire clk,reset;
input wire[WIDTH-1:0] d;
output reg[WIDTH-1:0] q;

always@(posedge clk or posedge reset) begin
    
    if(reset)
        q <= 0;
    else
        q <=d;


end

endmodule



module flopr_with_signal #(parameter WIDTH = 8 )(
    clk,reset,signal,
    d,q
);

input wire clk,reset,signal;
input wire[WIDTH-1:0] d;
output reg[WIDTH-1:0] q;

always@(posedge clk or posedge reset) begin
    
   if(reset)
        q<=0;
    else if (signal)
        q<=d;

    
end

endmodule