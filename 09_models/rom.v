/*
///////////////////////////////////////////////////////////////////////////////
//
// Project        : -
// Block          : rom
// File Name      : rom.v
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
// ROM generic model
//
//
///////////////////////////////////////////////////////////////////////////////
//
// Design Notes :  
//
///////////////////////////////////////////////////////////////////////////////
*/
`timescale 1ns/1ps

`celldefine
module rom ( Q, A );

parameter ADDR_SIZE  = 12;
parameter WORD_SIZE  = 16;
parameter FILE_PATH  = "prog.hex";

output [WORD_SIZE-1:0]   Q;   // data output
input  [ADDR_SIZE-1:0]   A;   // address

reg [WORD_SIZE-1:0]  mem [0:(1<<ADDR_SIZE)-1];
reg [WORD_SIZE-1:0]  Q_i;

integer i;
initial
begin
    $readmemh(FILE_PATH, mem); //<filename>, <array>, [start_address], [end_address])
end

assign #(2) Q = mem[A];


endmodule
`endcelldefine

