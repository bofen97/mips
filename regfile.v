module regfile (

    reg_clk,regwrite,
    read_1,read_2,write_3,
    write_data_p3,
    read_data_p1,read_data_p2


);

input wire reg_clk,regwrite;
input wire [4:0] read_1,read_2,write_3;
input wire [31:0] write_data_p3;
output wire [31:0] read_data_p1,read_data_p2;



reg [31:0] regs [31:0];

always @(posedge reg_clk ) begin

    if(regwrite)
        regs[write_3] <= write_data_p3;
end

assign read_data_p1 = (read_1!=0) ? regs[read_1]:0;
assign read_data_p2 =  (read_2!=0)? regs[read_2]:0;


endmodule