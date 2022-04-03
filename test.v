`include "top.v"


module testbench_();

reg clk,reset;
wire [31:0] writedata,dataadr,pc,instr,pcnext;
wire memwrite;

top dut(clk,reset,pc,pcnext,instr,writedata,dataadr,memwrite);


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
                

            $display("time: %d    pc: %h   pcnext: %h  instr: %h  memwrite %b  dataadr %d writedata %d",
                    $time,pc,pcnext,instr, memwrite,dataadr,writedata);
                
               
            // if(memwrite) begin
            //     if(dataadr===84 & writedata===7) begin
            //         $display("Simulation successed ");
            //         $stop;
            //     end else if (dataadr !== 80 )begin

            //         $display("Simulation failed ");
            //         $stop;
            //     end

            // end

            if(pc===32'h58) begin

                $display("Simulation successed ");
                $stop;
            
            end

            

        

        end
    end
end
endmodule