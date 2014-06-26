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
; 
;
; INPUTS:
;
; 
; 
; OUTPUTS:
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
; AUTHOR:
;
; Paolo Grigis, Institute of Astronomy, ETH Zurich
; pgrigis@astro.pyhs.ethz.ch
; 
; MODIFICATION HISTORY:
;
; 22-JUN-2004 written P.G.
;
;-

FUNCTION pg_pivot_model,F0,par,E0=E0

E0=fcheck(E0,35.)

Fpiv=par[0]
Epiv=par[1]

delta=alog(Fpiv/F0)/alog(E0/Epiv)

return, delta

END
