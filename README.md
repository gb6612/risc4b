# risc4b - 4 bits RISC architecture CPU core

<p>
This CPU core uses a custom ISA (Instruction Set Architecture). 
<br>It is perfect for teaching activities and/or in ASIC requiring some simple data conditioning.
<br>As a reference, historically this CPU was implemented (several years ago) in smartcard applications.  

## Characteristics:
True(!) atomic 1 clock cycle per instruction  
4 bits datapath, 16 x 4 bits registers   
12 bits instruction length   
4k x 12 bits program memory   
Addressable 256 x 4 bits RAM data memory   
Addressable 256 x 8 bits EEPROM   
4 wires test block    

Included qFlow for RTL to GDS implementation   
340x370um area, using OSU018 technology PDK. Note that OSU018 has a very limited number of std cells (<20). By using a more complete PDK (100+ std cells), this area is further reduced.   

Registers can in general be used as General Purpose. No particular EEPROM or serial interface controller is implemented (control was directly done via firmware).   
Only IP registers should be left for subroutine calls.  

Please refer to the *pdf file for the list of instructions.  

The assembler/linker is the original > *exe files. Unfortunately no time yet to develop a "gcc"-like or more user friendly solution...  


