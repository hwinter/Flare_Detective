;+
; NAME:
;      pg_num_diff
;
; PROJECT:
;      numeric utils
;
; PURPOSE: 
;      returns the numerical first derivative of y
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
FUNCTION pg_num_diff,y=yin,x=xin

IF n_elements(xin) NE n_elements(yin) THEN BEGIN 
   print,'Please input x and y with the same number of elements'
   RETURN,-1
ENDIF

n=n_elements(yin)

xplus=shift(xin,-1)
xminus=shift(xin,1)
yplus=shift(yin,-1)
yminus=shift(yin,1)

res=0.5*((yplus-yin)/(xplus-xin)+(yin-yminus)/(xin-xminus));average of left and right derivative

res[0]=(yin[1]-yin[0])/(xin[1]-xin[0]);fixes edges with 1 sided derivative
res[n-1]=(yin[n-1]-yin[n-2])/(xin[n-1]-xin[n-2]);

return,res

END
