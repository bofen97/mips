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
    
    RAM[0] = 32'h20020005;  //addi $2 $0 5   ok
    RAM[1] = 32'h2003000c;  //addi $3 $0 12  ok
    RAM[2] = 32'h2067fff7;  // addi $7 $3 -9   ok
    RAM[3] = 32'h00e22025;  // or $4 $7 $2      ok
    RAM[4] = 32'h00642824;  // and $5 $3 $4  ok
    RAM[5] = 32'h00a42820;  // add $5 $5 $4 ok
    RAM[6] = 32'h10a7000a;  //beq $5 $7 ,end ok
    RAM[7] = 32'h0064202a;  //slt $4 $3 ,$4  ok
    RAM[8] = 32'h10800001;  //beq $4 $0 ,around ok
    RAM[9] = 32'h20050000;  //addi $5 $0 ,$0
    RAM[10] = 32'h00e2202a;  //stl $4 $7 ,$2 ok
    RAM[11] = 32'h00853820; // add $7 $4 $5  ok
    RAM[12] = 32'h00e23822; // sub $7 $7 $2  ok
    RAM[13] = 32'hac670044; // sw $7 68($3)  ok
    RAM[14] = 32'h8c020050; // lw $2 80($0)  ok 
    RAM[15] = 32'h08000011;  // j end           ok
    RAM[16] = 32'h20020001; // add $2 , $0, 1 ok
    RAM[17] = 32'hac020054; // sw $2 ,84($0); ok

end
assign rd = RAM[a]; //word aligned


endmodule