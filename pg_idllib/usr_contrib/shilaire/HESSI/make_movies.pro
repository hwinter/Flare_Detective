; This is a quick and dirty routine to make a Hessi movie on the run.
;INPUT:
;	Trace fits files
;	Hessi fits files
;
;OUTPUTS:
;	javascript movie
;	MPEG movie
;
;
; Written PSH, 2001/11/09
;
; Needs TRUE COLOR DISPLAY !
; Takes only positive valuesw of Hessi map.




PRO make_movies , tracefits, hessifits, mpeg=mpeg, prep=prep, xdim=xdim,ydim=ydim

IF NOT KEYWORD_SET(xdim) THEN xdim=512
IF NOT KEYWORD_SET(ydim) THEN ydim=512


; make maps out of the trace fits files
trace_map=-1
FOR i=0,n_elements(tracefits) DO BEGIN
	read_trace,tracefits(i),-1,index,data
	IF KEYWORD_SET(prep) THEN trace_prep,index,data,outindex,outdata,/wave2point,/unspike,/destreak,/deripple,/normalize ELSE BEGIN
		outindex=index
		outdata=data
	ENDELSE
	index2map,outindex,outdata,newmap
	IF DATATYPE(trace_map) EQ 'INT' THEN trace_map=newmap ELSE merge_struct(trace_map,newmap)
ENDFOR
;OK, that's it for the TRACE map.

; Now, for HESSI;
hessi_map=-1
FOR i=0,n_elements(hessifits)-1 DO BEGIN
	fits2map,hessifits(i),newmap
	IF DATATYPE(hessi_map) EQ 'INT' THEN hessi_map=newmap ELSE merge_struct(hessi_map,newmap)
ENDFOR
;OK, that's it for the HESSI map.


;NOW, put them on top of each other... properly !!!
trace_img=congrid(trace_map.data,xdim,ydim,/INTERP)
; The TRACE image will set the frame of the whole thing...


; Take only positive values of HESSI image
hessi_img=congrid(hessi_map.data,xdim,ydim,/INTERP)
ss=WHERE(hessi_img LT 0)
hessi_img(ss)=0


; TRUE COLORS:
TVLCT,INDGEN(256),INDGEN(256),INDGEN(256)



;...append to previous images...
;TV,img,true=1
END


;plot_map,hessi_map,/noaxes,xmargin=[0,0],ymargin=[0,0],/iso,grid=10
;restore,'/global/tethys/users/shilaire/HXR_DCIM/1999_09_08/19990809.dat',/verbose
