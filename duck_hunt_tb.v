`timescale 1 ns / 1 ps
module duck_hunt_tb();

reg rst, trig_in, lig_in, dat_in;
duck_hunt top(.rst(rst));


initial begin
  rst = 1'b1;
  dat_in = 0;
  lig_in = 1;
  trig_in = 1;
  #60 rst = 1'b0;
end

initial begin
  forever begin
  #90100 trig_in = 0;
  #90100 trig_in = 1;
end
end

endmodule