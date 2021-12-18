/*
///////////////////////////////////////////////////////////////////////////////
//
// Project        : -
// Block          : risc4b
// File Name      : risc4b.v
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
// ALU (Arithmetic Logic Unit) for RISC4B (4 bits RISC)
//
///////////////////////////////////////////////////////////////////////////////
//
// Design Notes :  
//
///////////////////////////////////////////////////////////////////////////////
*/
`timescale 1ns / 1ps

module alu (
           nreset      , 
           clk         ,
           opcode      ,
           operation   ,
           alu_reg_in  ,
           w_accu      ,
           zero        ,
           carry
);

parameter REG_SIZE     = 4 ;

input            nreset      ;
input            clk         ;   
input [3:0]      opcode      ;
input [3:0]      operation   ;
input      [(REG_SIZE-1):0] alu_reg_in  ;
output reg [(REG_SIZE-1):0] w_accu      ;
output reg       zero        ;
output reg       carry       ;

// signals that indicates binary/unary instructions
wire       binary_op ;
wire       unary_op  ;
reg        CO        ;
wire       Y         ;
wire       Z         ;
wire [(REG_SIZE-1):0] Reg_xor   ;
reg  [(REG_SIZE-1):0] W         ;
wire [(REG_SIZE-1):0] in_A      ;
wire [(REG_SIZE-1):0] in_B      ;
wire [(REG_SIZE):0] S           ;

//-------------------------------------------
//-- unary or binary
//-------------------------------------------
assign binary_op = (opcode==4'h8 || opcode==4'h9) ? 1'b1 : 1'b0;
assign unary_op  = (opcode==4'hA || opcode==4'hB) ? 1'b1 : 1'b0;

//-------------------------------------------
//-- Y is the ADDER Carry-in
//-------------------------------------------
assign Y = (!operation[2]) ? ((operation[1] || carry) && !unary_op) :
                             ((operation[1] && carry) && !unary_op);

assign Z = ~|W; 

assign Reg_xor = (operation[2]) ? alu_reg_in : ~alu_reg_in;

//-------------------------------------------
//-- ADDER for ADD, ADDC, SUB, SUBC, INC, DEC
//-------------------------------------------
assign in_A = (binary_op || (unary_op && operation[0])) ? w_accu :
                                                          {{(REG_SIZE-1){operation[1]}}, 1'b1};
//              {operation[1], operation[1], operation[1], 1'b1};

assign in_B = (binary_op) ?                     Reg_xor    :
              ((unary_op) && (!operation[0])) ? alu_reg_in :
                                                {{(REG_SIZE-1){operation[1]}}, 1'b1};
//                  {operation[1], operation[1], operation[1], 1'b1};

assign #(2) S = in_A + in_B + Y;
  
//-------------------------------------------
//-- output process
//-------------------------------------------
always @(*)  
begin
    #(2) W  = w_accu;
    #(2) CO = carry; 

    // Binary operations
    if (binary_op) 
    begin	  
           if (operation[3])    {CO, W} = S; // ADD, SUB
      else if (operation==4'h4) W = w_accu & alu_reg_in; // AND
	  else if (operation==4'h7) W = w_accu | alu_reg_in; // OR
	  else if (operation==4'h6) W = w_accu ^ alu_reg_in; // XOR
	  else if (operation==4'h5) W = alu_reg_in; // NOP	  
	end

    // Unary Operations
    else if (unary_op) 
	begin
       // INC, DEC
            if (operation[3:2]==2'b01) {CO, W} = S;
	   	 
	   // NOT
       else if (operation==4'h0) W = Reg_xor;
       else if (operation==4'h1) W = ~w_accu;
	   
	   // RRL, RLC, SHL, SHR
       else if (operation==4'h8) {CO, W[(REG_SIZE-1):0]} = {w_accu[(REG_SIZE-1):0], carry}; // RLC
	   else if (operation==4'hA) {W[(REG_SIZE-1):0], CO} = {carry, w_accu[(REG_SIZE-1):0]}; // RRC
	   else if (operation==4'hC) {CO, W[(REG_SIZE-1):0]} = {w_accu[(REG_SIZE-1):0], 1'b0};  // SHL
	   else if (operation==4'hE) {W[(REG_SIZE-1):0], CO} = {1'b0, w_accu[(REG_SIZE-1):0]};  // SHR
	   
	   else if (operation==4'h9) {CO, W[(REG_SIZE-1):0]} = {alu_reg_in[(REG_SIZE-1):0], carry}; // RLC
	   else if (operation==4'hB) {W[(REG_SIZE-1):0], CO} = {carry, alu_reg_in[(REG_SIZE-1):0]}; // RRC
	   else if (operation==4'hD) {CO, W[(REG_SIZE-1):0]} = {alu_reg_in[(REG_SIZE-1):0], 1'b0};  // SHL
	   else if (operation==4'hF) {W[(REG_SIZE-1):0], CO} = {1'b0, alu_reg_in[(REG_SIZE-1):0]};  // SHR
	
    end // Unary Operations    

end

//-------------------------------------------
//-- synchronize outputs
//-------------------------------------------
always@(posedge clk or negedge nreset)
begin
    if (!nreset) 
        w_accu <= 'b0;
    else if ((binary_op && !(operation==4'hB)) || unary_op) 
        w_accu <= W; 
end

always@(posedge clk or negedge nreset)
begin
    if (!nreset) 
	begin
        carry <= 1'b0;
        zero  <= 1'b0;
	end
    else if (binary_op || unary_op) 
    begin    
        carry <= CO;
        zero  <= Z;      
    end
end

endmodule
