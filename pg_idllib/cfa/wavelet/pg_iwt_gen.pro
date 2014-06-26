;+
; NAME:
;
; pg_iwt_gen
;
; PURPOSE:
;
; return the general Integral Wavelet Transform (see EQ. 1.1.18 of CHUI, An
; Introduction to Wavelets)
;
; CATEGORY:
;
; wavelet tools
;
; CALLING SEQUENCE:
;
; res=pg_iwt_gen(y,j,k,wavfunc=wavfunc)
;
; INPUTS:
;
; y: the signal to be transformed
; wavfunc: the wavelet function name
; j: scaling parameter 
; k: translation parameter 
;
; OPTIONAL INPUTS:
;
; x: the ascisaa for y. If not given, a regular grid is used with width=1
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
; Computes the integral of y times wavfunc((x-b)/a))
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

FUNCTION pg_iwt_gen,y,j,k,x=x,wavfunc=wavfunc

ny=n_elements(y)

IF n_elements(x) NE ny THEN x=findgen(ny)-ny/2
IF n_elements(wavfunc) EQ 0 THEN wavfunc='pg_haar_wavelet'

res= int_tabulated(x,y*call_function(wavfunc,x,j,k),/double)/sqrt(abs(2d^(-j)))

RETURN,res

END
