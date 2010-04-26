module duck_hunt_tb();

reg rst, trig_in, lig_in, dat_in;
duck_hunt top(.rst(rst));//, .trigger_in(trig_in), .light_in(lig_in), .data_in(dat_in));


initial begin
  rst = 1'b1;
  dat_in = 0;
  lig_in = 1;
  trig_in = 1;
  #110 rst = 1'b0;
end

initial begin
  forever begin
  #90100 trig_in = 0;
  #90100 trig_in = 1;
end
end
initial begin
  forever begin
  #300000 rst = 1'b1;
  #100 rst = 0;
  end
  end
endmodule