"""
    !!Not done until you have a complete DocString!! 
"""


#
#
#        1) lock the Pending stack
#        2) Check to see if the necessary data is available
#        3a) if yes:
#           Move the event files to the Processing stack
#           Call instances of the charactarization routine to process
#            the files
#        3b) if no: move on
#
###########################################################################
#Import all of the modules necessary to run the code.
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
import sunpy.map
import numpy as np
import pickle
        
###########################################################################                
###########################################################################
#System dependent global variables
#Define the path to the stacks
PATH_2_STACKS="/Volumes/scratch_2/Users/hwinter/programs/Flare_Detective_Data/Event_Stacks/"

#Define the path to each stack
PATH_2_Pending=os.path.join(PATH_2_STACKS,'Pending')
PATH_2_Processing=os.path.join(PATH_2_STACKS,'Processing')
PATH_2_Completed=os.path.join(PATH_2_STACKS,'Completed')
PATH_2_Working=os.path.join(PATH_2_STACKS,'Working')
PATH_2_IDLpros=os.path.join(PATH_2_STACKS,'flare_scan')
#Define path to the top level AIA level1 data directory
aia_top_dir="/data/SDO/AIA/level1/"

#Define the threshold for a flare
###########################################################################
###########################################################################
def make_flare_lightcurve(map):


    return lightcurve
###########################################################################
###########################################################################
def make_meta_data_file(ev, working_dir):
    """
    !!Not done until you have a complete DocString!! 
    """
	success=0
	
	text_file = open(os.path.join(working_dir,"meta_data.txt"), "w")
	
	text_file.write("Ivorn File ",)
	text_file.write("Channel: ", str(ev.event.OBS_CHANNELID[0]))
	text_file.write("Start Time: ", \
		datetime.datetime.strptime(ev.event.EVENT_STARTTIME[0],"%Y-%m-%dT%H:%M:%S"))
	text_file.write("Start Time: ", \
		datetime.datetime.strptime(ev.event.EVENT_ENDTIME[0],"%Y-%m-%dT%H:%M:%S"))
    text_file.write("X Center: ", \
    	ev.event.EVENT_COORD1[0])
    text_file.write("Y Center: ", \
    	ev.event.EVENT_COORD2[0]) 
    
    text_file.close()
	success=1

    return success
###########################################################################
###########################################################################
def extract_YYYYMMDD(filename):
    """
    go through the filename and extract the first valid YYYYMMDD as a datetime
    object
    
    Parameters
    ==========
    filename : str
        filename to parse for a YYYYMMDD format
    
    Returns
    =======
    out : (None, datetime.datetime)
        the datetime found in the filename or None
        Written by B.A. Larsen, Ph.D. and generously donated to HDW III, Ph.D., D.A.
    """
    try:
        dt = datetime.datetime.strptime(re.search("[12][09][0-9][0-9][01][0-9][0-3][0-9]", filename).group(), "%Y%m%d")
    except (ValueError, AttributeError): # there is not one
        return None
    if dt < datetime.datetime(1957, 10, 4, 19, 28, 34): # Sputnik 1 launch datetime
        dt = None
    # better not still be using this... present to help with random numbers combinations
    elif dt > datetime.datetime(2050, 1, 1):
        dt = None
    return dt    
###########################################################################
###########################################################################
def make_working_paths(PATH_2_Working):
    """
    Make all of the working paths needed to get the job done.
    !!Not done until you have a complete DocString!! 
    """
    
    #Make a working directory to put the working fits files in.    
    working_dir=os.path.join(PATH_2_Working, os.path.splitext(filename)[0])
    if not os.path.exists(working_dir):
        os.mkdir(working_dir)
    fits_dir=os.path.join(working_dir, 'fits')
    if not os.path.exists(fits_dir):
        os.mkdir(fits_dir)
    #Make a directory to put the working image frames in.   
    frames_dir=os.path.join(working_dir, 'frames')
    if not os.path.exists(frames_dir):
        os.mkdir(frames_dir)
    #Make a directory to put the working movie files in.     
    movie_dir=os.path.join(working_dir, 'movie')
    if not os.path.exists(movie_dir):
        os.mkdir(movie_dir)
        
    return(working_dir,fits_dir, frames_dir, movie_dir )    
###########################################################################
###########################################################################
def get_flare_location(map_list):
    """
    """
    print("in get_flare_location")
    xy=[]
    for maps in map_list:
        dx=abs(maps.xrange[0]-maps.xrange[1])/maps.shape[0]
        dy=abs(maps.yrange[0]-maps.yrange[1])/maps.shape[1]
        pix_xy=image.center_of_mass(maps.base)
        xy.append([maps.xrange[0]+pix_xy[0]*dx,
                   maps.yrange[0]+pix_xy[1]*dy])

    return np.median(xy, axis=0)
###########################################################################
###########################################################################
def get_aia_fits_path(ev):
    """
    Make a list of all of the AIA fits files between start_time and end_time
    of a given wavelength.
    
    Parameters
    ==========
    start_time : str
        ISO formatted string of the start time
    end_time : str
        ISO formatted string of the end time
    wvl : str
        Wavelength of interest

    
    Returns
    =======
    out : (None, list)
        full path of AIA fits file in the 
    """


    #Define Global Variables
    global PATH_2_Working
    global aia_top_dir
    t_start=datetime.datetime.strptime(ev.event.EVENT_STARTTIME[0],"%Y-%m-%dT%H:%M:%S")
    t_end=  datetime.datetime.strptime(ev.event.EVENT_ENDTIME[0],"%Y-%m-%dT%H:%M:%S")
    
    

    #Huh.  This actually creates a copy.  I thought it would make a pointer reference.
    t_current=t_start
    one_hour=datetime.timedelta(hours=1)
    file_list=[]
    #!!!!  This needs to be rewritten more elegantly, but let's
    #get a working loop version out the door first
    while t_current <= t_end :
        path2data=get_aia_data_path(t_current)
        file_list.extend(glob.glob(os.path.join(path2data,\
                                                'AIA*'+str(ev.event.OBS_CHANNELID[0]).zfill(4)+'.fits')))
        t_current=t_current+one_hour


    pattern1="[12][09][0-9][0-9][01][0-9][0-3][0-9]"
    pattern2="_[0-9][0-9][0-9][0-9][0-9][0-9]_"
    pattern3="%Y%m%d%H%M%S"
    for files in file_list :

        dt=datetime.datetime.strptime(\
                                      re.search(pattern1,files).group() \
                                      +re.search(pattern2, files).group().replace('_',''),pattern3)
        

        if dt <  t_start  or dt >  t_end:
            file_list.remove(files)

    print(len(file_list))    
    return file_list
    #Gather the data for the program
    #test=check_mv(filename, PATH_2_Processing, PATH_2_Completed)
        

###########################################################################
###########################################################################
def get_aia_data_path(dt):
    """
    Get the path to the AIA folder you need based on a datetime object, dt
    
    Parameters
    ==========
    dt : datetime object reference.
    !!! REMEMBER.  THIS IS PYTHON!!! Do not alter dt! Passed via reference.
    ds=dt makes ds a pointer to dt!

    !!Not done until you have a complete DocString!! 
    """
    
    #Define Global Variables
    global aia_top_dir
    
    path2data=os.path.join(aia_top_dir,str(dt.year), 
                           str(dt.month).zfill(2),str(dt.day).zfill(2),
                           ('H'+str(dt.hour).zfill(2)+'00'))

    return path2data
    #Gather the data for the program
    



    
    #test=check_mv(filename, PATH_2_Processing, PATH_2_Completed)
        
###########################################################################
###########################################################################
def get_event_bounding_box(ev):
    """
    extract the coordinates, in arcseconds from the event file.
    
    Parameters:
    ==========
    ev: event object

    Output:
    ==========
    bbc: Bounding box coordinates [x1, y1, x2, y2]
    """
    bbc=[float(ev.event.BOUNDBOX_C1LL[0]),float(ev.event.BOUNDBOX_C2LL[0] ),
         float(ev.event.BOUNDBOX_C1UR[0]),float(ev.event.BOUNDBOX_C2UR[0] )]
         #print('bbc: ', bbc)
    return bbc
###########################################################################
###########################################################################
def get_cropped_map(ev, file_list):
    """
    
    
    Parameters:
    ==========
    ev: event object
    file_list: List of fits files to restore

    Output:
    ==========
    out_map_list: A list of map objects containing cropped images based of the
             event bounding box.
    """
  
    #Get the coordinates of the bounding box in arcsec
    bbc= get_event_bounding_box(ev)
    out_map_list=[]
    for files in file_list:
    	#Changed after Sunpy V0.5.0
        #temp_map= sunpy.make_map(files)
        temp_map=sunpy.map.Map(files)
        temp_map=temp_map.submap([bbc[0], bbc[2]],[bbc[1], bbc[3]])
        out_map_list.append(temp_map)
        temp_map.save(file, filetype='.fits')
    print("out_map_list",aalen(out_map_list))
    return out_map_list
###########################################################################
###########################################################################
def get_difference_map(map_list):
    """
    
    
    Parameters:
    ==========
    map_list: List AIA map objects

    Output:
    ==========
    out_map_list: A list containing map objects of a running difference.

    Based upon an example in the SunPy blog by Keith
    """
    print("in get_difference_map")
    out_map_list=[]
    print("1 in get_difference_map")
    print(len(out_map_list))
    print(len(map_list))
    before=map_list[0]
    print("1a in get_difference_map")
    for maps in map_list:
        
        print("2 in get_difference_map")
        after=maps
        out_map_list.append(np.absolute(after-before))
        # before=after
        after=None

    out_map_list.pop(0)
    print("leaving get_difference_map")    
    return out_map_list
###########################################################################
###########################################################################
def get_mask_map(map_list):
    """
    
    
    Parameters:
    ==========
    map_list: List AIA map objects made from difference images

    Output:
    ==========
    out_map_list: A list containing map objects that constitute a mask for a region of interest.

    Based upon an example in the SunPy blog by Keith
    """
    
    print("Starting get_mask_map.")
    #mask_thresh=.5
    out_map_list=[]
    for maps in map_list:
        #print('here1')
        temp_map=maps.copy()
        temp_map[:][:]=image.median_filter(temp_map,footprint=[[0,1,0],[1,1,1],[0,1,0]])
        temp_map=(np.absolute(maps[:][:]))
        #print('here2')
        #temp_map[:][:]=image.gaussian_filter(temp_map, sigma=3)
        temp_map[:][:]=image.median_filter(temp_map,footprint=[[0,1,0],[1,1,1],[0,1,0]])
        #print('here3')
        #print('temp_map.center',temp_map.center)
        
        #print('here4')
        temp_map>(temp_map.mean()+temp_map.std())
        
        #print('here5')
        out_map_list.append(temp_map)

    print("Finished get_mask_map.")
    return out_map_list
###########################################################################
###########################################################################
def fcm_make_movie_map(map_list, directory, ev,frames_dir='FALSE',movie_dir='FALSE',
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
        frame=map_obj.plot(vmin=map_obj.min(), vmax=map_obj.max())
        #print('here2')
        ax = frame.add_subplot(111)
        #print('here3')
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
def check_mv(filename, fromdir, todir):
    """
    !!Not done until you have a complete DocString!! 
    """
    print(os.getpid())
    infile=os.path.join(fromdir,filename)
    outfile=os.path.join(todir,filename)
    
    shutil.copy2(infile, outfile)      
    #Check to see if the file was copied correctly. !!!! Work on.
    if os.path.getsize(infile) !=  os.path.getsize(outfile):        
        return False
    else:
        # print(os.path.getsize(infile))
        os.remove(infile)
        return True
###########################################################################
###########################################################################
def call_character_mod(filename):
    """
    !!Not done until you have a complete DocString!! 
    """
    print(os.getpid())
    #time.sleep(1)
    #Define Global Variables
    global PATH_2_Pending
    global PATH_2_Processing
    global PATH_2_Completed
    global PATH_2_Working
    global PATH_2_IDLpros
    global aia_top_dir
###########################################################################
        
    working_dir,fits_dir, frames_dir, movie_dir=make_working_paths(PATH_2_Working)  
   
    #Read in the event structure as a NumPy recarray
    save_file=os.path.join(PATH_2_Processing,filename)
    ev=readsav(save_file)
    
   
    #print(ev.event.EVENT_STARTTIME[0])
    file_list=get_aia_fits_path(ev)
    print(file_list)
    #Print the file list to a text file that IDL can read.
    
    list_file=open(os.path.join(working_dir,'fits_list.txt'), 'w')
    for files in file_list :
        list_file.write(files+'\n')

    #list_file.close()
    print("here 1")
    #Write an sswidl file to call
    idl_file=open(os.path.join(working_dir, 'fft_fcm_prep_fits.pro'), 'w')
    idl_file.write("file_name= '"+working_dir+"/fits_list.txt' \n")
    idl_file.write("file_list=rd_tfile(file_name,1) \n")
    idl_file.write("fits_dir= '"+fits_dir+"' \n")
    idl_file.write("ind=indgen(n_elements(file_list)) \n")
    idl_file.write("aia_prep, file_list[ind], ind,outdir=fits_dir,/DO_WRITE_FITS \n")
    idl_file.write("EXIT \n")
    idl_file.write("END \n")
    idl_file.close()
    print("here 2")
   
    print(working_dir)
    print(os.path.join(working_dir, 'fft_fcm_prep_fits.pro'))
    subprocess.call("ssw_batch "+os.path.join(working_dir, 
    	'fft_fcm_prep_fits.pro')+" "+os.path.join(working_dir,
    	 'fft_fcm_prep_fits.log'), shell=True )
    
    print("here 3")
    #Get a list of fits files in the current working directory
    working_file_list= glob.glob(os.path.join(working_dir,'fits', '*.fits'))
    #reduce the full sun image to the area of the flare. (List of AIAmap objects)
    #   print("Calling get_cropped_map")
    flare_map_list=get_cropped_map(ev, working_file_list)
    for iii, map_obj in enumerate(flare_map_list):
        map_obj.dump(os.path.join(working_dir,'map_'+str(iii).zfill(5)+'.pkl'))
    
    #map_out=open(os.path.join(working_dir,'map_list.pkl'),'wb')
    #pickle.dump(flare_map_list,map_out)
    #map_out.close()
    
    #print("here 4")
        
    
        
    #print("Completed get_cropped_map")
    #
    #make a Movie
    #
    #print("Calling fcm_make_movie_map")
    #fcm_make_movie_map(flare_map_list,working_dir, ev,frames_dir,movie_dir)
    #print("Completed fcm_make_movie_map")
    print(len(flare_map_list))
    difference_map_list=get_difference_map(flare_map_list)
    #print("here 5")
    difference_out=open('diff.pkl','wb')
    
    pickle.dump(difference_map_list,difference_out)
    difference_out.close()
    fcm_make_movie_map(difference_map_list, working_dir, ev,frames_dir,movie_dir,
                       frame_prefix="difference_frame",movie_name="difference_mov.mp4" )
    
    print("here 6")
    #mask_map_list=get_mask_map(flare_map_list)
    mask_map_list=get_mask_map(difference_map_list)
    mask_out=open('mask.pkl','wb')
    pickle.dump(mask_map_list,mask_out)
    mask_out.close()
    print("here11")
    fcm_make_movie_map(mask_map_list, working_dir, ev,frames_dir,movie_dir,
                       frame_prefix="mask_frame",movie_name="mask_mov.mp4", normal='ON' )
        #
    #Get the flare location from a median of the center of mass from the masked image
    #as a function of time.
    xy=get_flare_location(mask_map_list)
    print("\n")
    print("####################################################################")
    print("ev.event.EVENT_COORD1[0]",ev.event.EVENT_COORD1[0], ev.event.EVENT_COORD2[0])
    print("xy", xy)
    
    ev.event.EVENT_COORD1[0]=str(xy[0])
    ev.event.EVENT_COORD2[0]=str(xy[1])
    print("ev.event.EVENT_COORD1[0]",ev.event.EVENT_COORD1[0], ev.event.EVENT_COORD2[0])

    print("####################################################################")
    print("\n")
    
    fcm_make_movie_map(flare_map_list,working_dir, ev,frames_dir,movie_dir,
                       frame_prefix="update_frame",movie_name="update_mov.mp4" )
    print("There!")
    #Save reduced image
    
    #get a mask that covers non-flaring region as a function of time.
    #Calculate area as a function of time
    #
    
###########################################################################    
###########################################################################

