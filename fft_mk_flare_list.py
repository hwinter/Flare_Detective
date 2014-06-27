###########################################################################
#Import all of the modules necessary to run the code.
from sunpy.net import hek
import os  
import glob 
import datetime
import time
import shutil
import sys

###########################################################################
#This creates a client that we will use to interact with the HEK
client = hek.HEKClient()

#
t_start_string = '2010/06/01 00:00:01' 
t_start=datetime.datetime.strptime(t_start_string,"%Y-%m-%dT%H:%M:%S")
t_end = '2011/08/09 12:40:29'
event_type = 'FL'

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

result = client.query(hek.attrs.Time(tstart,tend),hek.attrs.EventType(event_type))