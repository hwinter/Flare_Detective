;+
;
; NAME:
;       imseq_ltc
;
; PROJECT: 
;       rhessi - data analysis
;
; PURPOSE: 
;       compute a lightcurve from a sequence of images
;       Method:
;          A.) Compute a total image OR
;          B.) Compute a total image from minframe to maxframe
;       then choose ROI based on a specified contour level of this
;       image. Keyword in/output allows to use different methods.
;
;
; CALLING SEQUENCE:
;       imseq_ltc,ptr,lev=lev,tim=tim,lc=lc,minframe=minframe,maxframe=maxframe
;                ,box=box
; INPUTS:
;       ptr: array of pointer to map structures
;       lev: percent of maximum of total image used for selecting the ROI
;       min-,max- frame: minimum,maximum frame for the total image to
;                 be computed in order to get THE ROI
;       box: coordinates [x1,x2,y1,y2] of a box, lightcurve computed
;       from data inside box instead of previous method
;
; OUTPUT:
;       by keywords
;       
; KEYWORDS:
;       lc,tim: lightcurve & time array 
;       err: if not equal 0, then an error happened
;       
; EXAMPLE:
;        
;
; VERSION:
;       28-JAN-2003 (re)written, based on imaginglightcurvemap
;       13-MAR-2003 modified...
;       25-MAR-2003 updated header
;       28-MAR-2003 added box keyword
;       31-MAR-2003 fixed box ROI finding bug (tested, should work
;       fine now!)
;       09-APR-2003 added err keyword, improved check for boxes outside
;                   the image range
;
; COMMENT:
;       
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;-

PRO imseq_ltc,ptr,lev=lev,lc=lc,tim=tim,totalflux=totalflux $
             ,minframe=minframe,maxframe=maxframe,box=box $;,roi=roi
             ,negative=negative,out_roi=out_roi,err=err
             ;,positive_only=positive_only


;------------------------------------------------------
; initialisation
;------------------------------------------------------

dim=size(ptr)
err=0

;------------------------------------------------------
;define region of interest (ROI)
;------------------------------------------------------



totmap=summaps(ptr,min=minframe,max=maxframe)

IF NOT exist(box) THEN BEGIN ; CONTOUR LEVEL case

    IF NOT exist(lev) THEN lev=0.5

    ;compute total image, and select contour level according to the value
    ;of lev

    data=totmap.data    
    IF keyword_set(negative) THEN $
       q=where(data GT min(data)+lev*(max(data)-min(data))) $
    ELSE $
       q=where(data GT lev*max(data))  

ENDIF $
ELSE BEGIN     ; BOX case

    box2=[[box[0:1]],[box[2:3]]]
    pic=map_coor2pix(transpose(box2),totmap)
    pic=round(transpose(pic))
    dim2=size(totmap.data)

    
    err=1
    xmin=min(pic[*,0])
    IF xmin GT dim2[1]-1. THEN RETURN
    IF xmin LT 0. THEN xmin=0.

    xmax=max(pic[*,0])
    IF xmax LT 0. THEN RETURN
    IF xmax GT dim2[1]-1. THEN xmax=dim2[1]-1.

    ymin=min(pic[*,1])
    IF ymin GT dim2[2]-1. THEN RETURN
    IF ymin LT 0. THEN ymin=0.

    ymax=max(pic[*,1])
    IF ymax LT 0. THEN RETURN
    IF ymax GT dim2[2]-1. THEN ymax=dim2[2]-1.
    err=0

    tmp=totmap.data
    tmp[*,*]=1

    tmp[xmin:xmax,ymin:ymax]=replicate(0,xmax-xmin+1,ymax-ymin+1)
    q=where(tmp LT 0.5)

    
ENDELSE

;----------------------------------------------------------
;generate lightcurve
;----------------------------------------------------------


lc=fltarr(dim[1])
tim=dblarr(dim[1])


IF NOT exist(totalflux) THEN numpix=n_elements(q) $
ELSE numpix=1 ; flux normalization: total <-> average

FOR t=0,dim[1]-1 DO BEGIN       ;time intervals

    IF ptr[t] NE ptr_new() THEN BEGIN 
        lc[t]=total((*ptr[t]).data[q])/numpix

        tim[t]=anytim((*ptr[t]).time)
    ENDIF ELSE $
    BEGIN
        lc[t]=!values.F_NAN 

        tim[t]=!values.F_NAN   
    ENDELSE
ENDFOR
  
lc=lc[where(finite(lc))]   ;
tim=tim[where(finite(tim))]; discard NAN's

out_roi=q

END

















