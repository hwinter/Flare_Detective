;+
;
; NAME:
;        map_circle_oplot
;
; PURPOSE: 
;        overplot circles on a map
;
; CALLING SEQUENCE:
;
;        map_circle_oplot,x,y,r,rmin=rmin,rmax=rmax
; 
;
; INPUTS:
;
;        x,y: array of positions
;        r: array of radii
;        rmin,rmax: min and max radius
;
; KEYWORDS:
;       
;                
; OUTPUT:
;        
; CALLS:
;
; VERSION:
;       
;        07-JUL-2003 written
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;-

PRO map_circle_oplot,x,y,r,rmin=rmin,rmax=rmax,color=color,dmin=dmin,dmax=dmax

IF NOT keyword_set(rmin) THEN rmin=0
IF NOT keyword_set(rmax) THEN rmax=max(r)

IF NOT keyword_set(dmin) THEN dmin=min(r)
IF NOT keyword_set(dmax) THEN dmax=max(r)


IF NOT exist(color) THEN color=replicate(!P.color,n_elements(x))

FOR i=0,n_elements(x)-1 DO BEGIN
    tvcircle,(r[i]-dmin)/dmax*(rmax-rmin)+rmin,x[i],y[i],color[i],/data
ENDFOR

END





