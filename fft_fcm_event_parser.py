"""
    !!Not done until you have a complete DocString!! 
"""

###########################################################################
#Import the Flare Characterization Module
import fft_fcm as fcm
#Import all of the modules necessary to run the code.
import os  
import glob 
import datetime
import time
import sys
import multiprocessing as mp
###########################################################################
              
###########################################################################
#System dependent global variables
#Define the path to the stacks
#PATH_2_STACKS="/data/george/hwinter/data/Flare_Detective_Data/Event_Stacks/"
PATH_2_STACKS="/Volumes/scratch_2/Users/hwinter/programs/Flare_Detective_Data/Event_Stacks/"
#Define the path to each stack
PATH_2_Pending=os.path.join(PATH_2_STACKS,'Pending')
PATH_2_Processing=os.path.join(PATH_2_STACKS,'Processing')
PATH_2_Completed=os.path.join(PATH_2_STACKS,'Completed')
PATH_2_Working=os.path.join(PATH_2_STACKS,'Working')
PATH_2_IDLpros=os.path.join(PATH_2_STACKS,'flare_scan')
#Define path to the top level AIA level1 data directory
aia_top_dir="/data/SDO/AIA/level1/"


###########################################################################
#Check Stacks Path 
print(PATH_2_STACKS)
print(PATH_2_Pending)
#Check to see if paths exist
test=os.path.exists(PATH_2_Pending)
#If test is false leave some form of error message and quit.
test=os.path.exists(PATH_2_Processing)
#If test is false leave some form of error message and quit.
test=os.path.exists(PATH_2_Completed)
#If test is false leave some form of error message and quit.

#This one is a little different since sometimes (regularly) the /data/SDO directory becomes unmounted.
test=os.listdir(aia_top_dir)
#If test is false leave some form of error message and quit.

###########################################################################
#Check to see if a process has the Pending stack locked.

old_lockfiles= glob.glob(os.path.join(PATH_2_Pending, '*.lockfile'))
if old_lockfiles.__len__() < 1 :
    print("No Lockfiles")
else:    
    print("Lockfiles in Place!")
    
    # Test for age.  If the lockfiles are > some age then send and error report and start over
    #!!!
    
    sys.exit('Current Lockfile in Place. Exiting.')
    
#Put a lockfile in the pending stack
current_lockfile=datetime.datetime.now()
current_lockfile=current_lockfile.isoformat()+'.lockfile'
lf=open(os.path.join(PATH_2_Pending,current_lockfile), 'w')

###########################################################################
#Make a list of files in the Pending stack
event_files= glob.glob(os.path.join(PATH_2_Pending, '*.sav'))
if len(event_files) < 1 :
    #close the Lockfile
    lf.close()
    #Delete the lockfile
    print("Removing Lockfile: "+os.path.join(PATH_2_Pending,current_lockfile))
    os.remove(os.path.join(PATH_2_Pending,current_lockfile))
    sys.exit('No Pending files. Exiting.')
    
print("Number of files= "+str(event_files.__len__()))
processing_files=[]
for infile in event_files:
    print "current file is: " + infile
    filename=os.path.basename(infile)
    #Now determine if the data exists in the archive. Assume that the event is not > 1 day in length.
    #Look for data a day before, the day during, and the day after the event.
    #Grab date of event from name of ivo save file.
    event_date=fcm.extract_YYYYMMDD(filename)
    one_day = datetime.timedelta(days=1)
    dayb4=event_date-one_day
    dayafter=event_date+one_day
    #Construct a path to the data files:before, during and after
    path2data_dayb4=fcm.get_aia_data_path(dayb4)
    path2data_dayof=fcm.get_aia_data_path(event_date)
    path2data_dayafter=fcm.get_aia_data_path(dayafter)
    print(path2data_dayb4)
    print(path2data_dayof)
    print(path2data_dayafter)
    
    if (os.path.exists(path2data_dayb4) ) and (os.path.exists(path2data_dayof) ) \
        and (os.path.exists(path2data_dayafter) ):
        
        #Move the file to the Processing Stack
       
        test=fcm.check_mv(filename, PATH_2_Pending, PATH_2_Processing)
        if test :
        #Now add to list of files to process
            processing_files.append(filename)

###########################################################################
#close the Lockfile
lf.close()
#Delete the lockfile
print("Removing Lockfile: "+os.path.join(PATH_2_Pending,current_lockfile))
os.remove(os.path.join(PATH_2_Pending,current_lockfile))
###########################################################################
if not processing_files :
     sys.exit('No files to process. Exiting.')
#This section sends farms out files in the processing list to subprocesses
po=mp.Pool(5)

for  filename in processing_files:
    print(filename)
    po.apply_async(fcm.call_character_mod,(filename,))

po.close()
po.join()
