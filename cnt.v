`timescale 1 ns / 1 ps

module counter (input clk, reset,
                input set,
                input [31:0] val1,
                output c_int);
reg [31:0] tmp;
reg [31:0] val;

initial begin
val <= 32'hffffffff;
end

always @(posedge clk)
  if(reset | set)
    val <= val1;
  else
    val <= val;
    
  
always @(posedge clk)
  begin
    if (reset | (tmp == val) | set)
      tmp <= 32'h00000000;
    else
      tmp <= tmp + 1'b1;
  end

  assign c_int = reset ? 0 : (tmp == val) ? 1 : 0;
  
  
endmodule