;+
; NAME:
;
; pg_constel_mod
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
; fluxnorm=pg_constel_mod(delta,par)
;
; INPUTS:
;
; delta: electron spectral index
; par: array of [einj,ftot,enorm]
;                einj:  energy above which the electron injection rate
;                       is constant
;                ftot:  total constant electron flux
;                enorm: normalization energy
; inverse: if set, return the inverse function instead
; 
; OUTPUTS:
;
; fluxnorm: photon flux at normalization energy
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
;
;-

FUNCTION pg_constel_mod,delta,par,help=help,inverse=inverse

IF keyword_set(help) THEN BEGIN
   print,"CALLING SEQUENCE:"
   print,"fluxnorm=pg_constel_mod(delta,par)"
   print,"INPUTS:"
   print,"delta: electron spectral index"
   print,"par: array of [einj,ftot,enorm]"
   print,"     einj:  energy above which the electron injection rate"
   print,"            is constant"
   print,"     ftot:  total constant electron flux"
   print,"     enorm: normalization energy"
   RETURN,-1
ENDIF



einj=par[0]
ftot=par[1]
enorm=par[2]

IF keyword_set(inverse) THEN BEGIN
   influx=delta
   N=1001
   indelta=findgen(N)/(N-1)*15.+3.
   outflux=pg_constel_mod(indelta,par)
   
   result=interpol(indelta,outflux,influx)

   RETURN,result

ENDIF $
ELSE BEGIN

   fluxnorm=(delta-1)/einj*ftot*(enorm/einj)^(-delta)
   RETURN, fluxnorm

ENDELSE






END
