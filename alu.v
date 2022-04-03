module alu(

    srca,srcb,
    alucontrol,
    aluout,zero

);

input wire[31:0] srca,srcb;
input wire[3:0] alucontrol;

output reg[31:0] aluout;
output reg zero;



always@(*) begin

    if(aluout == 0)
        zero = 1;
    else
        zero = 0;
end

always @(*) begin

    case (alucontrol)
        4'b0010: aluout = srca+srcb; 
        4'b0110: aluout = srca-srcb; 
        4'b0000: aluout = srca&srcb; 
        4'b0001: aluout = srca|srcb; 
        4'b0111: begin

                if(srca<srcb)
                    aluout = 32'b1;
                else
                    aluout = 32'b0;
                end
        4'b0011 : aluout = srca << srcb;
        4'b0101 : aluout = srca >> srcb;
        4'b1000 : aluout = srca >> srcb; //算数右移
        
        4'b1011 : aluout =  srcb << srca;
        4'b1101 : aluout = srcb >> srca;
        4'b1100 : aluout = srcb >> srca;
        

        
        

        default: aluout = 32'bx;
    endcase
    
end


endmodule