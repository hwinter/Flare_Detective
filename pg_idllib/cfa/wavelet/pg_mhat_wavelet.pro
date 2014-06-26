;+
; NAME:
;
; pg_haar_scale
;
; PURPOSE:
;
; return the Mexican hat wavelet function
;
; CATEGORY:
;
; wavelet tools
;
; CALLING SEQUENCE:
;
; res=pg_haar_wavelet(x,j,k)
;
; INPUTS:
;
; x: the real numeric argument
; j: scaling index of the function
; k: translation index of the function
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
FUNCTION pg_mhat_wavelet,x,j,k,normalized=normalized
 
IF n_elements(j) EQ 0 THEN j=0
IF n_elements(k) EQ 0 THEN k=0

res=x*0

IF keyword_set(normalized) THEN nfact=2d^(0.5*j) ELSE nfact=1d

IF j EQ 0 AND k EQ 0 THEN BEGIN 

   res=(x*x-1)*exp(-0.5*x*x)

ENDIF $ 
ELSE res=nfact*pg_haar_wavelet(2d^j*x-k,0,0)

RETURN,res

END
