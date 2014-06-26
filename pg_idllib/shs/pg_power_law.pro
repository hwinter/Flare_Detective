;+
; NAME:
;
; pg_power_law
;
; PURPOSE:
;
; simple model for time evolution of the spectra: power-law
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
; 28-JUN-2004 written P.G.
;
;-

FUNCTION pg_power_law,F0,par;,E0=E0

;E0=fcheck(E0,35.)

NORM=par[0]
IND=par[1]

delta=norm*F0^(-ind)

return, delta

END
