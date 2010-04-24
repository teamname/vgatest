`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:10:45 03/22/2010 
// Design Name: 
// Module Name:    g_control 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: A controller for the NES Light Gun.  This controller only debounces
//              the trigger pull.  Debouncing is done by counting a large number of
//              consucutive 0's (the trigger is active low).  After it sees alot of
//              0's, it begins counting alot of 1's.  After it sees enough 1's, it
//              knows that the trigger was pulled.  Once the trigger was pulled,
//              the Trigger output goes high, and it will stay high until the
//              read input is asserted.  Trigger goes low in the same cycle that
//              read is asserted.
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module g_control(
					  input SYSTEM_Clock, //25 MHz Clock
					  input SYSTEM_Rst,   //Reset, will work even with constant 0
					  input GUN_Trigger,  //Input from Gun, tie to pin L4
					  input GUN_Light,    //Input from Gun, tie to pin M2
					  output reg Trigger_Pull,     //Output to processor, interrupt
					  output Light        //Output to processor
                );

	assign Light = GUN_Light;

	reg [10:0] zeroCount; //Counts zeros in a row
	reg [10:0] oneCount;  //Counts ones in a row

	always @(posedge SYSTEM_Clock, posedge SYSTEM_Rst) begin
	 
		if (SYSTEM_Rst) begin
			zeroCount <= 0;
			oneCount <= 0;
			Trigger_Pull <= 0;
		end

		//If got a bunch of 0's, and still getting zeros
		else if (zeroCount == 11'b111_1111_1111 && !GUN_Trigger) begin
		   zeroCount <= zeroCount;
			oneCount <= 0;
			Trigger_Pull <= 0;
		end
		
		//If got a bunch of 0's, and got a 1
		else if (zeroCount == 11'b111_1111_1111 && GUN_Trigger) begin
			//If got a bunch of 1s
			if (oneCount == 11'b111_1111_1111) begin
			   Trigger_Pull <= 1; //Trigger was pulled
				zeroCount <= 0; //Reset 0's
				oneCount <= oneCount; //Keep 1's
			end
			//Otherwise haven't gotten a bunch of 1's
			else begin 
			   oneCount <= oneCount+1'b1; //Increment 1's
				Trigger_Pull <= 0;
				zeroCount <= zeroCount; //Keep 0's
		   end
		end
		
		//Got a 0, increment 0's, reset 1's
		else if (!GUN_Trigger) begin
		   zeroCount <= zeroCount + 1'b1;
			oneCount <= 0;
			Trigger_Pull <= 0;
		end
		
		//Got a 1, increment 1's, reset 0's
		else if (GUN_Trigger) begin
		   zeroCount <= 0;
			oneCount <= oneCount + 1'b1;
			Trigger_Pull <= 0;
		end
	 end
endmodule