;+
;
; NAME:
;        pg_linfit_multilog
;
; PURPOSE: 
;
;        fit a series of straight lines to the log of a set of scatter
;        data for each given index range 
;
; CALLING SEQUENCE:
;
;        result=pg_linfit_multilog(x,y,border_indices [,nolog=nolog)
;    
; 
; INPUTS:
;
;        x,y: scatter data
;        border_indices: array [0..2N] of indices
;
; KEYWORDS:
;        nolog: inhibits the logarithmization of the data before the fit
;                
; OUTPUT:
;        result: structure tbd
;
; CALLS:
;        tbd
;
; EXAMPLE:
; 
;        
;
; VERSION:
;       
;       30-SEP-2003 written
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;-

FUNCTION pg_linfit_multilog,x,y,border_indices,nolog=nolog

n=n_elements(border_indices)/2
x2=x
y2=y

result=replicate({slope:0.,ycut:0.},n)

IF NOT keyword_set(nolog) THEN BEGIN
;    tmp=where(x2 LE 0,xcount)
;    tmp=where(y2 LE 0,ycount)
;    IF xcount GT 0 OR ycount GT 0 THEN RETURN,-1

    x2=alog(x2)
    y2=alog(y2)

ENDIF

FOR i=0,n-1 DO BEGIN
    indarr=border_indices[2*i]+indgen(border_indices[2*i+1] $
          -border_indices[2*i]+1)

    fitx=x2[indarr]
    fity=y2[indarr]

    res=linfit(fitx,fity)
    result[i].slope=res[1]
    result[i].ycut=res[0]

ENDFOR

RETURN,result

END












