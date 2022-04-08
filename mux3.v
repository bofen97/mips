module mux3 (

    s0,s1,s2,signal,to

);

input wire [1:0] signal;
input wire [31:0] s0,s1,s2;
output reg [31:0] to;


always @(*) begin
    
    case (signal)
        2'b00 : to = s0;
        2'b01 : to = s1;
        2'b10 : to = s2;
        default: to = s0;
    endcase
end

endmodule