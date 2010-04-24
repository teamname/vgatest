module toplevelfinal(input clk, reset, 

                output [9:0] sprite_x, output [8:0] sprite_y, output [4:0] sprite_sel, 
  output sprite_attr, sprite_pos, sprite_vis, bck_ch_active,
  output font_ch_active, font_clr, font_en,
  output [10:0] font_addr,
  output [3:0] font_data,
  output [1:0] bck, input [1:0] interrupts,
  output [4:0] audioVol, output [3:0] audioSel, output audioEn,
input gun_data, input [7:0] controller_data, output cnt_int, output [3:0] PCD);
  
  parameter D_MEM = "data.txt";
  parameter I_MEM = "guntest2.txt";
  parameter D_W = 8;
  parameter I_W = 10;
  wire [31:0] instr_addr;
  wire [31:0] mem_addr;
  wire [31:0] mem_data; 
  wire [31:0] instr_data;
  wire [31:0] wr_data;
  wire [7:0] data_addr_in;
  wire [9:0] instr_addr_in;
  wire stallMem;  
	 
  mips proc (clk, reset, instr_addr, instr_data, wr_en, mem_addr, wr_data, mem_data, instr_ack, mem_ack,
  sprite_x,  sprite_y, sprite_sel,
   sprite_attr, sprite_pos, sprite_vis, bck_ch_active,
   font_ch_active, font_clr, font_en,
    font_addr,
    font_data,
   bck, interrupts, audioVol, audioSel, audioEn, stallMem,
   gun_data, controller_data, cnt_int, PCD);
  
  assign data_addr_in = mem_addr[7:0]; 
  assign instr_addr_in = instr_addr[9:0];
  
  memoryfinal #(D_W, D_MEM) data (clk, wr_en, data_addr_in, wr_data, mem_data, mem_ack, 1'b0); 

  memoryfinal #(I_W, I_MEM) instr (clk, 1'b0, instr_addr_in, 32'h0000, instr_data, instr_ack, stallMem);
  
endmodule
