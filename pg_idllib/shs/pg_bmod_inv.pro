;+
; NAME:
;
; pg_bmod_inv
;
; PURPOSE:
;
; returns the electron spectral index delta as a function of the
; electron flux F0 as in the model by Brown & Loran (1985) but
; modified to provide parameters for *electron* spectra instead than
; photon spectra. The routine sintax allow it to be used as an input
; function for the MPFIT family of fitting routines by C. Markwardt
;
; CATEGORY:
;
; shs project util, spex util
;
; CALLING SEQUENCE:
;
; delta=pg_bmod_inv(flux,parm,einj=einj,eobs=eobs)
;
; INPUTS:
;
; flux: electron flux at E=eobs in the target (electron s^-1 keV^-1)
; parms: an float or double array [A,alpha,einj]
;               A: normalization parameter (asssumed >= 0)
;               alpha: Coulomb collisional depth (assumed >= 0)
;               einj: energy (E* in Brown & Loran) above which the electron are
;                     accelerated and distribited according to a powr-law
; eobs: observed electron energy
; 
; OUTPUTS:
;
; delta: electron spectral index
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
; computes first flux as a function of delta for delta in the range
; [2..12] and the uses numerical inversion for getting delta as a
; function of flux (that is, interpolation is used)
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
; 05-JUL-2004 corrected bug which caused incorrect answers for
;             alpha not equal 0 and improved documentation
;
;-

FUNCTION pg_bmod_inv,flux,par,eobs=eobs

A=par[0]
alpha=par[1]
einj=par[2]

delta=findgen(1001)/1000*10+2

result=A^2*(delta-1)*((1+sqrt(1+4*alpha*(delta+0.5)))/(2*(delta+0.5)))^2 $
       *((double(einj)/eobs)^delta)/einj

realdelta=dindgen(n_elements(flux))
FOR i=0,n_elements(flux)-1 DO BEGIN
   realdelta[i]=interpol(delta,result,flux[i])
ENDFOR

return,realdelta

END
