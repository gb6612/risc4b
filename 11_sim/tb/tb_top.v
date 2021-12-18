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
// This DUT compiles only the actual simulation pattern (not all)
//
//
///////////////////////////////////////////////////////////////////////////////
//
// Design Notes :  
//
///////////////////////////////////////////////////////////////////////////////
`include "timescale.v"

module top;

`resetall

`define OSC_PERIOD0     25
`define OSC_PW0         12
`define Tcycle          1*`OSC_PERIOD0

integer i;

//---------------------------------------------
//---------- Signals of top level design
//---------------------------------------------
supply1	vdd;
supply0	gnd;

reg  nreset;
reg  clk = 0;

reg  tm_inc_pc = 0;
reg  tm_en = 0;

reg  [3:0] rxd = 4'b0;
wire [3:0] txd;
wire [3:0] test;

//`include "defines.v"
`include "tasks.v"

//---------------------------------------------
//---------- Instance Top
//---------------------------------------------

chip CHIP_I0(
   .nreset      (nreset   ),
   .clk         (clk      ),
   .tm_inc_pc   (tm_inc_pc),
   .tm_en       (tm_en    ),

   .rxd         (rxd      ),
   .txd         (txd      ),

   .test        (test     )
);

//---------------------------------------------
//---------- Other stuff
//---------------------------------------------
/* CLOCK */
real osc_pw1;
initial 
begin
    #(14) clk = 1'b0;
	forever
    begin
	    osc_pw1 = `OSC_PW0;
      #(`OSC_PERIOD0-osc_pw1) clk = 1'b1;
      #(osc_pw1)              clk = 1'b0;
	end
end 


reg [8*32:1] testname;  // arbitrarily limit the name of the simulation to 32 characters
reg [8*32:1] subtestname;

initial
begin
    $value$plusargs("test=%s", testname);
    
    `ifdef pat_nop
        `include "pattern/pat_nop.v" 
    `elsif pat_tm_inc
        `include "pattern/pat_tm_inc.v" 
    `elsif pat_loop
        `include "pattern/pat_loop.v" 
    `elsif pat_meadarm
        `include "pattern/pat_meadarm.v" 
    `else
       begin $display("ERROR : no pattern found");  end
    `endif

  //#(1000);
  $display("**************************************************");
  //$system("date /t");
  //$system("time /t");
  $display("************ SIMULATION ENDED ********************");
  $stop;
end


//---------------------------------------------
// my WatchGoose, in case of stucked sim
initial
begin
   #(1000ms)
   $display("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
   $display("[%-13t] ERROR : SIMULATION ENDED BY THE WATCHGOOSE", $time);
   $display("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
   $stop;
end

endmodule // top
