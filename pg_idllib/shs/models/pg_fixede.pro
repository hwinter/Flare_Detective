;+
; NAME:
;
; pg_fixede
;
; PURPOSE:
;
; simple model: total electron energy (per sec.) = constant
;
; CATEGORY:
;
; shs project util
;
; CALLING SEQUENCE:
;
; delta=pg_fixedn(fnorm,par)
;
; INPUTS:
;
; fnorm: flux normalization at ENORM
; par: array of [EINJ,ETOT,ENORM]
;                EINJ:  energy above which the electron injection rate
;                       is constant
;                ETOT:  total (constant) electron energy (per sec)
;                ENORM: normalization energy
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
; 26-AUG-2004 written P.G.
;
;-

FUNCTION pg_fixede,fnorm,par,getparnames=getparnames

IF keyword_set(getparnames) THEN RETURN,['EINJ','ETOT','ENORM'] 

einj=par[0]
etot=par[1]
enorm=par[2]


   influx=fnorm

   N=1001
   indelta=findgen(N)/(N-1)*15.+3.

   outflux=(indelta-2)/(einj^2)*etot*(enorm/einj)^(-indelta)
   
   result=interpol(indelta,outflux,influx)

   RETURN,result


END
