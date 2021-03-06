;+
; NAME:
;     contour_nrh_on_map
; PURPOSE:
;	Contours NRH image files contents on a map at same time
;	The map can be a vector (i.e. a movie)
;	Map(s) is/are of Zarro's type
;	An additional map can be inserted, as contours for a certain ctimerange
;		(e.g. HXT contours to be drawn only during HXR burst...)
;
; CATEGORY:
;	PSH's PhD studies	
; CALLING SEQUENCE:
;    contour_nrh_on_map,map,nrh_images_files,cmap=cmap,ctimerange=ctimerange,/norm,outmap,_extra=extra
; INPUTS:
;     a map/map vector
;     a string array containing the pathnames of the NRH image files that will be contoured
;
; OPTIONAL (KEYWORD) INPUT PARAMETERS:
;	* a contour map
;	* a ctimerange : string array [start,end] of 'hh:mm:ss.xxx'
;		if a contour map is given but no ctimerange, then the contour map is always displayed
;	* winsize [x,y] : window size in pixels. Default is [512,512]
;	* all optional input keywords of plot_map
;	 	- levels : default is [.98,.99]
;	
;	* if outpngpath is set to an output path, frXXX.png files will be created at this emplacement.
;
;      later on, I guess the contour map should be able to have its own contour levels...
;
;	* /nonrhtime : if set, will not display the time of the NRH image
;
;	* /Tb : if set, will display the highest brightness temperature pixel in the NRH map,
;					for each frequency
;
;	* smooth_NRH : set this value above 1 to have smoothing of NRH (time consuming!!!)
;
;	* /normalize: if set, will normalize maps to 1 sec of exposure, and drange=[min(map(*).data),max(map(*).data)]
;
;	* roimax	: if set, will check if global maximum is outside FOV, if yes, will then plot LOCAL
;				maximum (i.e. inside FOV) in pointed lines, and add (in parenthesis) the Tb value.
;					roimax is a contour levels range, as a fraction of local maximum.
;
;	* /noinfo	: if set, will not print the additional informations.
;
;

; OUTPUTS: 
;	an image array/image cube
; COMMON BLOCKS:
; SIDE EFFECTS:
;	if /norm is set, will normalize each input map.data by map.dur
;
; RESTRICTIONS:
;	*if the NRH source is not maximum at image FOV, too bad...
;	 The above should easily be correctible...
; EXEMPLES  
; 	contour_nrh_on_map,trace_map,['164file','236file','432file'],outmovie,/log,grid=10,xrange=[-100,300],smooth_nrh=3,/normalize,roimax=[0.9,0.95]
; 	contour_nrh_on_map,trace_map,nrhfiles,cmap=hxt_map,ctimerange=['12:14:00','12:16:00'],outmovie,/normalize
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
;					1)option to contour local NRH maximum if global maximum is not in viewport
;					2)vectorized cmap and ctimerange ---> DONE!
;					3)show maximum flux/pixel for each NRH freq.
;					4)show some information (map/NRH pixel resolution,etc...)
;
;		Modified: PSH, 2001/06/11 : adapted for new read_nrh  compability
;									rewrote some parts in a better way 
;
;		Modified: PSH, 2001/06/14 : accepts a vectorized version of cmap and ctimerange
;									ex: cmap=[map1,map2,map3], ctimerange=[[t1,t2],[t3,t4],[t5,t6]]
;									here, ctimerange is either completely specified, or not at all.
;									All cmaps above the fifth are purple.
;
;		Modified: PSH, 2001/07/19 : added keyword /nonrhtime 
;		Modified: PSH, 2001/07/20 : added keyword /noTb 
;									added keyword smooth_NRH
;				PSH, 2001/08/06 : modified so that nrh data is normalized AFTER eventual smoothing
;		Modified: PSH, 2001/12/14 : -added much-needed /norm keyword
;									-drange of each map is [min,max] of ALL normalized maps
;		
;		Modified: PSH, 2001/12/16 : -added /roimax and /noinfo keywords
;
;
;-


pro contour_nrh_on_map,map,nrh_dir,nrh_image_files,cmap=cmap,ctimerange=ctimerange, $
		clevels=clevels,pixmap=pixmap,winsize=winsize,outmovie,quiet=quiet,	$
		outpngpath=outpngpath,levels=levels,nonrhtime=nonrhtime,noTb=noTb,	$
		smooth_NRH=smooth_NRH,normalize=normalize,roimax=roimax,noinfo=noinfo,_extra=extra
								
if not exist(levels) then levels=[0.98,0.99]
if not exist(cthick) then cthick=2
if not exist(winsize) then winsize=[512,512]
if not exist(clevels) then clevels=25*bindgen(10)+25  ; it's usually an HXT map...

cmapthick=1
cmapcolor=249


window,0,xsize=winsize(0),ysize=winsize(1),colors=256,pixmap=pixmap
myct3,ct=1
tvlct,r,g,b,/GET

nbrfreq=n_elements(nrh_image_files)
nbrimages=n_elements(map)
	;if /norm....
	IF KEYWORD_SET(normalize) THEN BEGIN
		FOR i=0,nbrimages-1 DO BEGIN 
			map(i).data=map(i).data/map(i).dur
			map(i).dur=1.
		ENDFOR		
		; now, find max and min of map to properly display
		themax=max(map.data,min=themin)
	ENDIF
outmovie=bytarr(winsize(0),winsize(1),nbrimages)

;now start main loop...
for i=0,nbrimages-1 do begin 
	map_time=rsi_strsplit(map(i).time,/EXTRACT)     ; in 'hh:mm:ss:xxx' ; not SLF's strsplit !!!
	map_time=map_time(1)
	IF KEYWORD_SET(normalize) THEN plot_map,map(i),ncolors=241,drange=[themin,themax],_extra=extra ELSE plot_map,map(i),ncolors=241,_extra=extra
	for j=0,nbrfreq-1 do begin 
		read_nrh,nrh_image_files(j),nindex,ndata,dir=nrh_dir				
		nrh_starttime=nindex.tim_str
		nrh_endtime=nindex.tim_end
		if map_time(0) lt nrh_starttime then print,'             				IMAGE BEFORE NRH DATA ! '
		if map_time(0) gt nrh_endtime then print,'               				IMAGE AFTER NRH DATA ! '
		if ((map_time(0) ge nrh_starttime) AND (map_time(0) le nrh_endtime)) then begin $
			hbeg=rsi_strsplit(map(i).time,/EXTRACT)
			hbeg=hbeg(1)
			read_nrh,nrh_image_files(j),nindex,ndata,dir=nrh_dir,hbeg=hbeg 
			index2map,nindex,ndata,nrh_image
			maxpixelTb=max(nrh_image.data)
			
			if exist(smooth_nrh) then begin
				smooth_nrh=smooth_nrh > 2
				oldsize=size(nrh_image.data)
				nrh_map=make_map(rebin(nrh_image.data,smooth_nrh*oldsize(1),smooth_nrh*oldsize(2)),xc=nrh_image.xc, $
					yc=nrh_image.yc, dx=nrh_image.dx/FLOAT(smooth_nrh), dy=nrh_image.dy/FLOAT(smooth_nrh))			
			endif else nrh_map=nrh_image

			nrh_map.data=nrh_map.data/max(nrh_map.data)	; normalize NRH data...			

			k=j
			if k eq 4 then k=5	; I don't want a blue contour on a blue color table...
			plot_map,nrh_map,/over,levels=levels,lcolor=249+k,cthick=cthick,smooth_width=smooth_nrh
			
			if not exist(nonrhtime) then XYOUTS,5,500-35*j,/dev,hbeg,color=249+k	
			if not exist(noTb) then begin
				bla=STRN(maxpixelTb/1000000.,format='(f12.3)') +' MK'
				xyouts,/dev,5,490-35*j,bla,color=249+k
			endif
			
			;THE FOLLOWING LINES ACT WHEN GLOBAL MAXIMUM IS NOT IN FOV
			IF KEYWORD_SET(roimax) THEN BEGIN
				; check whether global maximum is in FOV:			
				globalmax=FLOAT(max2d(nrh_map.data))	; nrh pixel location of global maximum.
				globalmax(0)=FLOAT(globalmax(0)-N_ELEMENTS(nrh_map.data(*,0))/2)*nrh_map.dx + nrh_map.xc	;converts nrh pixels coord. to arcsecs				
				globalmax(1)=FLOAT(globalmax(1)-N_ELEMENTS(nrh_map.data(0,*))/2)*nrh_map.dy + nrh_map.yc	;converts nrh pixels coord. to arcsecs				
				
				theXfov=!X.crange
				theYfov=!Y.crange
				
				IF ( (NOT is_in_range(globalmax(0),theXfov)) OR (NOT is_in_range(globalmax(1),theYfov)) ) THEN BEGIN
					; OK, now, take a sub-map of the nrh_map, and overlay it!					
					sub_map,nrh_map,sub_nrh_map,xrange=theXfov,yrange=theYfov							
					; find local (i.e. in FOV) maximum Tb, out it in appropriate units:
					localmaxpixelTb=max(sub_nrh_map.data)*maxpixelTb
					; normalize sub_nrh_map
					sub_nrh_map.data=sub_nrh_map.data/max(sub_nrh_map.data)
					;overlay it
					plot_map,sub_nrh_map,/over,levels=roimax,lcolor=249+k,cthick=cthick,smooth_width=smooth_nrh,cstyle=2
					; add the localmaxTb to the display:
					IF NOT KEYWORD_SET(noTb) THEN BEGIN
						bla='('+STRN(localmaxpixelTb/1000000.,format='(f12.3)') +' MK)'
						xyouts,/dev,5,480-35*j,bla,color=249+k						
					ENDIF				
					IF NOT KEYWORD_SET(noinfo) THEN BEGIN
						ligne='LOCAL: '+STRN(roimax(0))+' '+STRN(roimax(1))
						XYOUTS,/dev,330,5,ligne						
					ENDIF
				ENDIF						
			ENDIF
		endif
	endfor	; j loop
	
	if exist(cmap) then begin
			if not exist(ctimerange) then begin
				Ncmap=n_elements(cmap)
				for j=0,Ncmap-1 do plot_map,cmap(j),/over,lcolor=cmapcolor+j,levels=clevels
				IF ((NOT KEYWORD_SET(noinfo)) AND (EXIST(clevels))) THEN BEGIN
					ligne='Contour map levels: '+STRN(clevels(0))
					for ii=1,N_ELEMENTS(clevels)-1 do ligne=ligne+'/'+STRN(clevels(ii))
					XYOUTS,/dev,35,15,ligne
				ENDIF
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
					k=j
					if k gt 5 then k=5
					if map_time2 gt tstart and map_time2 lt tend then BEGIN
						plot_map,cmap(j),/over,lcolor=cmapcolor+k,levels=clevels	
						IF ((NOT KEYWORD_SET(noinfo)) AND (EXIST(clevels))) THEN BEGIN
							ligne='Contour map levels: '+STRN(clevels(0))
							for ii=1,N_ELEMENTS(clevels)-1 do ligne=ligne+'/'+STRN(clevels(ii))
							XYOUTS,/dev,35,15,ligne
						ENDIF
					endif
				endfor	
			endelse
	endif
	
	IF NOT KEYWORD_SET(noinfo) THEN BEGIN
		ligne='NRH contour levels: '+STRN(levels(0))+' '+STRN(levels(1))
		XYOUTS,/dev,35,5,ligne
		IF KEYWORD_SET(normalize) THEN XYOUTS,/dev,35,25,'normalized map'
	ENDIF
	
	outmovie(*,*,i)=tvrd()
	if keyword_set(outpngpath) then write_png,outpngpath+'fr'+int2str(i,4)+'.png',outmovie(*,*,i),r,g,b
	if not exist(quiet) then print,'		Percent completed : ',100*(i+1)/nbrimages
endfor	; i loop
end






