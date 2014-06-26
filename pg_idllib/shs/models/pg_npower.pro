;+
; NAME:
;
; pg_npower
;
; PURPOSE:
;
; simple model: delta= N ^ (-alpha)
;
; CATEGORY:
;
; shs project util
;
; CALLING SEQUENCE:
;
; delta=
;
; INPUTS:
;
; fnorm: flux normalization at ENORM
; par: array of [EINJ,ALPHA,A,ENORM]
;                EINJ:  energy above which the electron injection rate
;                       is constant
;                ....
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
; 30-AUG-2004 written P.G.
;
;-

FUNCTION pg_npower,fnorm,par,getparnames=getparnames

IF keyword_set(getparnames) THEN RETURN,['EINJ','ALPHA','A','ENORM'] 

einj=par[0]
alpha=par[1]
a=par[2]
enorm=par[3]


   influx=fnorm

   N=1001
   indelta=findgen(N)/(N-1)*15.+3.

   outflux=A*(indelta-1)/enorm*indelta^(alpha)*(einj/enorm)^(indelta)
   
   result=interpol(indelta,outflux,influx)

   RETURN,result


END
