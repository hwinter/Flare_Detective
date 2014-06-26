;+
; NAME:
;
; pg_pivot_model
;
; PURPOSE:
;
; simple model for time evolution of the spectra: fixed pivot point
; to use with mpfitfun
;
; CATEGORY:
;
; shs project util, spex util
;
; CALLING SEQUENCE:
;
; delta=pg_pivpoint(fnorm,[fpiv,epiv,enorm])
;
; INPUTS:
;
; fnorm: normalization of the flux at ENORM (can be an array)
; par: array of 
;             - FPIV: flux at the pivot point  
;             - EPIV: energy of the pivot point
;             - ENORM: normalization energy
;
;
; KEYWORDS:
;
; getparnames: if set, returns the parameter names
; 
; OUTPUTS:
;
; delta corresponding to the input fnorm 
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
; AUTHOR:
;
; Paolo Grigis, Institute of Astronomy, ETH Zurich
; pgrigis@astro.pyhs.ethz.ch
; 
; MODIFICATION HISTORY:
;
; 22-JUN-2004 written P.G.
; 24-AUG-2004 uniformed to standard notation for electron models...
;
;-

FUNCTION pg_pivpoint,fnorm,par,getparnames=getparnames

IF keyword_set(getparnames) THEN RETURN,['FPIV','EPIV','ENORM']

fpiv=par[0]
epiv=par[1]
enorm=par[2]

delta=alog(fpiv/fnorm)/alog(enorm/epiv)

return, delta

END
