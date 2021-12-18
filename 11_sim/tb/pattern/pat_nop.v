// just clock with a NOP hex file

mylog("*********************************");
mylog("Starting pattern ");
myinit;

// check PC is incrementing (NOP)
for (i=41; i<4200; i=i+1)
begin
    #(`Tcycle *1); check_error16("prog_addr", {4'b0, CHIP_I0.prog_addr}, i[11:0]);
end


#(`Tcycle *500);
mylog("End");
