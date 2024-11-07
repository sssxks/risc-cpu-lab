`timescale 1ns / 1ps
`define assert(signal, value) \
    if (signal !== value) begin \
        $display("ASSERTION FAILED in %m: signal != value"); \
        $finish; \
    end


module div32_tb();
      reg clk;
      reg rst;
      reg [31:0] dividend;
      reg [31:0] divisor;
      reg start;
      
      wire [31:0] quotient;
      wire [31:0] remainder;
      wire finish;
      div32   u_div(
         .clk(clk),
         .rst(rst),
         .dividend(dividend),
         .divisor(divisor),
         .start(start),
         .quotient(quotient),
         .remainder(remainder),
         .finish(finish)
      );
      always #5 clk = ~clk;
      
      initial begin
       clk =0;
       rst = 1;
       start = 0;
       dividend = 32'd0;
       divisor  = 32'd0;
       #10
       rst = 0;

       {testcases}
       
       $stop();   
      
      end
endmodule
