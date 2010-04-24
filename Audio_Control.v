`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:27:42 03/17/2010 
// Design Name: 
// Module Name:    Audio_Control 
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
module Audio_Control(
                     input SYSTEM_Clock, //25 MHz clock
							input SYSTEM_Rst, //reset
                     input start,  //start sound
							input [4:0] vol, //5 bit volume
							input [3:0] sel, //4 bit sound select
							input AC97_BIT_CLOCK, //Tie to pin F8
							output reg AC97_SYNCH, //Tie to pin F7
							output AC97_SDATA_OUT, //Tie to pin E8
							output AUDIO_RESET_Z //Tie to pin E6
    ); 
	
	 //The start positions of each sound in memory
	 parameter WingFlap = 18'd7009;
	 parameter DuckFall = 18'd8161;
	 parameter DuckHittingGround = 18'd20963;
	 parameter DuckRelease = 18'd21765;
	 parameter DogLaugh = 18'd29009;
	 parameter Bark = 18'd40046;
	 parameter Quack = 18'd41515;
	 parameter RoundStart = 18'd42598;
	 parameter EndOfRound = 18'd86078;
	 parameter Pause = 18'd113735;
	 parameter Point = 18'd117053;
	 parameter GameStart = 18'd118684;
	 parameter Win = 18'd148609;
	 parameter Lose = 18'd176137;
	 parameter PerfectRound = 18'd188168;
	 parameter endmem = 18'd199203;
	 
	
	 assign AUDIO_RESET_Z = !SYSTEM_Rst;
	 
	 
	 //Extends the 25 MHz input signal so that it can be used with the 12.288 MHz codec
	 //Stores the signal until a negative edge of the AC97 codec clock is seen
	 reg start2;      //Stores 1 bit start signal
	 reg [4:0] vol2;  //Stores 5 bit volume signal
	 reg [3:0] sel2;  //Stores 4 bit select signal
	 reg [1:0] state; //State machine for lengthening input signal
	 reg ac_clock; //Stores the previous state of the codec clock
	 
	 always @(posedge SYSTEM_Clock, posedge SYSTEM_Rst) begin
	 
	    if (SYSTEM_Rst) begin
		    start2 <= 1'd0;
			 vol2 <= 5'd0;
			 sel2 <= 4'd0;
			 state <= 2'd0;
			 ac_clock <= 0;
		 end
		 
		 //Got a start signal from the processor
		 else if (state == 2'd0 && start) begin
		    start2 <= start;
			 vol2 <= ~vol; //Volume is active-low in the codec, reverse it here
			 sel2 <= sel;
			 ac_clock <= AC97_BIT_CLOCK;
			 if (AC97_BIT_CLOCK) state <= 2'd2; //Bit clock a 1, wait for negedge
			 else state <= 2'd1; //Bit clock a 0, need to wait longer
		 end
		 
		 //Codec clock was 0, and it changed to a 1 (posedge)
		 else if (state == 2'd1 && (ac_clock != AC97_BIT_CLOCK)) begin
			 state <= 2'd2;
			 ac_clock <= 1'b1;
		 end
		 
		 //Codec clock was a 1, and it changed to a 0 (negedge)
		 else if (state == 2'd2 && (ac_clock != AC97_BIT_CLOCK)) begin
		    start2 <= 1'd0;
			 state <= 2'd0;
		 end
	 end
	 

    reg [17:0] tail; //Points to the beginning address of the sound effect to play
    reg [17:0] head; //Points to the final address of the sound effect to play

    //The memory where the sound effects are stored
    wire [3:0] rdata;
    sound_mem memory (.clk(AC97_BIT_CLOCK), .addr(tail[17:0]), .rdata(rdata[3:0]));

    reg [3:0] PCM; //4 bits of PCM data, read from memory
    
    reg newFrame; //1 the codec is switching frames
    reg [2:0] frameCount; //Need to send a frame only every sixth frame cycle
	 
	 reg flapping; //1 when the wing flapping sound effect is toggled
	 reg [4:0] currvol; //Volume of the sound currently being played
	 reg [4:0] flapvol; //Separate volume register for wing flaps
	 
	 //Busy is a 1 whenever a sound is currently being played
	 wire busy;
	 assign busy = (tail < head);
	 
	 always @ (negedge AC97_BIT_CLOCK) begin
	    
	    if (SYSTEM_Rst) begin
	       tail <= 18'd0;
	       head <= 18'd0;
	       PCM <= 4'd0;
			 currvol <= 5'd0;
			 flapvol <= 5'd0;
			 flapping <= 1'b0;
	    end
	    
		 //Got a start signal, begin playing sound
	    else if (start2) begin
		 	 
			 //Don't change the current volume for flap toggle
			 if (sel2 != 4'd1) currvol <= vol2;
			 
			 case (sel2[3:0])
				4'd0: begin
					tail <= 18'd0;
					head <= WingFlap - 1'd1;
				end
				4'd1: begin
				   flapping <= !flapping;
					flapvol <= vol2;
				end
				4'd2: begin
					tail <= DuckFall;
					head <= DuckHittingGround - 1'd1;
				end
				4'd3: begin
					tail <= DuckHittingGround;
					head <= DuckRelease - 1'd1;
				end
				4'd4: begin
					tail <= DuckRelease;
					head <= DogLaugh - 1'd1;
				end
				4'd5: begin
					tail <= DogLaugh;
					head <= Bark - 1'd1;
				end
				4'd6: begin
					tail <= Bark;
					head <= Quack - 1'd1;
				end
				4'd7: begin
					tail <= Quack;
					head <= RoundStart - 1'd1;
				end
				4'd8: begin
					tail <= RoundStart;
					head <= EndOfRound - 1'd1;
				end
				4'd9: begin	
					tail <= EndOfRound;
					head <= Pause - 1'd1;
				end
				4'd10:begin
					tail <= Pause;
					head <= Point - 1'd1;
				end
				4'd11:begin
					tail <= Point;
					head <= GameStart - 1'd1;
				end
				4'd12:begin
					tail <= GameStart;
					head <= Win - 1'd1;
				end
				4'd13:begin
					tail <= Win;
					head <= Lose - 1'd1;
				end
				4'd14:begin
					tail <= Lose;
					head <= PerfectRound - 1'd1;
				end
				4'd15:begin
					tail <= PerfectRound;
					head <= endmem;
				end
			 endcase
	    end
	    
		 //Read a new 4-bit piece of sound data
	    else if (newFrame && frameCount == 3'd2) begin
			 //Increment the tail if currently playing a sound
	       if (busy) begin 
	          tail <= tail + 1'd1;
	          PCM <= rdata;
	       end
	    end
		 
		 //Always play a wing flap if no other sound is being played
		 else if (!busy && flapping) begin
		    tail <= WingFlap;
		    head <= DuckFall - 1'd1;
		    currvol <= flapvol; 
		 end
	 end
	 
	 
	 reg [8:0] counter; //counter to count from 256 to 0 (256 bits per frame)
	 reg active;  //1 if the current frame has valid data to be sent to Codec
    always @(negedge AC97_BIT_CLOCK) begin
	 
	    if (SYSTEM_Rst) begin 
		    counter <= 9'd256;
			 AC97_SYNCH <= 1'b0;
			 newFrame <= 1'b0;
			 frameCount <= 3'd0;
			 active <= 1'b0;
		 end
		 
		 //Keep synch signal high until header is done
		 else if (counter > 239) begin
		    counter <= counter - 1'b1;
			 AC97_SYNCH <= 1'b1;
			 newFrame <= 1'b0;
		 end
		 
		 //Start synch signal at last part of current frame
		 else if (counter == 8'd0) begin 
		     counter <= 9'd255;
		     AC97_SYNCH <= 1;
			  newFrame <= 1;
			  case (frameCount)
			     3'd5: begin
			              frameCount <= 3'd0;
			              if (busy) active <= 1;
			           end
			     default: begin 
			        frameCount <= frameCount + 1'd1;
			        active <= 0;
			     end    
			  endcase
		 end
		 else begin
		   counter <= counter - 1;
			 AC97_SYNCH <= 0;
			 newFrame <= 0;
		 end
	 end
	 
	 reg [255:0] sending; //256 bit frame that we are sending
	 reg just_rst, just_rst2; //regs to delay shifting by 2 cycles if just exited reset state
	 always @(negedge AC97_BIT_CLOCK) begin
	    if (SYSTEM_Rst) begin
	       sending <= 256'd0;
	       just_rst <= 1;
			 just_rst2 <= 1;
	    end
	    else if (just_rst) just_rst <= 0;
		 else if (just_rst2) just_rst2 <= 0;
	    else if (newFrame) begin
	       case (frameCount)
	          3'd0: begin
	                    sending <= {active, 15'b00_11_00000000000, //Tag: use slot 3 and 4 only when active
	                                20'd0, 20'd0, //Slot 1 & 2: unused when sending PCM data
	                                PCM[3:0], 16'd0, //Slot 3: 8 bits unsigned PCM data to Left Speaker
	                                PCM[3:0], 16'd0, //Slot 4: 8 bits unsigned PCM data to Right Speaker
	                                20'd0, 20'd0, 20'd0, 20'd0, 20'd0, 20'd0, 20'd0, 20'd0 //Slots 5-12 unused
	                                };
	                end
	          3'd1: begin
	                    sending <= {16'b1_11_00_00000000000, //Tag: use slot 1 and 2
	                                20'b0_0000010_000000000000, //Write to Master Volume Reg
	                                3'b000, currvol[4:0], 3'b000, currvol[4:0], 4'b0000, //Sets L and R volume to 15
	                                20'd0, //Slot 3: unused
	                                20'd0, //Slot 4: unused
	                                20'd0, 20'd0, 20'd0, 20'd0, 20'd0, 20'd0, 20'd0, 20'd0 //Slots 5-12 unused
	                                };
	                end
	          3'd2: begin
	                    sending <= {16'b1_11_00_00000000000, //Tag: use slot 1 and 2
	                                20'b0_0011000_000000000000, //Write to PCM Gain Reg
	                                3'b000, 5'b10000, 3'b000, 5'b10000, 4'b0000, //Sets L and R volume to 15
	                                20'd0, //Slot 3: unused
	                                20'd0, //Slot 4: unused
	                                20'd0, 20'd0, 20'd0, 20'd0, 20'd0, 20'd0, 20'd0, 20'd0 //Slots 5-12 unused
	                                };
	                end
				 default: sending <= 256'd0;
	       endcase
	    end
	    
	    //Shifts sending register left
	    else sending <= {sending[254:0],1'b0};
	 end
	 
	 assign AC97_SDATA_OUT = sending[255];
	 
endmodule