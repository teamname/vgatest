module sim_clk_gen(clk100buf, clk25);
  output reg clk100buf, clk25;
  
  initial begin
    clk100buf = 1'b0;
    clk25 = 1'b0;
    forever begin
      #5 clk100buf = ~clk100buf;
     
    end
  end
  
  initial
  forever
   #20 clk25 = ~clk25;
  
endmodule
