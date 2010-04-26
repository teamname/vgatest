`timescale 1 ns / 1 ps
module fetch(input clk, reset, 
                  input br_stall, stall,
                  input [1:0] pc_sel,
                  input [31:0] pc_branch,
                  input [3:0] interrupts,
                  input rti,

                  output [31:0] pc,

                  output [31:0] pc_plus_4,
                  output int_en1, output reg sr);

  wire [31:0] pcnextF1, pcnextF2, pcnextF;
  wire [31:0] epc;
  wire int_en, inter0, inter1, inter2, inter3;
  wire [3:0] reset_l, inter_rst;
  
  parameter RESET_ADDRESS = 32'h00000000;
parameter IA1 = 32'h00000020;  //IO interrupt[0] 
parameter IA2 = 32'h00000020; //IO interrupt[1] 
parameter IA3 = 32'h00000009; //counter0
parameter IA4 = 32'h00000009; //counter1
  parameter EXCEPTION_ADDRESS = 32'h00000100;
  
  assign int_en = (|interrupts) & sr &~stall & ~br_stall ;
  
   
mux_4 #(32) pcmux(RESET_ADDRESS, pcnextF2 ,
                    pc_plus_4, pc_branch, pc_sel, pcnextF1);
 

  assign pcnextF2 = inter0 ? IA1 :
                  (inter1 ? IA2 :
                  (inter2 ? IA3 :
                  IA4 ));
  
  assign pcnextF = rti ? ((epc > 2) ? epc-3  : 0) : pcnextF1;
                  
  flip_flop_enable #(32) PC(clk,reset, ~stall, pcnextF, pc);
  
  flip_flop_enable #(32) EPC(clk,reset, int_en1, pc_plus_4, epc);
  
  //stores what interrupt we are handling
  flip_flop_enable #(4) intrst (clk, reset, int_en1, {(inter3 & ~inter2 & ~inter0 &~inter1),(inter2 & ~inter0 &~inter1), (inter1 & ~inter0), inter0}, inter_rst);
  
  
  assign reset_l = {inter_rst[3] & rti, inter_rst[2] & rti, inter_rst[1] & rti, inter_rst[0] & rti}; //reset for interrupt latches
    
  flip_flop_enable_clear #(1) int0(clk, reset, interrupts[0], reset_l[0], 1'b1, inter0);
  flip_flop_enable_clear #(1) int1(clk, reset, interrupts[1], reset_l[1], 1'b1, inter1);
  flip_flop_enable_clear #(1) int2(clk, reset, interrupts[2], reset_l[2], 1'b1, inter2);
  flip_flop_enable_clear #(1) int3(clk, reset, interrupts[3], reset_l[3], 1'b1, inter3);
  
  assign int_en1 = (inter0 | inter1 | inter2 | inter3) & sr;
  
  always@ (posedge clk) begin
    if(reset | rti) begin
      sr <= 1'b1;
    end
    else begin
      if(int_en1)
        sr <= 1'b0;
      else
        sr <= sr;
	  end
  end
  
  
   assign pc_plus_4 = pc + 1;


endmodule
