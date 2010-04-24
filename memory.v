module memory
   #(parameter RAM_ADDR_BITS = 10, parameter RAM_FILE = "test.mem") 
(input clk, wr_en, input [RAM_ADDR_BITS - 1: 0] addr, input [31: 0]data_in, output reg [31: 0] mem_out, output reg rd_ack, input [RAM_ADDR_BITS - 1: 0]test_in, output [31: 0]test_out, input stall);

   reg [31:0] ram [(2**RAM_ADDR_BITS)-1:0];
   
   reg [RAM_ADDR_BITS - 1: 0] addrin;

   //  The following code is only necessary if you wish to initialize the RAM 
   //  contents via an external file (use $readmemb for binary data)
   initial begin
      $readmemh(RAM_FILE, ram);
      rd_ack = 0;
  $display("using file %s", RAM_FILE);
 end


   always @(posedge clk) begin
         rd_ack <= 1'b1;
         if (wr_en) begin
            ram [addr] <= data_in;
            mem_out <= 0;
          end
          else if(~stall) begin
            mem_out <= ram[addr];
            rd_ack <= 1'b1;
          end
   end
   

  assign test_out = ram[test_in];
	endmodule
