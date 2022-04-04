// module dmem (
//     clk,we,a,wd,rd
// );
    
// input wire clk,we;

// input wire[31:0] a,wd;
// output wire[31:0] rd;


// reg [31:0] RAM[0:63];

// assign rd = RAM[a[31:2]]; //word aligned

// always @(posedge clk) begin
//     if(we)
//         RAM[a[31:2]] <= wd;
    
// end


// endmodule


// module imem(
//     a,rd
// );

// input wire[5:0] a;
// output wire[31:0] rd;


// reg[31:0] RAM[0:63];

// initial begin
//     RAM[0] = 32'h20020005;// 001000 00000 00010 0000000000000101 // addi $2 , $0, 5;
//     RAM[1] = 32'h2003000c;
//     RAM[2] = 32'h2067fff7;
//     RAM[3] = 32'h00e22025;
//     RAM[4] = 32'h00642824;
//     RAM[5] = 32'h00a42820;
//     RAM[6] = 32'h10a7000a;
//     RAM[7] = 32'h0064202a;
//     RAM[8] = 32'h10800001;
//     RAM[9] = 32'h20050000;
//     RAM[10] = 32'h00e2202a;
//     RAM[11] = 32'h00853820;
//     RAM[12] = 32'h00e23822;
//     RAM[13] = 32'hac670044;
//     RAM[14] = 32'h8c020050;
//     RAM[15] = 32'h08000011;
//     RAM[16] = 32'h20020001;
//     RAM[17] = 32'hac020054;
//     //srlv  $2 $2 $2
//     RAM[18] = 32'b000000_00010_00010_00010_00000_000100;
//     RAM[19] = 32'b001000_00000_00011_0000000000000111;
//     RAM[20] = 32'b000000_00010_00011_00010_00000_000110;
//     RAM[21] = 32'b000000_00000_00010_00010_00111_000000;
//     RAM[22] = 32'h1043fffb;
// end
// assign rd = RAM[a]; //word aligned


// endmodule



module mems(
    clk,we,a,rd,wd
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