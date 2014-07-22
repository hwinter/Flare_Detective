

###########################################################################
# Import modules needed to run the code.
import os  
import glob 
import datetime
#import time
#import subprocess
#import multiprocessing as mp
###########################################################################

import fft_fcm as fcm
        
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

###########################################################################
#Get flare ev file
#Make a list of files in the Pending stack
event_files= glob.glob(os.path.join(PATH_2_Pending, '*.sav'))
infile=event_files[0]
filename=os.path.basename(infile)
#Path to metadata file
md_file=os.path.join('./', 'meta_data.txt')
#print Metadata file

#END

