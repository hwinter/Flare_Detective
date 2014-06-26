;+
; NAME:
;      pg_expq
;
; PURPOSE: 
;      returns a generalized exponential with index q,
;      if q=1 the normal exponential is returned
;
;      formula:  f(E) = N*exp(-E/T) (q=1)
;                f(E,q) = N * (1 - (1-q)*E/T) ^(q/(1-q))
;
;      1-dimensional case--> 3 dimensional get a v^2dv=sqrt(E)dE
;      factor
;      this is the density per keV (= number of electrons cm^-3 keV^-1) 
;
; CALLING SEQUENCE:
;      pg_expq,e,params
;
; INPUTS:
;      e: energy, formally the independent parameter
;      params: an array of 3 parameters:
;                  params[0]: is N, the normalization
;                  params[1]: is T, the (generalized) temperature
;                             (same unit as the energy)
;                  params[2]: is q, the "entropic index"

;
; KEYWORDS:
;      
;
; OUTPUT:
;      
;       
;
; COMMENT:
;
;
; EXAMPLE   
;
;
;
; VERSION:
;       28-SEP-2005 written PG
;       
; AUTHOR:
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;-

FUNCTION pg_expq,e,params

N=params[0]
T=params[1]
q=params[2]

IF q NE 1. THEN BEGIN 
   res=N*(1-(1-q)*e/T)^(q/(1-q))*sqrt(e)
ENDIF ELSE BEGIN 
   res=N*exp(-E/T)*sqrt(e)
ENDELSE


RETURN,res

END
