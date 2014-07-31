"""
    !!Not done until you have a complete DocString!! 
"""
#move_ivo_saves.py
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
import shutil
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
ivo_save_files =glob.glob(os.path.join(PATH_2_Processing, '*.sav'))
counter_number=0
paths_file = open("good_paths.txt", 'w')
for file in ivo_save_files: 
	#Get the basename of the file	
	ivo_basename=os.path.splitext(os.path.basename(file))[0]
	#print(ivo_basename)
	#print(file)
	#Make a working directory path based on the basename
	ivo_working_dir=os.path.join(PATH_2_Working,ivo_basename)
	#Make an empty list to store the name of the paths that actually exist
	good_paths=[]
	#If the path exists do the following
	if os.path.exists(ivo_working_dir):
		#Copy the ivo file to the working directory
		shutil.copy(file, ivo_working_dir)
		#print("PING!!!")
		#Get the name of the new ivo event save file path 
		#print(ivo_working_dir)
		new_ivo_save_path=glob.glob(os.path.join(ivo_working_dir, '*.sav'))
		Num_fits_files=len(glob.glob(os.path.join(\
			os.path.join(ivo_working_dir, 'fits'), \
			'*.fits')))
		if Num_fits_files >0:
			print(Num_fits_files)		
			paths_file.write("%s\n" % ivo_basename)
			good_paths.append(new_ivo_save_path)
			counter_number=counter_number+1
		#print(new_ivo_save_path)
		#if os.path.exists(good_path):
			#good_paths.append(good_path)
			#print("PING!!!", good_path)

paths_file.close()	
print('')
print('')
print(counter_number)	
#len(good_paths)
#Make a text file to save all of the good paths.
#paths_file = open("good_paths.txt", 'w')
#for path in good_paths:
#	paths_file.write(path, '/n')
#	
#paths_file.close()

###########################################################################

