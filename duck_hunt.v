`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:45:06 04/11/2010 
// Design Name: 
// Module Name:    duck_hunt 
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
module duck_hunt(clk_100mhz, rst,clk_25mhz, blank, comp_sync, hsync, vsync, 
pixel_r, pixel_g, pixel_b, led0, led1, 
trigger_in, light_in, 
data_in, latch_out, clk_out, 
//clk12mhz, synch, audio_data_out, audio_rst, //audio I/O , tie to pins listed in Audio_control
led2, led3, clk_rst); 
	 input clk_100mhz;
    input rst;
	 input clk_rst;
	 input trigger_in, light_in;
	 output clk_25mhz;
	 output blank; 
	 //output synch, audio_data_out, audio_rst, clk12mhz;
	 output comp_sync;
    output hsync;
    output vsync;
	 output led0;
	 output led2; //led2
	 output led1; 
	 output latch_out, clk_out;
	 input data_in;
    output [7:0] pixel_r;
    output [7:0] pixel_g;
    output [7:0] pixel_b;
	 output led3;
	 wire [9:0] sprite_x;
	 wire [8:0] sprite_y;
	 wire sprite_vis, sprite_pos, sprite_attr, bck_ch_active, font_ch_active, font_en;
	 wire [4:0] sprite_sel;
	 wire [1:0] bck_sel; 
	 wire [3:0] font_data;
    wire [10:0] font_addr;
    wire [1:0] interrupts;
    wire int_out_g, int_out_c;
    wire [7:0] controller_data;
    wire [3:0] audioSel;
    wire [4:0] audioVol;
	wire [3:0] pc;
	wire cnt_int;
	reg trig, posz, c0, c1;
	
	 assign led0 = trig; //led0
	 assign led1 = posz; //led1
	 assign led2 = c0; //led2
	 assign led3 = c1; //led3
vgamult vga(clk_100mhz, rst, clk_25mhz, blank, comp_sync, hsync, vsync, pixel_r, pixel_g, pixel_b, sprite_x, sprite_y, sprite_vis, 
				sprite_pos, sprite_attr, sprite_sel, bck_ch_active, bck_sel,
				font_ch_active, font_data, font_addr, font_en, clk_rst);

assign interrupts = {2'b00};
parameter D_MEM = "data.txt";
parameter I_MEM = "timer.txt";
parameter D_W = 9;
parameter I_W = 11;
parameter IA1 = 32'h0000001c;  //interrupts[0] 
parameter IA2 = 32'h0000001e; //interrupts[1] 
parameter IA3 = 32'h00000010; //counter0
parameter IA4 = 32'h00000012; //counter1
		
toplevelfinal #(D_MEM, I_MEM, D_W, I_W, IA1, IA2, IA3, IA4) proc(clk_25mhz, rst, sprite_x, sprite_y, sprite_sel, sprite_attr, sprite_pos, sprite_vis, bck_ch_active,	
font_ch_active, font_clr, font_en, font_addr, font_data, 
bck_sel, interrupts, audioVol, audioSel, audioEn, gun_data, controller_data, cnt_int, pc);

always @ (posedge clk_25mhz) begin
 if (rst) trig <= 1;
 else if (pc[3]) trig <= ~trig;
 else trig <= trig;
end

always @ (posedge clk_25mhz) begin
 if (rst) posz <= 1;
 else if (pc[1]) posz <= ~posz;
 else posz <= posz;
end


always @ (posedge clk_25mhz) begin
 if (rst) c0 <= 1;
 else if (pc[3]) c0 <= ~c0;
 else c0 <= c0;
end

always @ (posedge clk_25mhz) begin
 if (rst) c1 <= 1;
 else if (pc[2]) c1 <= ~c1;
 else c1 <= c1;
end


reg [30:0] counts;
always @ (posedge clk_25mhz) begin
 if (rst| int_out_c) counts <= 0;
 else counts <= counts+1;
end

assign int_out_g = (counts == 40) ? 1 : 0;
assign int_out_c = (counts == 107) ? 1 : 0;

//g_control gun(clk_25mhz, rst, trigger_in, light_in, int_out_g, gun_data);
//c_control con(clk_25mhz, rst, data_in, latch_out, clk_out, controller_data, int_out_c);
//Audio_Control aud(clk_25mhz, rst, audioEn, audioVol, audioSel, clk12mhz, synch, audio_data_out , audio_rst);
endmodule
