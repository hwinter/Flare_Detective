

;use /usr/bin/time herkidl

;the following are system-dependant:
	;cd,'\hessi_data\psh'
	SETENV,'HSI_DATA_ARCHIVE=~/.'
	
	pslist='user,nice,comm,vsz,rss,etime,cputime,systime,usertime,sl' ;for carme
	;pslist='user,nice,args,vsz,rss,etime,time' ;for hercules
	;pslist='user,nice,comm,vsz,rss,etime,cputime' ;for stokes


;===========================================================================


starttime=systime(/seconds)

io=hsi_image()
io->set,time_range=anytim('2000/09/01 '+['04:07:16','04:07:20'])
io->set,xyoffset=[-790,300],pixel_size=[4.,4.]
io->set,image_algorithm='pixon',energy_band=[12,25]
io->set,det_index_mask=[0,0,0,0,1,1,1,1,0]
io->set_no_screen_output
data=io->getdata()
;io->fitswrite,fitsfile='pixon_image.fits'
io->plot

obj_destroy,io
io=-1
heap_gc


endtime=systime(/seconds)
print,'Duration = '+strn(endtime-starttime)+' seconds'
openw,lun,'pixon_time.txt',/GET_LUN
printf,lun,strn(endtime-starttime)
	pscmd='ps -Ao "'+pslist+'" |grep shilaire |grep idl'
	printf,lun,'Result of '+pscmd+' :'
	SPAWN,pscmd,res
	printf,lun,res
FREE_LUN,lun

	EXIT
END

