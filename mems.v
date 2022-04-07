module dmem (
    clk,we,a,wd,rd
);
    
input wire clk,we;

input wire[31:0] a,wd;
output wire[31:0] rd;


reg [31:0] RAM[0:63];

assign rd = RAM[a[31:2]]; //word aligned

always @(posedge clk) begin
    if(we)
        RAM[a[31:2]] <= wd;
    
end


endmodule


module imem(
    a,rd
);

input wire[5:0] a;
output wire[31:0] rd;


reg[31:0] RAM[0:63];

initial begin
    RAM[0] = 32'b000100_00000_00001_0000000000000000;
    // RAM[1] = 32'b000100_00000_00000_0000000000000011;
    

    
end
assign rd = RAM[a]; //word aligned


endmodule