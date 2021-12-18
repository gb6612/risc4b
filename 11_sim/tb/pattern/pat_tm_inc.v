// check tm_en and tm_inc_pc

mylog("*********************************");
mylog("Starting pattern ");
myinit;

tm_inc_pc = 1'b1;
tm_en = 1'b1;


// check PC is incrementing when tm_inc_pc=1
for (i=1; i<4097; i=i+1)
begin
    #(`Tcycle *1); check_error16("prog_addr", {4'b0, CHIP_I0.prog_addr}, i[11:0]);
end


// check PC is stopped when tm_inc_pc=0
#(`Tcycle *1); tm_inc_pc = 1'b0;
for (i=1; i<16; i=i+1)
begin
    #(`Tcycle *1); check_error16("prog_addr", {4'b0, CHIP_I0.prog_addr}, 12'h001);
end



#(`Tcycle *500);
mylog("End");
