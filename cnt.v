`timescale 1 ns / 1 ps

module counter (input clk, reset,
                input set, int_disable,
                input [31:0] val1,
                output c_int);
reg [31:0] tmp;
reg [31:0] val;
reg off;

initial begin
val <= 32'hffffffff;
off<= 1;
tmp <= 32'h00000000;
end

always @(posedge clk) begin
  if(reset) begin
    val <= val1;
	 off <= 1;
  end
  else if(set) begin
      val <= val1;
		off <= 0;
  end
  else if(int_disable)
		off <= 1;
  else begin
    val <= val;
	 off <= off;
    end
end
  
always @(posedge clk)
  begin
    if (reset | (tmp == val) | set)
      tmp <= 32'h00000000;
    else
      tmp <= tmp + 1'b1;
  end

  assign c_int = (reset | off) ? 0 : (tmp == val) ? 1 : 0;
  
  
endmodule