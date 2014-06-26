;+
; NAME:
;
; pg_fixedn
;
; PURPOSE:
;
; simple model: electron acceleration rate = constant
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
; par: array of [EINJ,FTOT,ENORM]
;                EINJ:  energy above which the electron injection rate
;                       is constant
;                FTOT:  total (constant) electron flux above EINJ
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
; 17-AUG-2004 written P.G.
; 20-AUG-2004 added inverse functionality P.G.
; 24-AUG-2004 uniformed to standard notation for electron models... 
;             and made /inverse the defaultP.G.
;-

FUNCTION pg_fixedn,fnorm,par,getparnames=getparnames

IF keyword_set(getparnames) THEN RETURN,['EINJ','FTOT','ENORM'] 

einj=par[0]
ftot=par[1]
enorm=par[2]

;IF keyword_set(inverse) THEN BEGIN

   influx=fnorm

   N=1001
   indelta=findgen(N)/(N-1)*15.+3.

   outflux=(indelta-1)/einj*ftot*(enorm/einj)^(-indelta)
   
   result=interpol(indelta,outflux,influx)

   RETURN,result

;ENDIF $
;ELSE BEGIN

;   fluxnorm=(delta-1)/einj*ftot*(enorm/einj)^(-delta)
;   RETURN, fluxnorm

;ENDELSE

END
