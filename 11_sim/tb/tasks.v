///////////////////////////////////////////////////////////////////////////////
//
// Project        : 
// Block          : 
// File Name      : 
// Department     : 
// Creation Date  : 
// Author         : 
// Author's email : 
//
///////////////////////////////////////////////////////////////////////////////
//
// Module Description:
//
//
///////////////////////////////////////////////////////////////////////////////
//
// Design Notes :  
//
///////////////////////////////////////////////////////////////////////////////

//
// myLOG
// write INFO message in the log file
//
task mylog;
  input [8*64:1] sim_text;
  begin
     //sim_phase = ""; // clear string first
     //sim_phase = sim_text;
     $display("[%-13t] INFO      : %0s", $time, sim_text);
  end
endtask

task mywarn;
  input [8*64:1] sim_text;
  begin
     $display("[%-13t] WARNING   : %0s", $time, sim_text);
  end
endtask

task myerr;
  input [8*64:1] sim_text;
  begin
     $display("[%-13t] ERROR     : %0s", $time, sim_text);
  end
endtask

//
// check errors, and log message in the affirmative
//
task check_error;
 input reg [(16*8):1] signalname;
 input signalvalue;
 input signalexpected;
 begin
    // shows error only if expected is different from X
    if ((signalexpected !== 1'bx) && (signalexpected !== signalvalue))
       $display("[%-13t] ERROR     : %0s found %b expected %b", $time, signalname, signalvalue, signalexpected);
	else
       $display("[%-13t] INFO      : %0s found %b", $time, signalname, signalvalue);
 end
endtask

task check_error8;
 input reg [(16*8):1] signalname;
 input [7:0] signalvalue;
 input [7:0] signalexpected;
 begin
    // shows error only if expected is different from X
    if ((signalexpected !== 8'bx) && (signalexpected !== signalvalue))
       $display("[%-13t] ERROR     : %0s found %h expected %h", $time, signalname, signalvalue, signalexpected);
	else
       $display("[%-13t] INFO      : %0s found %h", $time, signalname, signalvalue);
 end
endtask

task check_error16;
 input reg [(16*8):1] signalname;
 input [15:0] signalvalue;
 input [15:0] signalexpected;
 begin
    // shows error only if expected is different from X
    if ((signalexpected !== 16'bx) && (signalexpected !== signalvalue))
       $display("[%-13t] ERROR     : %0s found %h expected %h", $time, signalname, signalvalue, signalexpected);
	else
       $display("[%-13t] INFO      : %0s found %h", $time, signalname, signalvalue);
 end
endtask

task check_error32;
 input reg [(16*8):1] signalname;
 input [31:0] signalvalue;
 input [31:0] signalexpected;
 begin
    // shows error only if expected is different from X
    if ((signalexpected !== 32'bx) && (signalexpected !== signalvalue))
       $display("[%-13t] ERROR     : %0s found %h expected %h", $time, signalname, signalvalue, signalexpected);
	else
       $display("[%-13t] INFO      : %0s = %h", $time, signalname, signalvalue);
 end
endtask

// every 4-bits hex number is transformed into an 8-bits ASCII
function logic [63:0] hex2str (
  input [31:0] hexin
  );
  int i;
  logic [31:0] temp;
  logic [63:0] temp_str;
  begin
     temp_str = 0;
     for (i=0; i<32; i++)
	 begin
	    temp = (hexin >> (4*i)) & 32'h0000_000F;
		if (temp>9) 
		   temp_str = ((temp+55)<<(i*8)) | temp_str; // 65=="A"
		else
		   temp_str = ((temp+48)<<(i*8)) | temp_str; // 48=="0"
	 end
     hex2str=temp_str;
  end
endfunction


//
// Init task
//
task myinit;
  begin
     nreset = 1'bx;
     tm_inc_pc = 1'bx;
     tm_en = 1'bx;
     rxd = 4'bx;

	  #(30) 
     $display("[%0t] reset=0", $time);
     nreset = 1'b0;
     tm_inc_pc = 1'b0;
     tm_en = 1'b0;
     rxd = 4'b0;

	  #(1000)
	  mylog("reset=1");
     nreset = 1'b1;

	  #(1000);
     
  end
endtask

