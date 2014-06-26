;+
; NAME:
;
; pg_sp_ecutoff_thick
;
; PURPOSE:
;
; spectral model: represent the photon spectrum given by an injected electron
; spectrum which is a powerlaw above ecutoff and 0 below ecutoff
;
; CATEGORY:
;
; rhessi spectrograms/fitting util
;
; CALLING SEQUENCE:
;
; spectrum=pg_sp_ecutoff_thick(elenergy=elenergy,phenergy=phenergy
;                             ,delta=delta,f50=f50,ecutoff=ecutoff)
;
; INPUTS:
;
;  elenergy: array of electron energies (in keV)
;  phenergy: array of photon energies (in keV)
;  delta: spectral index of the injected electron spectrum
;  f50: normalization at 50 keV of the power-law, in units of 
;       electrons s^-1 keV^-1 impinging on the whole target
;
; OPTIONAL INPUTS:
;
;
;
; KEYWORD PARAMETERS:
;
; 
;
; OUTPUTS:
;
; photsp: photon spectrum at 1 AU
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
; AUTHOR:
; Paolo Grigis, Institute for Astronomy, ETH Zurich
; pgrigis@astro.phys.ethz.ch 
;
; MODIFICATION HISTORY:
;
; 18-JUL-2006 pg written
;-

;.comp pg_sp_ecutoff_thick

PRO pg_sp_ecutoff_thick_test

  n=1000
  elenergy=10^(4*findgen(n)/(n-1))

  n2=100
  phenergy=10^(2*findgen(n)/(n-1))

  delta=8.
  f50=1d33
  ecutoff=20

  ph=pg_sp_ecutoff_thick(elenergy=elenergy,phenergy=phenergy $
                            ,delta=delta,f50=f50,ecutoff=ecutoff)
  ph2=pg_sp_ecutoff_thick(elenergy=elenergy,phenergy=phenergy $
                            ,delta=delta,f50=f50,ecutoff=ecutoff,/turnover)


  plot,phenergy,ph,/xlog,/ylog
  oplot,phenergy,ph2,linestyle=2

END


FUNCTION pg_sp_ecutoff_thick,elenergy=elenergy,phenergy=phenergy $
                            ,delta=delta,f50=f50,ecutoff=ecutoff $
                            ,turnover=turnover



  elspectrum=f50*(elenergy/50.)^(-delta)

  ind = where(elenergy LT ecutoff, count)

  IF count GT 0 THEN BEGIN 
     elspectrum[ind]=0
     IF keyword_set(turnover) THEN elspectrum[ind]=f50*(ecutoff/50.)^(-delta)
  ENDIF ELSE BEGIN 
     elspectrum[*]=0
     IF keyword_set(turnover) THEN elspectrum[*]=f50*(ecutoff/50.)^(-delta)
  ENDELSE


  photsp=pg_el2phot_thick(elsp=elspectrum,ele=elenergy,phe=phenergy, $
                          surfacetar=1.)

  return,photsp



END
