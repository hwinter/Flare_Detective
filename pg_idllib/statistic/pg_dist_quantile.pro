;+
; NAME:
;      pg_distquantile
;
; PURPOSE: 
;      given an input array of values x and a number d between 0 and
;      1, returns the value for which a fraction d of elements of x
;      are below that value. For d=0.5 the median is returned. 
;
;
; CALLING SEQUENCE:
;
;      res=pg_dist_quantile,x,d
;
; INPUTS:
;            
;      x: float or double array
;      d: real number between 0 and 1 (can be an array too)
;
; OUTPUTS:
;      
;      
; KEYWORDS:
;      
;
; HISTORY:
;
;      05-JAN-2005 written
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;
;-

FUNCTION pg_dist_quantile,x,d

IF (min(d) LT 0) OR (max(d) GT 1) THEN BEGIN
   print,'Invalid d'
   RETURN,-1
ENDIF

xx=float(x[sort(x)])

n=n_elements(xx)-1

res=interpolate(xx,d*n)

return,res

END
