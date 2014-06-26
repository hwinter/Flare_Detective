;+
; NAME:
;
; pg_gauss_scale
;
; PURPOSE:
;
; return a scaled and shifted gauss function
;
; CATEGORY:
;
; wavelet tools
;
; CALLING SEQUENCE:
;
; res=pg_haar_wavelet(x,xc,width)
;
; INPUTS:
;
; x: the real numeric argument
; xc: center of gaussian
; width: width of gaussian
;
; OPTIONAL INPUTS:
;
; NONE
;
; KEYWORD PARAMETERS:
;
; NONE
;
; OUTPUTS:
;
; 
;
; OPTIONAL OUTPUTS:
;
;
;
; COMMON BLOCKS:
;
;
;
; SIDE EFFECTS:
;
;
;
; RESTRICTIONS:
;
;
;
; PROCEDURE:
;
;
;
; EXAMPLE:
;
;
;
; MODIFICATION HISTORY:
; 
; written 15_MAY-2008 PG 
;
;-
FUNCTION pg_gauss_scale,x,xc=xc,width=width
 
xc=fcheck(xc,0)
width=fcheck(width,1)

sigma=width/sqrt(8*alog(2))
RETURN,exp(-0.5*((x-xc)/sigma)^2)/(sigma*sqrt(2*!PI))

END
