module mux2 #(parameter WIDTH=8 )(
    d0,d1,s,
    y
);

input wire[WIDTH-1:0] d0,d1;
input wire s;

output reg[WIDTH-1:0] y;


always @(*) begin
    if(s)
        y <= d1;
    else
        y <= d0;
    
end


endmodule