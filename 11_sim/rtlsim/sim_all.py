#!python

import sys
import shutil
import os
import time

def cls():
    os.system('cls' if os.name=='nt' else 'clear')

cls()

if os.path.exists("run_all.done"):
  os.remove("run_all.done")



# ***********************
# List all simulations
simlist=[]
simlist.append('pat_nop')
simlist.append('pat_tm_inc')
simlist.append('pat_loop')
simlist.append('pat_meadarm')
#simlist.append('sim5')

# ***********************

for i in simlist:
      print('************************************** ===')
      print('***** Starting Sim ', i)
      print('************************************** ===')
      code_filename = './../tb/pattern/'+i+'.hex'
      if (not os.path.exists(code_filename)):
         code_filename = './../tb/pattern/pat_nop.hex'

      shutil.copyfile(code_filename, './prog.hex') 
      print('Firmware used: '+ code_filename)

      logfile = "./log/compiled_"+i+".log"
      os.system("python ./scripts/vlog0.py "+i+" > "+logfile)
      os.system("python ./scripts/vsim0.py "+ i)
      time.sleep(3)

   
print('****************************************')
print('*****    END OF BATCH              *****')
print('****************************************')

with open('run_all.done', 'w') as f:
    pass
