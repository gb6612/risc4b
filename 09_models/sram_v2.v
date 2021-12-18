/*
///////////////////////////////////////////////////////////////////////////////
//
// Project        : -
// Block          : sram_v2
// File Name      : sram_v2.v
// Department     : 
// Creation Date  : 
// Author         : gb
// Author's email : 
// License        : see MIT license file
//
///////////////////////////////////////////////////////////////////////////////
//
// Module Description:
// 
// SRAM generic model
// This RAM is without clock and always-on 
// Data is stored when WEN=0
//
//
///////////////////////////////////////////////////////////////////////////////
//
// Design Notes :  
//
///////////////////////////////////////////////////////////////////////////////
*/

`timescale 1ns/1ps
`define INIT_MEM

`celldefine
module sram_v2 ( Q, WEN, A, D );

parameter ADDR_SIZE     = 8;
parameter WORD_SIZE     = 4;

output [WORD_SIZE-1:0]   Q;   // data output
input  [ADDR_SIZE-1:0]   A;   // address
input  [WORD_SIZE-1:0]   D;   // data input
input                    WEN; // write enable active low
   

reg [WORD_SIZE-1:0]  mem [0:(1<<ADDR_SIZE)-1];
reg [WORD_SIZE-1:0]  Q_i;

`ifdef INIT_MEM
  integer i;
  initial
  begin
    //randomize();
//    for (i = 0; i < (1<<ADDR_SIZE); i = i + 1)
//      mem[i] = {WORD_SIZE{1'b0}};
    // create random numbers if not initialized
    for (i = 0; i < (1<<ADDR_SIZE); i = i + 1)
      mem[i] = $urandom(i); //$urandom%((1<<WORD_SIZE)-1); 
  end 
`endif

always @(*) begin
    if (!WEN) begin
       mem[A] = D;		
       Q_i = mem[A];
    end	
    else begin
       Q_i = mem[A];
    end	
end

assign #(2) Q = Q_i;


endmodule
`endcelldefine

