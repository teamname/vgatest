module tohex();


  reg [31:0] ins [1000:0];
  integer file_handle, TEST_SZ,out;
  integer num_bytes_in_line;
  initial begin
  file_handle = $fopen("instruction.txt","r");
  out = $fopen("instructionhex.txt", "w");
  TEST_SZ = 0;
    while(!$feof(file_handle)) begin
      num_bytes_in_line= $fscanf(file_handle,"%b\n" ,ins[TEST_SZ]);//make fscanf!!
      $display("%h", ins[TEST_SZ]);
	$fdisplay(out, "%h", ins[TEST_SZ]);
      TEST_SZ = TEST_SZ + 1;
    end 
  end
    
  endmodule
