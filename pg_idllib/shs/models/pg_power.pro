;+
; NAME:
;
; pg_power
;
; PURPOSE:
;
; simple model: delta= A*flux^(-B)
;
; CATEGORY:
;
; shs project util
;
; CALLING SEQUENCE:
;
; delta=
;
; INPUTS:
;
; fnorm: flux normalization at ENORM
; par: array of [A,B]
;               
; 
; OUTPUTS:
;
; delta: spectral index
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
; EXAMPLE:
;
;
;
; AUTHOR:
;
; Paolo Grigis, Institute of Astronomy, ETH Zurich
; pgrigis@astro.pyhs.ethz.ch
; 
; MODIFICATION HISTORY:
;
; 30-AUG-2004 written P.G.
;
;-

FUNCTION pg_power,fnorm,par,getparnames=getparnames

IF keyword_set(getparnames) THEN RETURN,['A','B'] 

A=par[0]
B=par[1]

result=A*fnorm^B

RETURN,result

END
