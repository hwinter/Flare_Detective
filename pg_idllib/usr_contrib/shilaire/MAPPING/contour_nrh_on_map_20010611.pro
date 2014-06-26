;+
; NAME:
;     contour_nrh_on_map
; PURPOSE:
;	Contours NRH image files contents on a map at same time
;	The map can be a vector (i.e. a movie)
;	Map(s) is/are of Zarro's type
;	An additional map can be inserted, as contours for a certain timerange
;		(e.g. HXT contours to be drawn only during HXR burst...)
;
; CATEGORY:
;	PSH's PhD studies	
; CALLING SEQUENCE:
;    contour_nrh_on_map,map,nrh_images_files,cmap=cmap,timerange=timerange,outmap,_extra=extra
; INPUTS:
;     a map/map vector
;     a string array containing the pathnames of the NRH image files that will be contoured
;
; OPTIONAL (KEYWORD) INPUT PARAMETERS:
;	* a contour map
;	* a timerange : string array [start,end] of 'hh:mm:ss.xxx'
;		if a contour map is given but no timerange, then the contour map is always displayed
;	* windowsize [x,y] in pixels. Default is [512,512]
;	* all optional input keywords of plot_map
;	 	- levels : default is [.98,.99]
;	
;      later on, I guess the contour map should be able to have its own contour levels...
;	and one should have the option of determining its color index... (should be from 0,250-255)
;	and the thickness.... (default now is 2)
;
; OUTPUTS: 
;	an image array/image cube
; COMMON BLOCKS:
; SIDE EFFECTS:
; RESTRICTIONS:
;	*if the NRH source is not maximum at image FOV, too bad...
;	 The above should easily be correctible...
;	*I should not try to contour more than the five NRH frequencies (or change color table....)
; EXEMPLE  
; 	contour_nrh_on_map,trace_map,['164file','236file','432file'],outmovie,/log,grid=10,xrange=[-100,300]
; 	contour_nrh_on_map,trace_map,nrh_image_files,cmap=hxt_map,timerange=['12:14:00','12:16:00'],outmovie
;
; COMPLETE DEMONSTRATION ON HOW TO USE THIS PROCEDURE
;	- create a map/map vector from TRACE, SXT, HESSI, etc...
;	- have NRH image files ready (any resolution, any frequencies)
;	- the contour colors are rainbow-ordered... so should the  NRH image files string vector be in order of increasing frequency...
;	- contour_nrh_on_map,...,outmovie
;	- stepper,outmovie
;
; MODIFICATION HISTORY:
;     Created by PSH : Wednesday, 20 dec 2000
;					1)nomargins
;					2)option to contour local NRH maximum if global maximum is not in viewport
;					3)vectorized cmap and timerange ?
;					4)option to use shared colortable?
;					5)show maximum flux/pixel for each NRH freq.
;					6)show some information (map/NRH pixel resolution,etc...)
;
;-


;****************************************************
;*********** a useful routine by PSH ****************
;****************************************************

pro myct2,nb=nb
;nb is actually the number of color indices available.
if not exist(nb) then nb=!D.TABLE_SIZE
loadct,1,ncolors=nb-6
tvlct,r,g,b,/get
r(nb-6)=255
r(nb-5)=255
r(nb-4)=255
r(nb-3)=0
r(nb-2)=255
r(nb-1)=255
g(nb-6)=0
g(nb-5)=90
g(nb-4)=255
g(nb-3)=255
g(nb-2)=0
g(nb-1)=255
b(nb-6)=0
b(nb-5)=9
b(nb-4)=0
b(nb-3)=0
b(nb-2)=255
b(nb-1)=255
tvlct,r,g,b
print,' Now using the modified BLUE/WHITE color table of PSH... '
end


;****************************************************
;****************  THE MAIN EVENT   *****************
;****************************************************


pro contour_nrh_on_map,map,nrh_image_files,cmap=cmap,timerange=timerange, $
		pixmap=pixmap,windowsize=windowsize,outmovie,_extra=extra
								
if not exist(levels) then levels=[0.98,0.99]
if not exist(cthick) then cthick=2
if not exist(windowsize) then windowsize=[512,512]
cmapthick=1
cmapcolor=250
cmaplevels=[25,50,75,100,125,150,175,200,225,250]	; it's usually an HXT map...


window,0,xsize=windowsize(0),ysize=windowsize(1),colors=256,pixmap=pixmap
myct2
nbrfreq=n_elements(nrh_image_files)
nbrimages=n_elements(map)
outmovie=bytarr(windowsize(0),windowsize(1),nbrimages)

for i=0,nbrimages-1 do begin 
	map_time=strsplit(map(i).time,/tail)     ; in 'hh:mm:ss:xxx'
	plot_map,map(i),ncolors=!D.TABLE_SIZE-6,_extra=extra	
	for j=0,nbrfreq-1 do begin 
		read_nrh,nrh_image_files(j),nindex,ndata				
		nrh_starttime=nindex.tim_str
		nrh_endtime=nindex.tim_end
		if map_time(0) lt nrh_starttime then print,'             				IMAGE BEFORE NRH DATA ! '
		if map_time(0) gt nrh_endtime then print,'               				IMAGE AFTER NRH DATA ! '
		if ((map_time(0) ge nrh_starttime) AND (map_time(0) le nrh_endtime)) then begin $
			read_nrh,nrh_image_files(j),nindex,ndata,hbeg=strsplit(map(i).time,/tail) 
			index2map,nindex,ndata,nrh_image
			nrh_image.data=nrh_image.data/max(nrh_image.data)	; normalize NRH data...
			plot_map,nrh_image,/over,levels=levels,lcolor=!D.TABLE_SIZE-6+j,cthick=cthick
											  end
		     	     end
	
	if exist(cmap) then begin
			if not exist(timerange) then plot_map,cmap,/over,lcolor=cmapcolor
			if exist(timerange) then begin
				map_time2=str2utc(map(i).time)
				map_time2=map_time2.time   		; in ms
				tstart=str2utc(timerange(0))
				tend=str2utc(timerange(1))
				if map_time2 gt tstart.time and map_time2 lt tend.time then plot_map,cmap,/over,lcolor=cmapcolor,levels=cmaplevels	
						end
			end
	
	outmovie(*,*,i)=tvrd()
	print,'		Percent completed : ',100*(i+1)/nbrimages
			     end
end






