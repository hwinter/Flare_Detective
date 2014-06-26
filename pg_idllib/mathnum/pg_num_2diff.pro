;+
; NAME:
;      pg_num_2diff
;
; PROJECT:
;      numeric utils
;
; PURPOSE: 
;      returns the numerical second derivative of y
;      
;
; CALLING SEQUENCE:
;     
;      diffy=pg_num_diff(y=y,x=x)
;
; INPUTS:
;
;      y: array of y values
;      x: array of x values
;
; OUTPUTS:
;      diffy: the numerical first derivative
;      
; KEYWORDS:
;
;
; HISTORY:
;       27-JUL-2005 written PG
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;
;-
FUNCTION pg_num_2diff,y=yin,x=xin

IF n_elements(xin) NE n_elements(yin) THEN BEGIN 
   print,'Please input x and y with the same number of elements'
   RETURN,-1
ENDIF

n=n_elements(yin)

xplus=shift(xin,-1)
xminus=shift(xin,1)
yplus=shift(yin,-1)
yminus=shift(yin,1)

res=2*((yplus-yin)/(xplus-xin)-(yin-yminus)/(xin-xminus))/(xplus-xminus);average of left and right derivative

res[0]=res[1];fixes edges (don't extrapolate anything for now)
res[n-1]=res[n-2];

return,res

END
