;+
; NAME:
;      hsi_background_subtract
;
; PURPOSE: 
;      background subtraction for a spectrogram 
;
; INPUTS:
;      spg: original spectrogram
;      timerange: the selected timerange
;      erange: the selected energy range
;  
; OUTPUTS:
;      returns the background subtracted spg
;      
; KEYWORDS:
;        
;
; HISTORY:
;       15-OCT-2002 written
;       28-APR-2003 corrected a bug in the background normalization
;       18-JUL-2003 now allows other name tag in spg structure
;                   and a check of the time/energy range is also done
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;
;-

FUNCTION hsi_background_subtract,timerange=timerange,erange=erange,spg=spg

IF n_elements(erange) NE 2 THEN erange=[min(spg.y),max(spg.y)] $
ELSE erange=erange[sort(erange)]

IF n_elements(timerange) NE 2 THEN timerange=[min(spg.x),max(spg.x)] $
ELSE timerange=timerange[sort(anytim(timerange))]

timerange=anytim(timerange)
;ptim,timerange

qy=where(spg.y GE erange[0] AND spg.y LE erange[1],county)
qx=where(spg.x GE timerange[0] AND spg.x LE timerange[1],countx)

IF (countx EQ 0 ) OR (county EQ 0) THEN BEGIN
    print,'Wrong time or energy range given'
    RETURN,spg
ENDIF

xx=spg.x[qx]
yy=spg.y[qy]

;a=(size(spg.spectrogram))[1]
;b=(size(spg.spectrogram))[2]
;tmp=fltarr(a,b)
tmp=spg.spectrogram


FOR j=0L,n_elements(yy)-1 DO BEGIN
    bg=0
    FOR i=0L,n_elements(xx)-1 DO bg=bg+tmp[qx[i],qy[j]]
    tmp[*,qy[j]]=tmp[*,qy[j]]-bg/(n_elements(xx));-1 wrong!!!
ENDFOR

spg2=spg
spg2.spectrogram=tmp

RETURN,spg2

END











