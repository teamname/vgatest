`timescale 1 ns / 1 ps
module fetch(input clk, reset, 
                  input [31:0] pc_D,
                  input br_stall, stall,
                  input [1:0] pc_sel,
                  input [31:0] pc_branch,
                  input [3:0] interrupts,
                  input rti,

                  output [31:0] pc,

                  output [31:0] pc_plus_4,
                  output int_en1, output reg sr, 
	  	  output [3:0] interrupt_taken);

  wire [31:0] pcnextF1, pcnextF2, pcnextF;
  wire [31:0] epc, epc_in;
  wire int_en, inter0, inter1, inter2, inter3;
  wire [3:0] reset_l, inter_rst;
  wire epc_en;

  parameter IA1 = 32'h00000018;  //IO interrupt[0] 
parameter IA2 = 32'h0000002c; //IO interrupt[1] 
parameter IA3 = 32'h0000001b; //counter0
parameter IA4 = 32'h00000030; //counter1


  assign interrupt_taken = inter_rst;

  assign int_en = (|interrupts) & sr &~stall ;
 
   
mux_4 #(32) pcmux(32'h00000000, 32'h00000000 ,
                    pc_plus_4, pc_branch, pc_sel, pcnextF1);
 //reset, interrupt, pc+1, branch

  assign pcnextF2 =  int_en1 ? (inter0 ? IA1 :
                  (inter1 ? IA2 :
                  (inter2 ? IA3 :
                  IA4 ))) : pcnextF1;
  assign epc_in = (int_en1 & pc_sel[1] & pc_sel[0]) ? pcnextF1 : pc_D;
  assign epc_en = int_en1 ? 1'b1:int_en;
  
  assign pcnextF =  rti ? epc : pcnextF2;
                  
  flip_flop_enable #(32) PC(clk,reset, ~stall , pcnextF, pc);
  
  flip_flop_enable #(32) EPC(clk,reset, int_en1 , epc_in, epc);
  
  assign intrst_en = (int_en1) ? 1'b1 : 1'b0;
  //stores what interrupt we are handling
  flip_flop_enable #(4) intrst (clk, reset, intrst_en, {(inter3 & ~inter2 & ~inter0 &~inter1),(inter2 & ~inter0 &~inter1), (inter1 & ~inter0), inter0}, inter_rst);
  
  
  assign reset_l = {inter_rst[3] & rti, inter_rst[2] & rti, inter_rst[1] & rti, inter_rst[0] & rti}; //reset for interrupt latches
    
  flip_flop_enable_clear #(1) int0(clk, reset, interrupts[0], reset_l[0], 1'b1, inter0);
  flip_flop_enable_clear #(1) int1(clk, reset, interrupts[1], reset_l[1], 1'b1, inter1);
  flip_flop_enable_clear #(1) int2(clk, reset, interrupts[2], reset_l[2], 1'b1, inter2);
  flip_flop_enable_clear #(1) int3(clk, reset, interrupts[3], reset_l[3], 1'b1, inter3);
  
  assign int_en1 = (inter0 | inter1 | inter2 | inter3) & sr & ~stall & ~br_stall;
   
  always@ (posedge clk) begin
    if(reset | rti) begin
      sr <= 1'b1;
    end
    else begin
      if(int_en1) begin 
        sr <= 0;
      end
      else begin
        sr <= sr;
      end
	  end
  end
  
  
   assign pc_plus_4 = pc + 1;


endmodule
