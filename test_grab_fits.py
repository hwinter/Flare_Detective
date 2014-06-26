

###########################################################################
import os  
import glob 
import datetime
import time
import shutil
import sys
import re
import multiprocessing as mp
import scipy
from scipy.io.idl import readsav
        
###########################################################################                
###########################################################################
#System dependent global variables
#Define the path to the stacks
PATH_2_STACKS="/home/hwinter/programs/Flare_Detective/Event_Stacks/"

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
def grab_fits(ev):
    """
    !!Not done until you have a complete DocString!! 
    """
    
    print('in grab_fits!')
    #Define Global Variables
    global PATH_2_Working
    global aia_top_dir
    t_start=ev.event.EVENT_STARTTIME[0]
    t_end=ev.event.EVENT_ENDTIME[0]

    Year_folders=
    month_folders=
    day_folders=

    

   

    return 1
    #Gather the data for the program
    



    
    #test=check_mv(filename, PATH_2_Processing, PATH_2_Completed)
        

###########################################################################
###########################################################################
