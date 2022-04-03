module adder (
    a,b,
    y
);

input wire[31:0] a,b;
output wire[31:0] y;

assign y = a+b;


endmodule