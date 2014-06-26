;+
; NAME:
;
; pg_ecut_compenergy
;
; PURPOSE:
;
; computes the total energy (and, optionally, particle number) in an electron
; spectrum with a low energy cutoff (or turnover)
;
; CATEGORY:
;
; spectral utility
;
; CALLING SEQUENCE:
;
; energy=pg_ecut_compenergy(fnorm,delta,ecut [,enorm=enorm,/trunover])
;
; INPUTS:
;
; fnorm: electron flux (electron s^-1 keV^-1) at enorm
; delta: electron spectral index (should be a number < -1)
; ecut: cutoff energy
;
; OPTIONAL INPUTS:
;
; enorm: normalization energy (default: 50. keV)
;
; KEYWORD PARAMETERS:
;
; turnover: if set, then a turnover spectrum rather than cutoff is used
;           this means that the electron flux is below the cutoff energy is constant. 
;
;
; OUTPUTS:
;
; energy: total energy (in erg)
; pnumber: the particle number
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
; AUTHOR:
;
; Paolo Grigis, pgrigis@astro.phys.ethz.ch
;
; MODIFICATION HISTORY:
;
; 23-JUL-2007 written PG 
;
;-

;.comp pg_ecut_compenergy

FUNCTION pg_ecut_compenergy,fnorm,delta,ecut,enorm=enorm $
                           ,turnover=turnover,pnumber=pnumber


  enorm=fcheck(enorm,50.)


     res_intermed=-fnorm*(ecut/enorm)^(delta)

     pnumber=res_intermed*ecut/(delta+1)

     energy=res_intermed*ecut*ecut/(delta+2)
     
  IF keyword_set(turnover) THEN BEGIN 

     pnumber=pnumber-ecut*res_intermed
     energy=energy-0.5*res_intermed*ecut*ecut

  ENDIF


  return,energy*1.60217653d-9;convert keV in erg


END


