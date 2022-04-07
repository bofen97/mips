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
    
    RAM[0] = 32'b001000_00000_00001_0000000000000111;
    RAM[1] = 32'b001000_00000_00010_0000000000001000;

    
    RAM[5] = 32'b000000_00001_00010_00011_00000_100000;
    
    RAM[9] = 32'b001000_00000_00100_0000000000001111;
    
    RAM[13] = 32'b000100_00100_00011_0000000000000001;
    
    
    


    
    

    
end
assign rd = RAM[a]; //word aligned


endmodule