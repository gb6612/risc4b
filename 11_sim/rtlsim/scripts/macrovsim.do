log -r /*

onbreak {resume}

###run 20000 ns
###
### check contention config -file ./log/contention/sim0_contention_${2}_${1}.log  -time 50000
### check contention add -r -ports /*
###
### 5ns
### check float config -file ./log/float/sim0_float_${2}_${1}.log  -time 5000000
### check float add -r -ports /*
### check float off /top/CHIP_I0/PADRING/PAD_SDO/padio_PAD_SDO/din
###
###
### coverage exclude -togglenode SYNOPSYS_UNCONNECTED* -scope /top/CHIP_I0/CORE_I0 -r
### coverage save -onexit ./log/cover/${2}_${1}.ucdb
###
### 
### turn off the X reporting and propagation on the following ports
###
### tcheck_set     /top/CHIP_I0/CORE_I0/udtp_sink_tdgo_reg     "(SETUP)" OFF 
### tcheck_status  /top/CHIP_I0/CORE_I0/udtp_sink_tdgo_reg    
###
###
### Power report
### 
### power add -r /top/CHIP_I0/CORE_I0/*

#
run -all

#power report -all -noheader -file ./log/power/sim0_${2}_${1}_power.log 
#power report -all -bsaif ./log/power/sim0_${2}_${1}_power.saif

quit
