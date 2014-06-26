;+
; NAME:
;
; pg_brown
;
; PURPOSE:
;
; returns the electron spectral index delta as a function of the
; electron flux F0 as in the model by Brown & Loran (1985) but
; modified to provide parameters for *electron* spectra instead than
; photon spectra. The routine sintax allow it to be used as an input
; function for the MPFIT family of fitting routines by C. Markwardt
; [this version has a syntax compatible with the other models in dis dir]
;
;
; CATEGORY:
;
; shs project util, spex util
;
; CALLING SEQUENCE:
;
; delta=pg_brown(flux,parm)
;
; INPUTS:
;
; flux: electron flux at ENORM in the target (electron s^-1 keV^-1)
; parms: an float or double array [A,alpha,einj,enorm]
;               P: normalization parameter (asssumed >= 0)
;               alpha: Coulomb collisional depth (assumed >= 0)
;               einj: energy (E* in Brown & Loran) above which the electron are
;                     accelerated and distribited according to a powr-law
;               enorm: normalization energy for the electron flux
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
; 25-AUG-2004 uniformated to syntax of the others models
; 26-AUG-2004 made sure input parameters are converted to doubles to
;             avoid overflows
;-

FUNCTION pg_brown,flux,par,getparnames=getparnames

IF keyword_set(getparnames) THEN return,['P','ALPHA','EINJ','ENORM']

P=double(par[0])
alpha=double(par[1])
einj=double(par[2])
enorm=double(par[3])


N=1001
delta=findgen(N)/(N-1)*10+2

result=P^2*(delta-1)*((1+sqrt(1+4*alpha*(delta+0.5)))/(2*(delta+0.5)))^2 $
       *((einj/enorm)^delta)/einj


realdelta=interpol(delta,result,flux)

return,realdelta

END
