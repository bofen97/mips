`include "top.v"


module testbench_();

reg clk,reset;
wire [31:0] pc,instr,pcnext,ALUOutM;
wire [4:0] DEBUG_WriteRegW;
wire DEBUG_RegWriteW;


top dut(clk,reset,pc,pcnext,instr,ALUOutM,DEBUG_WriteRegW,DEBUG_RegWriteW);


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
                

            $display("time: %d    pc: %h   pcnext: %h  instr: %h  aluout: %h  regwrite : %h , writereg: %h",
                    $time,pc,pcnext,instr,ALUOutM,DEBUG_RegWriteW,DEBUG_WriteRegW);
            if(pc===32'h58) begin

                $display("Simulation successed ");
                $stop;
            
            end

        
        end
    end
end
endmodule