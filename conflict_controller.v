module conflict_controller(

    RsE,RtE,WriteRegM,RegWriteM,WriteRegW,RegWriteW,
    ForwardAE,ForwardBE


);

input wire [4:0] RsE,RtE; //两个源寄存器
input wire [4:0] WriteRegM,WriteRegW;//Memory , WriteBack阶段需要写的寄存器
input wire RegWriteM,RegWriteW; //Memory , WriteBack阶段的写寄存器信号
output reg[1:0] ForwardAE,ForwardBE ; //把什么输入给ALU？


always@(*) begin

    if ((RsE!=0) && (RsE == WriteRegM ) && RegWriteM)
        ForwardAE = 2'b10;
    else if ((RsE!=0) && (RsE == WriteRegW) && RegWriteW)
        ForwardAE = 2'b01;
    else
        ForwardAE = 2'b00;

end


always@(*) begin

    if ((RtE!=0) && (RtE == WriteRegM ) && RegWriteM)
        ForwardBE = 2'b10;
    else if ((RtE!=0) && (RtE == WriteRegW) && RegWriteW)
        ForwardBE = 2'b01;
    else
        ForwardBE = 2'b00;

end



endmodule