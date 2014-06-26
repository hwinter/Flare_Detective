;+
; NAME:
;      pg_fbar_integrand
;
; PURPOSE: 
;      returns the integrand used by f_pg_fbar_genexp
;
; CALLING SEQUENCE:
;      pg_fbar_integrand,e,params
;
; INPUTS:
;      e: energy, formally the independent parameter
;      params: an array of 3 parameters for the general exponential:
;                  params[0]: is N, the normalization
;                  params[1]: is T, the (generalized) temperature
;                             (same unit as the energy)
;                  params[2]: is q, the "entropic index"
;
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

FUNCTION pg_fbar_integrand,e,params,low_limit=low_limit

;stop

res=sqrt(e)*pg_expq(e,params)/e*pg_brem_red_crosssec(low_limit,e)

return,res

END
