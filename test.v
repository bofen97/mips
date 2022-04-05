`include "top.v"


module testbench_();

reg clk,reset;
wire [31:0] pc,pcnext;

top dut(clk,reset,pc,pcnext);


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
                

            $display("time: %d    pc: %h   pcnext: %h ",$time,pc,pcnext);
                
            if(pc===32'h20) begin

                $display("Simulation successed ");
                $stop;
            
            end

            
        end
    end
end
endmodule