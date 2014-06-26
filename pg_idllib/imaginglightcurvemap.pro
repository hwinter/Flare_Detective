;+
;
; NAME:
;       imaginglightcurvemap
;
; PROJECT: 
;       vls/rhessi
;
; PURPOSE: 
;       plot lightcurves of selected regions
;
; CALLING SEQUENCE:
;       
;
; INPUTS:
;       ptrim: array of pointer to map structures
;
; OUTPUT:
;       by keywords
;       
; KEYWORDS:
;       lc,tim: lightcurve & time array 
;       roi: array of pointers to arrays with pixel positions of the ROI
;
; EXAMPLE:
;        
;        imaginglightcurvemap,...
;
; VERSION:
;       11-NOV-2002 written
;       13-NOV-2002 imported in rapp_idl
;       26-NOV-2002 converted to use with maps
;       28-NOV-2002 check for null pointer before doing anything
;
; COMMENT:
;       the idea is the following: for each image sequence and energy
;       interval find the time interval with the brightest pixel,
;       (or pixel region, say 2x2 or 4x4 -->not yet used),
;       define the region with (frmax)% of max flux there,
;       compute lightcurve for this region (ROI)
;
;       
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;-

PRO imaginglightcurvemap,ptrim,lc=lc,tim=tim,maxfr=maxfr,roi=roi

;IF NOT exist(ptrim) THEN BEGIN


;ENDIF


;-------------------------------------------------
; find max in the sequence
;-------------------------------------------------

dim=size(ptrim)

maxim=0

FOR t=0,dim[1]-1 DO BEGIN       ;time intervals
    IF ptrim[t] NE ptr_new() THEN BEGIN
        IF max((*ptrim[t]).data) GT maxim THEN BEGIN
            maxim=max((*ptrim[t]).data)
            maxtime=t
        ENDIF
    ENDIF
ENDFOR



;------------------------------------------------------
;define region of interest (ROI)
;------------------------------------------------------


IF NOT exist(maxfr) THEN maxfr=0.5

low=0
WHILE ptrim[low] EQ ptr_new() DO low=low+1
 


IF NOT exist(roi) THEN BEGIN
    data=(*ptrim[low]).data
    FOR i=low,dim[1]-1 DO BEGIN
        IF ptrim[i] NE ptr_new() THEN $
        data=data+(*ptrim[i]).data
    ENDFOR


    q=ptr_new(where2(data GT maxfr*max(data)))  

    roi=q

;q gives the ROI

ENDIF ELSE q=roi


;----------------------------------------------------------
;generate lightcurve
;----------------------------------------------------------

lc=fltarr(dim[1])
tim=dblarr(dim[1])


maxim=0

numpix=(size(*roi))[2]

FOR t=0,dim[1]-1 DO BEGIN       ;time intervals

    IF ptrim[t] NE ptr_new() THEN BEGIN 
        lc[t]=total((*ptrim[t]).data[(*q)[0,*],(*q)[1,*]])/numpix

        tim[t]=anytim((*ptrim[t]).time)
    ENDIF ELSE $
    BEGIN
        lc[t]=!values.F_NAN 

        tim[t]=!values.F_NAN   
    ENDELSE
ENDFOR
  
lc=lc[where(finite(lc))]
tim=tim[where(finite(tim))]

END






















