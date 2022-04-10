`include "top.v"


module testbench_();

reg clk,reset;
wire [31:0] pc,instr,pcnext,ALUOutM;
wire [4:0] DEBUG_WriteRegW;
wire DEBUG_RegWriteW;
wire StallD,StallF,FlushE;

top dut(clk,reset,pc,pcnext,instr,ALUOutM,DEBUG_WriteRegW,DEBUG_RegWriteW,
StallD,StallF,FlushE);


initial begin

    reset=1;
    #25;
    reset=0;

end


initial begin
    clk = 1'b1;
    forever begin
        #5 clk = ~clk;
    end
end



initial begin
    forever begin

            @(negedge clk) begin
                

            $display("time: %d    pc: %h   pcnext: %h  instr: %h  aluout: %h  regwrite : %h , writereg: %h  stalld  %b stallf %b flushe %b " ,
                    $time,pc,pcnext,instr,ALUOutM,DEBUG_RegWriteW,DEBUG_WriteRegW,StallD,StallF,FlushE);
            if(pc===32'h5c) begin

                $display("Simulation successed ");
                $stop;
            
            end

        
        end
    end
end
endmodule