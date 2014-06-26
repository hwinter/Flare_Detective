;+
; NAME:
;
; pg_brownmod_el
;
; PURPOSE:
;
; model for electron spectra from brown & loran...
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
; 01-JUL-2004 written P.G.
;
;-

FUNCTION pg_brownmodel_el,delta,par,Einj=Einj,Eobs=Eobs

A=par[0]
alpha=par[1]

IF alpha EQ 0. THEN $
  result=A^2*(delta-1)/((delta+0.5)*(delta+0.5))*(einj/eobs)^(delta) $
ELSE $
  result=A^2/(-1+sqrt(1+4*alpha*(delta+0.5)))^2*(2*alpha*sqrt(delta-1))^2 $
         *(einj/eobs)^(delta)

return,result



END
