;+
; NAME:
;     map_on_nrh
; PURPOSE:
;	This is the counterpart of contour_nrh_on_map.pro : instead of making images 
;	depending on the times of the map(s), a time interval is given, as well as
;	a timestep between each images.
;
; CATEGORY:
;	PSH's PhD studies	
; CALLING SEQUENCE:
;	...
; INPUTS:
;	  a timerange (anytim format)
;	  a timestep (in seconds)
;     a map or map vector
;     a string array containing the pathnames of the NRH image files that will be contoured
;	  a string containing the directory of nrh files (compability with stupid new read_nrh)
;
; OPTIONAL (KEYWORD) INPUT PARAMETERS:
;	  a contour map (cmap) or cmap vector, with ctimerange or ctimerange vector in hh:mm:ss:xxx format  [no DATE !!!]
;		if a contour map is given but no ctimerange, then the contour map is always displayed
;	* windowsize [x,y] in pixels. Default is [512,512]
;	* all optional input keywords of plot_map
;	 	- levels : default is [.98,.99]
;	
;	* if outpngpath is set to an output path, frXXX.png files will be created at this emplacement.
;;
; OUTPUTS: 
;	an image array/image cube
; COMMON BLOCKS:
; SIDE EFFECTS:
; RESTRICTIONS:
;	*if the NRH source is not maximum at image FOV, too bad...
;	 The above should easily be correctible...
;	* it is assumed the input maps are already arranged in a chronological order !!!
; EXEMPLE  
;	timerange='2000/06/21 '+['09:24:00','09:26:00']
;	timestep=5.
;	nrhdir='/global/carme/home/shilaire/mylepus/nrh/'
;	nrhfile=['nrh2_1640_h70_20000621_092158:06_c.fts','nrh2_2366_h70_20000621_092158:06_c.fts',$
;		'nrh2_3270_h70_20000621_092158:06_c.fts','nrh2_4105_h70_20000621_092158:06_c.fts',$
;		'nrh2_4320_h70_20000621_092158:06_c.fts']
;	map_on_nrh,timerange,timestep,nrhdir,nrhfile,sxt_map,outmovie,grid=10
;
; MODIFICATION HISTORY:
;     Created by PSH : Thursday, 2001/06/14
;		
;		Modified : 2001/06/21 : checks for datagaps in NRH data...
;-


function return_map_number,map,time
; this functions returns the proper framenbr (=map number) according to time
; i.e. the frame which is closest in time to the input time
time=anytim(time)
out=-1	; initialize output
N=n_elements(map)

if N eq 1 then return,0 
if time le anytim(map(0).time) then return,0
if time ge anytim(map(N-1).time) then return,N-1

; OK, now we're sure time is inside the set of maps.
i=0
while out eq -1 do begin
	if (time gt anytim(map(i).time)) then i=i+1 else begin
		; now I have to choose between i-1 and i
			if ((time-anytim(map(i-1).time)) le (anytim(map(i).time)-time)) then return,i-1 else return,i
												endelse
endwhile
return,out
END




;*******************************************************************************
;*******************************************************************************
;*******************************************************************************
;*******************************************************************************
PRO map_on_nrh,timerange,timestep,nrhdir,nrhfile,map,outmovie,cmap=cmap,ctimerange=ctimerange, $
		levels=levels, clevels=clevels,pixmap=pixmap,windowsize=windowsize,quiet=quiet,	$
		outpngpath=outpngpath,noTb=noTb,_extra=_extra
								
if not exist(levels) then levels=[0.98,0.99]
if not exist(cthick) then cthick=2
if not exist(windowsize) then windowsize=[512,512]
if not exist(clevels) then clevels=25*bindgen(10)+25  ; it's usually an HXT map...

timerange=anytim(timerange)
cmapthick=1
cmapcolor=249

time_interval=timerange(1)-timerange(0)
Nimg=ceil(time_interval/float(timestep))

window,0,xsize=windowsize(0),ysize=windowsize(1),colors=256,pixmap=pixmap
myct3,ct=1
tvlct,r,g,b,/GET

Nfreq=n_elements(nrhfile)
outmovie=bytarr(windowsize(0),windowsize(1),Nimg)

; now, get nrh start and end times...
read_nrh,nrhfile(0),nindex,ndata,dir=nrhdir
nrh_starttime=nindex.tim_str
nrh_endtime=nindex.tim_end
if Nfreq gt 1 then begin
	for j=1,Nfreq-1 do begin 
		read_nrh,nrhfile(j),nindex,ndata,dir=nrhdir
		nrh_starttime=[nrh_starttime,nindex.tim_str]
		nrh_endtime=[nrh_endtime,nindex.tim_end]
	endfor
endif

curtime=timerange(0)
for i=0,Nimg-1 do begin 
	plot_map,map(return_map_number(map,curtime)),ncolors=241,_extra=_extra
	curtimeofday=anytim(curtime,/ECS)
	curtimeofday=rsi_strsplit(curtimeofday,/EXTRACT)
	curtimeofday=curtimeofday(1)
	xyouts,0.70,0.02,/norm,charsize=1.5,'NRH: '+curtimeofday
	for j=0,Nfreq-1 do begin 
		if ((curtimeofday ge nrh_starttime(j)) and (curtimeofday le nrh_endtime(j))) then begin
			temp=curtimeofday
			read_nrh,nrhfile(j),nindex,ndata,dir=nrhdir,hbeg=temp			
			index2map,nindex,ndata,nrh_image
			maxpixelTb=max(nrh_image.data)
			nrh_image.data=nrh_image.data/maxpixelTb	; normalize NRH data...
			k=j
			if k eq 4 then k=5	; I don't want a blue contour on a blue color table...
			
				;NEW! :check for datagaps in nrh data. If nrh data too far away, don't plot it, and announce a datagap
				if abs(curtime-anytim(nrh_image.time)) gt timestep then begin	; gt timestep/2. would be a bit more logical, but pretty stringent, 
					xyouts,5,100-10*j,'GAP',color=249+k,/device								; considering the fact that hbeg=... returns the closest time AFTER...
					print,' ......................NO NRH DATA WITHIN timestep (GAP) for freq# ',j
				endif else begin
			plot_map,nrh_image,/over,levels=levels,lcolor=249+k,cthick=cthick		
				endelse
		endif else print,'.................................. outside of NRH data ......'
	
		if not exist(noTb) then begin
			bla=STRN(maxpixelTb/1000000.,format='(f8.3)') +' MK'
			xyouts,/dev,5,490-25*j,bla,color=249+k
		endif		
	endfor

	if exist(cmap) then begin
			Ncmap=n_elements(cmap)
			if not exist(ctimerange) then begin
				for j=0,Ncmap-1 do begin
					k=j
					if k gt 5 then k=5
					plot_map,cmap(j),/over,lcolor=cmapcolor+k,levels=clevels
				endfor
			endif else begin
				for j=0,Ncmap-1 do begin
					if ((curtimeofday ge ctimerange(0,j)) AND (curtimeofday le ctimerange(1,j))) then begin
						k=j
						if k gt 5 then k=5
						plot_map,cmap(j),/over,lcolor=cmapcolor+k,levels=clevels
					endif
				endfor	
			endelse
	endif
	
outmovie(*,*,i)=tvrd()
if keyword_set(outpngpath) then write_png,outpngpath+'fr'+int2str(i,4)+'.png',outmovie(*,*,i),r,g,b
if not exist(quiet) then print,'		Percent completed : ',100*(i+1)/Nimg

curtime=curtime+timestep
endfor	
END	

