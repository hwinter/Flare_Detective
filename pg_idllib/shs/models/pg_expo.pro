;+
; NAME:
;
; pg_expo
;
; PURPOSE:
;
; simple model: delta= A*exp(-B*flux)
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

FUNCTION pg_expo,fnorm,par,getparnames=getparnames

IF keyword_set(getparnames) THEN RETURN,['A','B'] 

A=par[0]
B=par[1]

result=A*exp(B/fnorm)

RETURN,result

END
