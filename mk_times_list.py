"""
    !!Not done until you have a complete DocString!! 
"""


###########################################################################
# Import modules needed to run the code.
import os  
import glob 
import datetime
import time
import subprocess
import multiprocessing as mp
import random
###########################################################################
top_dir="/sdo/scratch/hwinter/programs/"
#top_dir="/Volumes/scratch_2/Users/hwinter/programs/"
#working_dir='/data/george/hwinter/data/Flare_Detective_Data/flare_scan/'
working_dir=os.path.join(top_dir,"Flare_Detective_Data/flare_scan/")
#PATH_2_STACKS="/data/george/hwinter/data/Flare_Detective_Data/Event_Stacks/"
PATH_2_STACKS=os.path.join(top_dir,"Flare_Detective_Data/Event_Stacks/")
###########################################################################
# Define time range and time steps
begin_time=datetime.datetime(2014, 2, 1, 00, 00, 00)
end_time=  datetime.datetime(2014, 3, 1, 00, 00, 00)
prefix='feb_'

t_current=begin_time
start_times=[]
end_times=[]
delta=datetime.timedelta(hours=1)
###########################################################################
def run_idl_jobs(filename):
    subprocess.call("ssw_batch "+filename+" "+filename+".log", shell=True )

###########################################################################

#Make a list of times based on the start, end and delta time defined above.
while t_current <= end_time :
    
    start_times.append(t_current.isoformat())
    t_current=t_current+delta
    end_times.append(t_current.isoformat())

#Make a list of start and end times in an easy to read ASCII file.
times_file=open(os.path.join(working_dir,'times.txt'),'w')

for iii, times in enumerate(start_times):
    times_file.write(start_times[iii]+'   '+end_times[iii]+' \n' )

times_file.close()

###########################################################################


idl_files=[]
for iii, times in enumerate(start_times):
#Write an sswidl file to call
    fname=os.path.join(working_dir, 'fft_fcm_step_'+prefix+str(iii)+'.pro')
    idl_files.append(fname)
    idl_file=open(fname, 'w')
    idl_file.write("start_index="+str(iii)+"ul \n")
    idl_file.write("!path=!path+':'+EXPAND_PATH('+'+'/"+working_dir+"') \n")
    idl_file.write("print, 'doing it!' \n")
    # idl_file.write("RESOLVE_ROUTINE, 'fft_fcm_event_scan', /COMPILE_FULL_FILE \n")
    
    
    idl_file.write("PATH_2_STACKS= '"+PATH_2_STACKS+"' \n")
    idl_file.write("readcol, '"+os.path.join(working_dir,'times.txt')+"', start_times, end_times, FORMAT=['A,A'], delim='   ' \n")
    idl_file.write("help, start_times, end_times \n")
    idl_file.write("print, start_times[start_index], ' ', end_times[start_index] \n")
    idl_file.write("    fft_fcm_event_scan, start_times[start_index], end_times[start_index], $ \n")
    idl_file.write("                 VERBOSE=VERBOSE, PATH_2_STACKS=PATH_2_STACKS \n")
    idl_file.write("    print, 'Completed #', string(start_index) \n")
    idl_file.write("EXIT \n")
    idl_file.write("END \n \n")
    idl_file.close()

    
###########################################################################


po=mp.Pool(10)
random.shuffle(idl_files)
for  filename in idl_files:
    print(filename)
    po.apply_async(run_idl_jobs,(filename,))
    time.sleep(30)
    
po.close()
po.join()
###########################################################################
