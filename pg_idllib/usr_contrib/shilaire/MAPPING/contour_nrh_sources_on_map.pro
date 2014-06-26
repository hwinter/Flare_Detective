;+
; NAME:
;     contour_nrh_sources_on_map
; PURPOSE:
;	Contours NRH source file(s) contents on a map at same time
;	The map can be a vector (i.e. a movie)
;	Map(s) is/are of Zarro's type
;	An additional map can be inserted, as contours for a certain ctimerange
;		(e.g. HXT contours to be drawn only during HXR burst...)
;
; CATEGORY:
;	PSH's PhD studies	
; CALLING SEQUENCE:
;    contour_nrh_sources_on_map,map,nrh_source_file,cmap=cmap,ctimerange=ctimerange,outmap,_extra=_extra
; INPUTS:
;     a map/map vector
;     a string array containing the pathnames of the NRH source file(s) that will be contoured
;
; OPTIONAL (KEYWORD) INPUT PARAMETERS:
;	* a contour map
;	* a ctimerange : string array [start,end] of 'hh:mm:ss.xxx'
;		if a contour map is given but no ctimerange, then the contour map is always displayed
;	* windowsize [x,y] in pixels. Default is [512,512]
;	* all optional input keywords of plot_map
;	 	- levels : default is [.98,.99]
;	
;	* if outpngpath is set to an output path, frXXX.png files will be created at this emplacement.
;
;      later on, I guess the contour map should be able to have its own contour levels...
;
;	* maxnbrsources : if set, limits the max nbr of sources per frequency to that number
;
;	* /nonrhtime : if set, will not display the time of the NRH image
;	
;	* npixels : default is 256
;
;	* nofreq : if set, will not display the frequency line
;
; OUTPUTS: 
;	an image array/image cube
; COMMON BLOCKS:
; SIDE EFFECTS:
; RESTRICTIONS:
; EXEMPLE  
; 	contour_nrh_sources_on_map,trace_map,{'164sourcefile','432sourcefile'],outmovie,/log,grid=10,xrange=[-100,300]
; 	contour_nrh_sources_on_map,trace_map,files,cmap=hxt_map,ctimerange=['12:14:00','12:16:00'],outmovie
;
; MODIFICATION HISTORY:
;     Created by PSH : Thursday, 2001/07/19, from my own "contour_nrh_on_map.pro"
;-


pro contour_nrh_sources_on_map,map,files,cmap=cmap,ctimerange=ctimerange, $
		clevels=clevels,pixmap=pixmap,windowsize=windowsize,outmovie,quiet=quiet,	$
		outpngpath=outpngpath,nonrhtime=nonrhtime,maxnbrsources=maxnbrsources,	$
		npixels=npixels,nofreq=nofreq,sfu_min=sfu_min,_extra=_extra
								
if not exist(cthick) then cthick=2
if not exist(windowsize) then windowsize=[512,768]
if not exist(clevels) then clevels=25*bindgen(10)+25  ; it's usually an HXT map...
if not exist(maxnbrsources) then maxnbrsources=-1
if not exist(npixels) then npixels=256
if not exist(sfu_min) then sfu_min=10.

cmapthick=1
cmapcolor=249

window,0,xsize=windowsize(0),ysize=windowsize(1),colors=256,pixmap=pixmap
myct3,ct=1
tvlct,r,g,b,/GET

nbrfreq=n_elements(files)
nbrimages=n_elements(map)
outmovie=bytarr(windowsize(0),windowsize(1),nbrimages)

for i=0,nbrimages-1 do begin 
	map_time=anytim(map(i).time,/time_only)
	plot_map,map(i),ncolors=241,/iso,_extra=_extra	
	
	if not exist(nofreq) then begin
		xyouts,30,760,'164 MHz',color=249,/dev
		xyouts,130,760,'236.6 MHz',color=250,/dev
		xyouts,230,760,'327 MHz',color=251,/dev
		xyouts,330,760,'410.5 MHz',color=252,/dev
		xyouts,430,760,'432 MHz',color=254,/dev
	endif
	
	for j=0,nbrfreq-1 do begin 
		; get nbr of sources...
		fits_info,files(j),/SILENT,N_ext=Next
		if maxnbrsources ne -1 then nbr_sources= maxnbrsources < Next else nbr_sources=Next
		
		; first , let's settle the color issue...
		l=j
		if l eq 4 then l=5	; I don't want a blue contour on a blue color table...

		for k=0,nbr_sources-1 do begin						
			;some time overlay checking...
			data=mrdfits(files(j),k+1)
			ntimes=n_elements(data.time)					
			nrh_starttime=data.time(0)/1000.
			nrh_endtime=data.time(ntimes-1)/1000.		
			if map_time lt nrh_starttime then print,'             				IMAGE BEFORE NRH DATA ! '
			if map_time gt nrh_endtime then print,'               				IMAGE AFTER NRH DATA ! '
			
			;now go for it...
			if ((map_time ge nrh_starttime) AND (map_time le nrh_endtime)) then begin 
	
				t=0
				while data.time(t) lt map_time*1000. do t=t+1
				; now, the correct t is either t or t-1
				; let's take the one closest in time to map_time
				if ntimes eq 1 then t=0 else if t ge ntimes then t=ntimes-1 else if abs(data.time(t-1)-1000.*map_time) lt  abs(data.time(t)-1000.*map_time) then t=t-1	


				if data.flux(t) ge sfu_min then begin
					; first, plot some infos... (freq, sourcenbr, time, intensity, flux)
					bla=int2str(k,1)
					bla=bla+':'
					xyouts,j*100,755-35*k,bla,color=249+l,/dev
					bla=ms2hms(data.time(t))+' UT'
					xyouts,10+j*100,745-35*k,bla,color=249+l,/dev
					bla=STRN(data.intensity(t)/1000000.,FORMAT='(f9.3)')+' MK'
					xyouts,10+j*100,735-35*k,bla,color=249+l,/dev
					bla=strtrim(data.flux(t),2)+' SFU'
					xyouts,10+j*100,725-35*k,bla,color=249+l,/dev
					
					; and finally plot the sources themselves...(and source nbr !)
					pixsize=nrh_pixarcsec(map(i).time,1.)
					x=ind_rs(data.ewpos(t),npixels/2,npixels/4)*pixsize
					y=ind_rs(data.nspos(t),npixels/2,npixels/4)*pixsize
					a=ind_rs(1/SQRT(data.majaxis(t)),0,npixels/4)*pixsize
					b=ind_rs(1/SQRT(data.minaxis(t)),0,npixels/4)*pixsize
					ang=data.angle(t)	; radians ? ... I think
				
					; now, to plot an oblique ellipse with the above info...
					mytvellipse,a,b,x,y,ang*180./!PI,color=249+l,/data
					xyouts,x,y,strtrim(k,2),color=249+l
				endif
			endif
		endfor
	endfor
			
	if exist(cmap) then begin
			if not exist(ctimerange) then begin
				Ncmap=n_elements(cmap)
				for j=0,Ncmap-1 do plot_map,cmap(j),/over,lcolor=cmapcolor+j,levels=clevels
			endif else begin
				Ncmap=n_elements(cmap)
				map_time2=map(i).time
				map_time2=str2utc(map_time2)
				map_time2=map_time2.time
				for j=0,Ncmap-1 do begin				
					tstart=str2utc(ctimerange(0,j))
					tstart=tstart.time
					tend=str2utc(ctimerange(1,j))
					tend=tend.time
					if map_time2 gt tstart and map_time2 lt tend then plot_map,cmap(j),/over,lcolor=cmapcolor+l,levels=clevels	
				endfor	
			endelse
	endif
	
	outmovie(*,*,i)=tvrd()
	if keyword_set(outpngpath) then write_png,outpngpath+'fr'+int2str(i,4)+'.png',outmovie(*,*,i),r,g,b
	if not exist(quiet) then print,'		Percent completed : ',100*(i+1)/nbrimages
endfor
end






