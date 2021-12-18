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
// 4 bits RISC architecture
// 12 bits ISA (instruction set architecture)
// 12 bits program address
// 16x4 bits registers
// 256x8 bits external user-EEPROM
// 256x4 bits external RAM
// Some test bits
//
///////////////////////////////////////////////////////////////////////////////
//
// Design Notes :  
//
///////////////////////////////////////////////////////////////////////////////
*/
`timescale 1ns / 1ps

module risc4b (
      nreset      ,
      clk         ,
      tm_inc_pc   ,
      tm_en       ,
      prog_addr   ,
      prog_data   ,
   
      rxd         ,
      txd         ,
   
      ee_ctrl     ,
      ee_wdata    ,
      ee_rdata    ,
      ee_addr     ,
   
      test        ,
   
      ram_addr    ,
      ram_rdata   ,
      ram_wdata   ,
      ram_we   
);

input          nreset      ;
input          clk         ;
input          tm_inc_pc   ; // testmode increment PC
input          tm_en       ; // testmode enable
output [11:0]  prog_addr   ; // ==PC (program counter)
input  [11:0]  prog_data   ; // ==IR (instruction register)

input  [3:0]   rxd         ; // Data RxD / Start RxD / DV RxD / ACK TxD
output [3:0]   txd         ; // Data TxD / Start TxD / DV TxD / ACK RxD

output [3:0]   ee_ctrl     ;
output [7:0]   ee_wdata    ;
input  [7:0]   ee_rdata    ;
output [7:0]   ee_addr     ;

output [3:0]   test        ;

output [7:0]   ram_addr    ;
input  [3:0]   ram_rdata   ;
output [3:0]   ram_wdata   ;
output reg     ram_we   ;


localparam CC_NC     = 3'b000;
localparam CC_EQ_ZS  = 3'b111;
localparam CC_NE_ZC  = 3'b011;
localparam CC_GE_CS  = 3'b001;
localparam CC_GT     = 3'b010;
localparam CC_LE     = 3'b110;
localparam CC_LT_CC  = 3'b101;

wire [3:0] REG_BANK_DATA  ;
wire [3:0] REG_W          ;
wire [3:0] ALU_REG_IN     ;
wire REG_ZERO;
wire REG_CARRY;
reg  [3:0] REG_BANK [0:15];

// Program Conter
reg  [11:0] PC;
wire [11:0] PC_1; assign #(2) PC_1 = PC + 1;

// Instruction Pointer
wire [11:0] IP; assign IP = {REG_BANK[5],REG_BANK[4],REG_BANK[3]};

// Instruction Register
wire [11:0] IR; assign IR = prog_data;


alu ALU_I0(
          .nreset      (nreset    ), // 
          .clk         (clk       ), // 
 
          .opcode      (IR[11:8]  ), // 
          .operation   (IR[7:4]   ), // 

          .alu_reg_in  (ALU_REG_IN), // 

          .w_accu      (REG_W     ), //  
          .zero        (REG_ZERO  ), // 
          .carry       (REG_CARRY )  // 
);

// SERIAL DATA INTERFACE
assign txd            = REG_BANK[13];  // Data TxD / Start TxD / DV TxD / ACK RxD

// EEPROM INTERFACE
assign ee_addr[3:0]   = REG_BANK[6]; 
assign ee_addr[7:4]   = REG_BANK[7]; 
assign ee_wdata[3:0]  = REG_BANK[8];
assign ee_wdata[7:4]  = REG_BANK[9];
assign ee_ctrl        = REG_BANK[10];

// TEST bus
assign test           = REG_BANK[15]; //test bus register

// ALU_REG_IN
assign ALU_REG_IN     = (IR[11:8]==4'b1000 || IR[11:8]==4'b1010) ? REG_BANK_DATA : IR[3:0];

// RAM
assign ram_addr[7:4] = REG_BANK[7];
assign ram_addr[3:0] = REG_BANK[6];
assign ram_wdata     = REG_BANK[IR[3:0]];
  
assign REG_BANK_DATA = REG_BANK[IR[3:0]];

assign prog_addr = PC;


// RAM Write Enable
always @(posedge clk or negedge nreset)
begin
    if (!nreset) ram_we <= 1'b0;
    else if (!tm_en && (IR[11:4]==8'hF0)) ram_we <= 1'b1; // STO
    else ram_we <= 1'b0;
end

//  SEQUENCER
always @(posedge clk or negedge nreset)
begin
    if (!nreset)
    begin
      PC <= 'b0;
      REG_BANK[0]  <= 4'b0;
      REG_BANK[1]  <= 4'b0;
      REG_BANK[2]  <= 4'b0;
      REG_BANK[3]  <= 4'b0;
      REG_BANK[4]  <= 4'b0;
      REG_BANK[5]  <= 4'b0;
      REG_BANK[6]  <= 4'b0;
      REG_BANK[7]  <= 4'b0;
      REG_BANK[8]  <= 4'b0;
      REG_BANK[9]  <= 4'b0;
      REG_BANK[10] <= 4'b0;
      REG_BANK[11] <= 4'b0;
      REG_BANK[12] <= 4'b0;
      REG_BANK[13] <= 4'b0;
      REG_BANK[14] <= 4'b0;
      REG_BANK[15] <= 4'b0;
    end

    else if (tm_en)
        if (tm_inc_pc)
          PC <= PC_1;
        else
          PC <= PC;
        		
    else 
    begin
        REG_BANK[12] <= rxd;
		
        if (REG_BANK[10][1]) // if EERD=1
        begin
           REG_BANK[8] <= ee_rdata[3:0];
           REG_BANK[9] <= ee_rdata[7:4];
        end
		
        // JMPC cc:3 addr:8
        if (!IR[11])
        begin  
            if (IR[10:8]==CC_NC )
              PC[7:0] <= IR[7:0];

            else if (IR[10:8]==CC_GE_CS )
              if (REG_CARRY) 
                PC[7:0] <= IR[7:0];
              else
                PC <= PC_1;
              
            else if (IR[10:8]==CC_GT )
              if (REG_CARRY && !REG_ZERO) 
                PC[7:0] <= IR[7:0];
              else
                PC <= PC_1;
              
            else if (IR[10:8]==CC_NE_ZC )
              if (!REG_ZERO) 
                PC[7:0] <= IR[7:0];
              else
                PC <= PC_1;
              
            else if (IR[10:8]==CC_LT_CC )
              if (!REG_CARRY)
                PC[7:0] <= IR[7:0];
              else
                PC <= PC_1;
              
            else if (IR[10:8]==CC_LE )
              if (!REG_CARRY || REG_ZERO) 
                PC[7:0] <= IR[7:0];
              else
                PC <= PC_1;
              
            else if (IR[10:8]==CC_EQ_ZS )
              if (REG_ZERO)
                PC[7:0] <= IR[7:0];
              else
                PC <= PC_1;
        end      			              

        // ALU binary alu:4 reg:4
        else if (IR[11:8] == 4'h8 )
          PC <= PC_1;

        // ALU binary imediat alu:4 im:4
        else if (IR[11:8] == 4'h9 )
          PC <= PC_1;

        // ALU unary alu:3 selrw:1 reg:4
        else if (IR[11:8] == 4'hA )
          PC <= PC_1;

        // ALU unary imediat alu:3 selrw:1 im:4
        else if (IR[11:8] == 4'hB )
          PC <= PC_1;

        // CALL addr:8
        else if (IR[11:8] == 4'hC )
		    begin
          $display("[%0t] CALL", $time);
          REG_BANK[5] <= PC_1[11:8];
          REG_BANK[4] <= PC_1[7:4];
          REG_BANK[3] <= PC_1[3:0];
          PC[7:0] <= IR[7:0];
		    end

        // MOVI reg:4 im:4
        else if (IR[11:8] == 4'hD )
		    begin
          $display("[%0t] MOVI", $time);
          REG_BANK[IR[7:4]] <= IR[3:0];
          PC <= PC_1;
		    end

        // STO reg:4
        else if (IR[11:4] == 8'hF0 )
        begin
          $display("[%0t] STO", $time);
          PC <= PC_1;
        end

        // LOAD reg:4
        else if (IR[11:4] == 8'hF1 )
		    begin
          $display("[%0t] LOAD", $time);
          REG_BANK[IR[3:0]] <= ram_rdata;
          PC <= PC_1;
		    end

        // MOVW reg:4
        else if (IR[11:4] == 8'hF2 )
		    begin
          $display("[%0t] MOVW", $time);
          REG_BANK[IR[3:0]] <= REG_W;
          PC <= PC_1;
		    end

        // JMPIC cc:3
        else if (IR[11:3] == 9'b1111_1111_0 )
        begin          
          $display("[%0t] JMPIC", $time);
            if (IR[2:0]==CC_NC )
			          PC <= IP;

            else if (IR[2:0]==CC_GE_CS )
              if (REG_CARRY) 
			           PC <= IP;
              else
                PC <= PC_1;
              
            else if (IR[2:0]==CC_GT )
              if (REG_CARRY && !REG_ZERO) 
  			        PC <= IP;
              else
                PC <= PC_1;
              
            else if (IR[2:0]==CC_NE_ZC )
              if (!REG_ZERO) 
  			        PC <= IP;
              else
                PC <= PC_1;
              
            else if (IR[2:0]==CC_LT_CC )
              if (!REG_CARRY)
  			        PC <= IP;
              else
                PC <= PC_1;
              
            else if (IR[2:0]==CC_LE )
              if (!REG_CARRY || REG_ZERO) 
  			        PC <= IP;
              else
                PC <= PC_1;
              
            else if (IR[2:0]==CC_EQ_ZS )
              if (REG_ZERO)
  			        PC <= IP;
              else
                PC <= PC_1;
        end

        // CALLI
        else if (IR[11:0] == 12'hFFE )
		    begin
          $display("[%0t] CALLI", $time);
	        PC <= IP;
          REG_BANK[5] <=  PC_1[11:8];
          REG_BANK[4] <=  PC_1[7:4];
          REG_BANK[3] <=  PC_1[3:0];
		    end

        // NOP
        else if (IR[11:0] == 12'hFFF )
        begin
          $display("[%0t] NOP", $time);
          PC <= PC_1;
        end
		          
	  end // tm_en
    
end // SEQUENCER;

endmodule