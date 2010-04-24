`timescale 1 ns / 1 ps
module RF(input         clk, reset,
               input         we, 
               input  [4:0]  reg_address_1, reg_address_2, write_address, 
               input  [31:0] data, 
               output [31:0] rd1, rd2);

  reg [31:0] regFile[31:0];
integer k;

initial begin
  for(k = 0; k < 32; k = k+1)
    regFile[k] <= 0;
  end

  always @(negedge clk) begin
   if(reset) begin
	for(k = 0; k < 32; k = k+1) 
    regFile[k] <= 0;
  end
	else if (we) regFile[write_address] <= data;
end

  assign rd1 = (reg_address_1 != 0) ? regFile[reg_address_1] : 0;
  assign rd2 = (reg_address_2 != 0) ? regFile[reg_address_2] : 0;
  
  
  //reg 29 stack pointer
  
endmodule

