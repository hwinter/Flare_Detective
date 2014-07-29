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

###########################################################################
# Make a list of IVO save files 


# Make a list of working folder names 


# Make Compare IVO save file names to working folder names

# If there is a match, copy the IVO save file to the working folder


###########################################################################

