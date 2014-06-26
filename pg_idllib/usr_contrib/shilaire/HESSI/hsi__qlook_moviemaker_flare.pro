; by Pascal Saint-Hilaire Feb. 23th,2001
; shilaire@astro.phys.ethz.ch OR psainth@hotmail.com
;
;
;
; EXEMPLE : hsi__qlook_moviemaker_flare,1380,pngfile='HESSI_Qlook_'
;
; List of possible improvements:
;	- normalization (using instant count rates vs. peak value ?)
;	  (so that when source is still/gets faint, 
;	  the background doesn't appear to be higher...)
;	- overlaid with other images ???
;	- only picture, without frame nor info....?
;	- other parameter tweaking...
;




pro hsi__qlook_moviemaker_flare,flarenbr,moviepath=moviepath, $
	pngfile=pngfile, moviestartend=moviestartend,timestep=timestep, $
	imagedim=imagedim,pixelsize=pixelsize

if not exist(moviepath) then moviepath='/global/helene/home/www/staff/shilaire/private/PNG_MOVIES/HESSI_Qlook/'
if not exist(pngfile) then pngfilename='HESSI_Qlook_img_'
if not exist(moviestartend) then moviestartend=[600.,600.]	; 10 min before, to 10 after...
if not exist(timestep) then timestep=30.	;  30 secs between pictures
if not exist(imagedim) then imagedim=64
if not exist(pixelsize) then pixelsize=2.


color_file = loc_file(path=hessi_data_paths(), 'colors_hessi.tbl')
loadct, file=color_file, 41
tvlct,r,g,b,/get

flist = hsi_read_flarelist()
i=0
while flist(i).id_number ne flarenbr do i=i+1
flare=flist(i)

NBR=round( (anytim(flare.end_time) + moviestartend(1)-anytim(flare.start_time)+ moviestartend(0))/timestep)
NBR=NBR+1
print,NBR

wdef,0
o=hsi_image()
time=anytim(flare.start_time) - moviestartend(0)

starttime=systime(/sec)

for i=0,NBR-1 do begin
	im=o->getdata(/plot,obs_time_interval=[time,time+timestep] ,timerange=[-2.,2.], $
	      image_algorithm='back projection', energy_band=[12.,25.], $
		       xyoffset=[flare.position(0),flare.position(1)], $
	       image_dim=[imagedim,imagedim], pixel_size=[pixelsize,pixelsize], $
		a2d_index_mask=[0,0,0,1,1,1,1,1,0,0,0,0,1,1,1,1,1,0,0,0,0,1,1,1,1,1,0])
		;       front_segment=1, rear_segment=0 
    		 
	print,anytim(time,/yoh)

	img=tvrd()
	filename=moviepath+pngfile+int2str(i,3)+'.png'			; I'd be surprised if NBR is > 1000 ...
	write_png,filename,img,r,g,b
	
        time=time+timestep
	print,'....... percent completed : ',100 * (i+1)/NBR
		 end

endtime=systime(/sec)
print,'.............................the loop took : ',endtime-starttime,' seconds.'
end
