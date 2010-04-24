`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:26:19 02/23/2010 
// Design Name: 
// Module Name:    c_control 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: A controller to interface with the NES controller.  The NES
//              controller expects a latch input that is high for 12uS (~83kHz) at
//              a rate of 60 Hz.  It also expects eight 83kHz clock cycles after
//              that latch goes low.  These clock cycles are active-low.  This
//              controller then serially reads 8 bits of data from the NES controller
//              and outputs them in an 8-bit wide bus.
//
//              This module expects a clock of 25 MHz.
//              Data_Ready will go low at the same time as read is asserted.
//              After a read, Data_Ready will go high again after the next Latch.
//              Read should not be asserted when Data_Ready is low.
//
//              The 8 button presses are transferred via Parallel_Data[7:0].
//              A 1 means a button is currently pressed down.
//
//              Parallel_Data[7:0] A, B, SEL, START, UP, DOWN, LEFT, RIGHT
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module c_control(
                input SYSTEM_Clock, //25MHz clock from processor
                input SYSTEM_Rst,   //Reset, will work even with constant 0
                input Serial_Data,  //Input from controller, tie to pin L5
                output NES_Latch,   //Output to controller, tie to pin N6
                output NES_Clock,   //Output to controller, tie to pin N5
                output reg [7:0] Parallel_Data, //Output to processor
                output Data_Ready   //Output to processor, interrupt
                 ); 
  
   reg clk_83kHz; // 83.333... kHz NES_Clock
   reg [7:0] counter; //counter to create the NES_Clock
   
   //Creates the 83.333 kHz clock from a 25 MHz clock
   always @ (posedge SYSTEM_Clock, posedge SYSTEM_Rst) begin
      if (SYSTEM_Rst) counter <= 8'd149;
      else if (counter == 0) counter <= 8'd149;
      else counter <= counter - 1'b1;
   end
   always @ (posedge SYSTEM_Clock, posedge SYSTEM_Rst) begin
      if (SYSTEM_Rst) clk_83kHz <= 0;
      else if (counter == 0) clk_83kHz <= ~clk_83kHz;
      else clk_83kHz <= clk_83kHz;
   end 
 
   reg [10:0] counter_60; //Counter to output 60 Hz tick

   //Latch goes high for 1 83kHz clock cycle at 60 Hz
   assign NES_Latch = (counter_60 == 11'd0);

   always @ (posedge clk_83kHz, posedge SYSTEM_Rst) begin
      if (SYSTEM_Rst) counter_60 <= 11'd1388;
  else if (NES_Latch) counter_60 <= 11'd1388;
  else counter_60 <= counter_60 - 1'd1;
   end
 

   //Shifts the Serial NES Controller data into an 8-bit shift register
   always @ (negedge NES_Clock, posedge SYSTEM_Rst) begin
      if (SYSTEM_Rst) Parallel_Data <= 8'd0;
      else Parallel_Data <= {Parallel_Data[6:0], !Serial_Data};
   end

   //A counter to count 8 cycles
   reg [3:0] cycle_count;

   always @ (posedge clk_83kHz, posedge SYSTEM_Rst) begin
      if (SYSTEM_Rst) cycle_count <= 4'd0;
      else if (NES_Latch) cycle_count <= 4'd8;
      else if (cycle_count == 0) cycle_count <= 0;
      else cycle_count <= cycle_count - 1'd1;
   end

   //Outputs 8 clock cycles after a latch
   assign NES_Clock = (cycle_count == 0)? 1 : clk_83kHz;
   
   //Register to delay a ready signal by 1 clock cycle
   reg delay;
   always @ (posedge clk_83kHz, posedge SYSTEM_Rst) begin
      if (SYSTEM_Rst) delay <= 1'b0;
      else if (cycle_count == 1) delay <= 1'b1;
      else delay <= 1'b0;
   end

   //Outputs a single 25 MHz clock cycle when delay goes high   
   reg [1:0] ready;
   always @ (posedge SYSTEM_Clock, posedge SYSTEM_Rst) begin
     if (SYSTEM_Rst) ready <= 2'd0;
     else if (ready == 2'd0 && delay) ready <= 2'd1;
     else if (ready == 2'd1) ready <= 2'd2;
     else if (ready == 2'd2 && NES_Latch) ready <= 2'd0;
     else ready <= ready;
   end

   assign Data_Ready = ready == 2'd1;
   
endmodule