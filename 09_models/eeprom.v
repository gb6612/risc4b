/*
///////////////////////////////////////////////////////////////////////////////
//
// Project        : -
// Block          : eeprom
// File Name      : eeprom.v
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
// EEPROM generic model
//
//
///////////////////////////////////////////////////////////////////////////////
//
// Design Notes :  
//
///////////////////////////////////////////////////////////////////////////////
*/
`timescale 1ns/1ps


module eeprom ( Q, EN, WR, RD, ERASE, A, D );

parameter ADDR_SIZE  = 8;
parameter WORD_SIZE  = 8;
parameter FILE_PATH  = "hex_eeprom.mem";

output [WORD_SIZE-1:0]   Q;   // data output
input  [ADDR_SIZE-1:0]   A;   // address
input  [WORD_SIZE-1:0]   D;   // data input
input                    EN; // enable
input                    WR; // write enable
input                    RD; // read enable
input                    ERASE; // erase

reg [WORD_SIZE-1:0]  mem [0:(1<<ADDR_SIZE)-1];
reg [WORD_SIZE-1:0]  Q_i;


`ifdef INIT_MEM
  initial
  begin
    $readmemh(FILE_PATH, mem); //<filename>, <array>, [start_address], [end_address])
  end
`else
  integer i;
  initial
  begin
    // create random numbers if not initialized
    for (i = 0; i < (1<<ADDR_SIZE); i = i + 1)
      mem[i] = $urandom%((1<<WORD_SIZE)-1); //{WORD_SIZE{1'b0}};
  end
`endif

assign #(2) Q = mem[A];


endmodule


