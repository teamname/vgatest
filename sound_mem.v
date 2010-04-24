`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:42:32 03/23/2010 
// Design Name: 
// Module Name:    sound_mem 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module sound_mem(clk, addr, rdata);
   parameter ROM_DATA_FILE = "Sound.mem";
      input clk;
      input [17:0] addr;
      output reg [3:0] rdata;
      
      reg [3:0] MY_ROM [0:2**18-1];
      initial $readmemb(ROM_DATA_FILE, MY_ROM);
      always @(posedge clk) rdata <= MY_ROM[addr];
endmodule
