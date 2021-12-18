// using the loop.hex for a simple loop

mylog("*********************************");
mylog("Starting pattern ");
myinit;



#(`Tcycle *1); check_error16("prog_addr", {4'b0, CHIP_I0.prog_addr}, 12'h001);
#(`Tcycle *1); check_error16("prog_addr", {4'b0, CHIP_I0.prog_addr}, 12'h002);
#(`Tcycle *1); check_error16("prog_addr", {4'b0, CHIP_I0.prog_addr}, 12'h003);
#(`Tcycle *1); check_error16("prog_addr", {4'b0, CHIP_I0.prog_addr}, 12'h000);



#(`Tcycle *500);
mylog("End");
