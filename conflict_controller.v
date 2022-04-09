module conflict_controller(

    RsE,RtE,WriteRegM,RegWriteM,WriteRegW,RegWriteW,
    ForwardAE,ForwardBE,ForwardAD,ForwardBD,RsD,RtD


);

input wire [4:0] RsE,RtE,RsD,RtD; //两个源寄存器
input wire [4:0] WriteRegM,WriteRegW;//Memory , WriteBack阶段需要写的寄存器
input wire RegWriteM,RegWriteW; //Memory , WriteBack阶段的写寄存器信号
output reg[1:0] ForwardAE,ForwardBE ; //把什么输入给ALU？
output reg ForwardAD,ForwardBD;

always@(*) begin
    if ((RsD!=0) && (RsD==WriteRegM) && RegWriteM)
        ForwardAD = 1'b1;
    else
        ForwardAD = 1'b0;
end

always@(*) begin
    if ((RtD!=0) && (RtD==WriteRegM) && RegWriteM)
        ForwardBD = 1'b1;
    else
        ForwardBD = 1'b0;
end


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



module stall_contorller(
    StallD,StallF,FlushE,RsD,RtD,RtE,MemtoRegE,
    RegWriteE,BranchD,WriteRegE,
    MemtoRegM,WriteRegM
);


input wire [4:0] RsD,RtD,RtE;
input wire MemtoRegE;
output reg StallD,StallF,FlushE;
input wire RegWriteE,BranchD;
input wire [4:0] WriteRegE;
input wire MemtoRegM;
input wire [4:0] WriteRegM;


always@(*) begin


        if (((RsD == RtE) || (RtD == RtE)) && MemtoRegE) begin

            StallD = 1;
            StallF = 1;
            FlushE = 1;

        end
        else if (BranchD && RegWriteE && (RsD == WriteRegE || RtD == WriteRegE)) begin
            
            StallD = 1;
            StallF = 1;
            FlushE = 1;
        end
        else if  (BranchD && MemtoRegM && (RsD == WriteRegM || RtD == WriteRegM) ) begin

            StallD = 1;
            StallF = 1;
            FlushE = 1;

        end 
        else begin

            StallD = 0;
            StallF = 0;
            FlushE = 0;
        end









end




endmodule