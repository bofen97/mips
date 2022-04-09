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
    
    RAM[0] = 32'b001000_00000_00001_0000000000000111; //addi $1 $0 7
    RAM[1] = 32'b001000_00000_00010_0000000000001000; //addi $2 $0 8
    RAM[2] = 32'b001000_00000_00100_0000000000001111; // addi $4 $0 15
    RAM[3] = 32'b000000_00001_00010_00011_00000_100000;//add $3 $1 $2
    RAM[4] = 32'b000100_00100_00011_0000000000000000;// beq $4 $3 ram5
    RAM[5] = 32'h00000000;

    RAM[8] = 32'b101011_00000_00001_0000000000000000; // sw $1 $0(0)
    RAM[9] = 32'b101011_00000_00010_0000000000000100; // sw $2 $0(4)
    RAM[10] = 32'b100011_00000_00011_0000000000000000; // lw $3 $0(0)
    RAM[11] = 32'b100011_00000_00100_0000000000000100; // lw $4 $0(4)
    RAM[12] = 32'b101011_00000_00100_0000000000001000; // sw $4 $0(8)
    RAM[13] = 32'b000000_00011_00100_00000_00000_100000; // add $0 $3 $4
    

    
    
    


    
    

    
end
assign rd = RAM[a]; //word aligned


endmodule