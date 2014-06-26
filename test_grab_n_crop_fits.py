#test_grab_n_crop_fits
#        3b) if no: move on
#
###########################################################################
import os  
import glob 
import datetime
import time
import shutil
import sys
import re
import subprocess
import multiprocessing as mp
import scipy
from scipy.io.idl import readsav
import scipy.ndimage as image
import sunpy
import numpy as np
import pickle
###########################################################################
bbc=[800.,50, 1160,450]
PATH_2_STACKS="/home/hwinter/programs/Flare_Detective/"
# From AIA/SDO FITS Keywords, AIA02840  Rev. M, 2/23/2011
AIA_sat_thresh=15000.
###########################################################################
def fcm_make_movie_map(map_list, directory, ev='FALSE',frames_dir='FALSE',movie_dir='FALSE',
                       frame_prefix="flare_frame",movie_name="flare_mov.mp4", normal='OFF' ):
    """
    """

    if frames_dir=='FALSE':
        frames_dir=directory
    if movie_dir=='FALSE':
        movie_dir=directory
        
    print("In fcm_make_movie_map")
    for iii, map_obj in enumerate(map_list):
        
        #print('here1')
        frame=map_obj.plot(vmin=map_obj.min(), vmax=map_obj.max(),draw_limb=False)
        #print('here2')
        ax = frame.add_subplot(111)
        #print('here3')
        if ev !='FALSE':
            ax.annotate('Flare',xy=(float(ev.EVENT.EVENT_COORD1[0]),float(ev.EVENT.EVENT_COORD2[0])),
                        xytext=(0.8, 0.8),    # fraction, fraction
                        bbox=dict(boxstyle="round", fc="0.7"),
                        textcoords='figure fraction',arrowprops=dict(facecolor='yellow'), color='Black')
        
        fname=frame_prefix+"%d.png" % iii
        #print('here3')
        #print(fname)
        file=os.path.join(frames_dir,fname)
                
        frame.savefig(file, dpi=100,  bbox_inches='tight', pad_inches=0.25)
    
  
    subprocess.call("ffmpeg -i "+os.path.join(frames_dir, frame_prefix+"%d.png")+" -r 15 "+os.path.join(movie_dir,movie_name), shell=True)   
        
###########################################################################
###########################################################################
def fcm_rm_sat_pix(map_list,threshold):
    """
    """

    
        
###########################################################################
###########################################################################
fits_path=os.path.join(PATH_2_STACKS, "Working_old","ivo:__helio-informatics.org__FL_FlareDetective-TriggerModule_20120501_014529_2012-05-01T01:25:47.070_1","fits")

file_list= glob.glob(os.path.join(fits_path, '*.fits'))
        
map_obj=sunpy.make_map(file_list[0])

out_map_list=[]

for files in file_list[0:50]:
    temp_map= sunpy.make_map(files)
    temp_map=temp_map.submap([bbc[0], bbc[2]],[bbc[1], bbc[3]])
    out_map_list.append(temp_map)



mask=abs(out_map_list[0].base.copy()*0.)
mask[out_map_list[0].shape[1]-300:out_map_list[0].shape[1]-100][out_map_list[0].shape[0]-100:out_map_list[0].shape[0]-50]=AIA_sat_thresh
mask[:][out_map_list[0].shape[0]-90:out_map_list[0].shape[0]-75]=AIA_sat_thresh

for maps in out_map_list:
    maps[:][:]+=mask
    maps[:][:]<=AIA_sat_thresh
    
fcm_make_movie_map(out_map_list, './',frames_dir='./test_frames/')


