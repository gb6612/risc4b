#!python

import sys
import os
import datetime

# Arguments to pass are
# sim0 <simname> <max/min>
#   <simname> is the simulation name
#   <max/min> is the sdf we will use

if len(sys.argv) > 1:
    param1 = sys.argv[1]
else:
    param1 = 'dummy'

if len(sys.argv) > 2:
    param2 = sys.argv[2]
else:
    param2 = 'typ'

simstarttime = datetime.datetime.now()

print( "running "+ param1 + " at " + param2)

wlf_out = "./wlf/sim_" + param1 + ".wlf"
vcd_out = "./wlf/sim_" + param1 + ".vcd"
log_out = "./log/sim_" + param1 + ".log"
#print(wlf_out)
#print(log_out)

macro_ = ' -do \"do ./scripts/macrovsim.do ' + param1 + '\"'
#print(macro_)


os.system("vsim -f ./scripts/vsim.file +test=" + param1 + " -wlf " + wlf_out + " -l " + log_out + " " + macro_ + " work.top")


print('convert wlf to vcd')
# wlf2vcd <wlffile> [-help] [-o <outfile>] [-quiet]   
os.system("wlf2vcd " + wlf_out + " -o " + vcd_out )
  
# For simulations "bursts"(many sims), prefer using "vsim" command, and start all in parallel !
# Uncomment the loop below if you want to start one simulation after another.
#while (! -f .done )
#    sleep 10
#end
#    sleep 2


	
simstoptime = datetime.datetime.now()

print( "********************************")
print( "=== Job started  at " + str(simstarttime))
print( "=== Job finished at " + str(simstoptime))
print( "********************************")
 
