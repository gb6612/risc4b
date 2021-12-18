/*
///////////////////////////////////////////////////////////////////////////////
//
// Project        : -
// Block          : chip
// File Name      : chip.v
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
// Top level wrapper with core and memories
//
//
///////////////////////////////////////////////////////////////////////////////
//
// Design Notes :  
//
///////////////////////////////////////////////////////////////////////////////
*/
`timescale 1ns / 1ps

module chip (
   input  logic        nreset      ,
   input  logic        clk         ,
   input  logic        tm_inc_pc   ,
   input  logic        tm_en       ,

   input  logic [3:0]  rxd         ,
   output logic [3:0]  txd         ,

   output logic [3:0]  test
);

wire [11:0] prog_addr;
wire [11:0] prog_data;

wire [7:0]  ram_addr;
wire [3:0]  ram_rdata;
wire [3:0]  ram_wdata;
wire        ram_we;

wire [3:0]  ee_ctrl  ;
wire [7:0]  ee_wdata ;
wire [7:0]  ee_rdata ;
wire [7:0]  ee_addr  ;

wire [3:0]  dummy    ;

risc4b CORE_I0(
   .nreset      (nreset     ), // i
   .clk         (clk        ), // i
   .tm_inc_pc   (tm_inc_pc  ), // i
   .tm_en       (tm_en      ), // i
   .prog_addr   (prog_addr  ), // o [11:0]
   .prog_data   (prog_data  ), // i [11:0]  
   .rxd         (rxd        ), // i [3:0]
   .txd         (txd        ), // o [3:0]
   .ee_ctrl     (ee_ctrl    ), // o [3:0]
   .ee_wdata    (ee_wdata   ), // o [7:0]
   .ee_rdata    (ee_rdata   ), // i [7:0]
   .ee_addr     (ee_addr    ), // o [7:0]  
   .test        (test       ), // o [3:0]
   .ram_addr    (ram_addr   ), // o [5:0]
   .ram_rdata   (ram_rdata  ), // i [3:0]
   .ram_wdata   (ram_wdata  ), // o [3:0]
   .ram_we      (ram_we     )  // o
);

// Program memory
rom ROM_I0( .Q({dummy[3:0], prog_data}), .A(prog_addr) );

// RAM Memory
sram_v2 RAM_I0 ( .Q(ram_rdata), .WEN(ram_we), .A(ram_addr), .D(ram_wdata) );

// NVM
eeprom EE_I0( .Q(ee_rdata), .EN(1'b1), .WR(ee_ctrl[0]), .RD(ee_ctrl[1]), .ERASE(ee_ctrl[2]), .A(ee_addr), .D(ee_wdata) );


endmodule