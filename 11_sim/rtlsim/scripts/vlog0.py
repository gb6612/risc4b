#!python

import sys
import os

if len(sys.argv) > 1:
    param1 = sys.argv[1]
else:
    param1 = 'dummy'


def cls():
    os.system('cls' if os.name=='nt' else 'clear')
cls()

os.system("vdel -lib work -all -verbose")
os.system("vlib work")

# Enter HERE all design to be compiled

#vlog_cmd = "vlog -sv +incdir+./hdl -lint=full +cover -reportprogress 300 -work work "
vlog_cmd = "vlog -f ./scripts/vlog.file -work work "

#================================================
print( "compiling modules")
#================================================
file_list = "./../../10_rtl/alu.v "+ \
            "./../../10_rtl/risc4b.v "

os.system(vlog_cmd + file_list)

#================================================
print( "compiling macros models")
#================================================
file_list = "./../../09_models/eeprom.v "+ \
            "./../../09_models/rom.v "+ \
            "./../../09_models/sram_v2.v "+ \
            "./../../09_models/chip.v "

os.system(vlog_cmd + file_list)


#================================================
print( "compiling top&DUT ")
#================================================
#os.system("vlog -sv -reportprogress 300 -work work " + "./../tb/dut1.v")
os.system("vlog -sv -reportprogress 300 +define+"+param1+" -work work " + "./../tb/tb_top.v")

##================================================
#print( "run vopt ")
##================================================
#vopt top -o top_opt_max -f scripts/vopt_maxdly.file
#vopt top -o top_opt_min -f scripts/vopt_mindly.file

print( "*************************************************************")
print( "library work purged and recompiled")
print( "*************************************************************")
#input("Press Enter to continue...")

