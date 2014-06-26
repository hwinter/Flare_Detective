
import os  
import glob 
import datetime
import time
import subprocess
import multiprocessing as mp

working_dir='/home/hwinter/programs/Flare_Detective/flare_scan'
begin_time=datetime.datetime(2012, 01, 05, 01, 28, 34)
end_time=  datetime.datetime(2012, 05, 30, 01, 28, 34)

def run_idl_jobs(filename):
    subprocess.call("ssw_batch "+filename+" "+filename+".log", shell=True )


t_current=begin_time
start_times=[]
end_times=[]
delta=datetime.timedelta(days=1)

while t_current <= end_time :
    
    start_times.append(t_current.isoformat())
    t_current=t_current+delta
    end_times.append(t_current.isoformat())

times_file=open('times.txt','w')
for iii, times in enumerate(start_times):
    times_file.write(start_times[iii]+'   '+end_times[iii]+' \n' )

times_file.close()



idl_files=[]
for iii, times in enumerate(start_times):
#Write an sswidl file to call
    fname=os.path.join(working_dir, 'fft_fcm_step_'+str(iii)+'.pro')
    idl_files.append(fname)
    idl_file=open(fname, 'w')
    idl_file.write("start_index="+str(iii)+"ul \n")
    idl_file.write("!path=!path+':'+EXPAND_PATH('+'+'/home/hwinter/programs/Flare_Detective/flare_scan') \n")
    idl_file.write("print, 'doing it!' \n")
    # idl_file.write("RESOLVE_ROUTINE, 'fft_fcm_event_scan', /COMPILE_FULL_FILE \n")
    
    
    idl_file.write("PATH_2_STACKS= '/home/hwinter/programs/Flare_Detective/Event_Stacks/' \n")
    idl_file.write("readcol, '/home/hwinter/programs/Flare_Detective/times.txt', start_times, end_times, FORMAT=['A,A'], delim='   ' \n")
    idl_file.write("help, start_times, end_times \n")
    idl_file.write("print, start_times[start_index], ' ', end_times[start_index] \n")
    idl_file.write("    fft_fcm_event_scan, start_times[start_index], end_times[start_index], $ \n")
    idl_file.write("                 VERBOSE=VERBOSE, PATH_2_STACKS=PATH_2_STACKS \n")
    idl_file.write("    print, 'Completed #', string(start_index) \n")
    idl_file.write("EXIT \n")
    idl_file.write("END \n \n")
    idl_file.close()

    


po=mp.Pool()

for  filename in idl_files:
    print(filename)
    po.apply_async(run_idl_jobs,(filename,))
    time.sleep(30)
    
po.close()
po.join()
