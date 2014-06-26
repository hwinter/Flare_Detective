;+
; NAME:
;      f_pg_fbar_genexp
;
; PURPOSE: 
;      gives the photon spectrum foran fbar electron spectrum
;      with the shape of a generalized exponential, in a form
;      suitable to be used with OSPEX
;
; CALLING SEQUENCE:
;      f_pg_plotgoes,e,params
;
; INPUTS:
;      e: [2,nbins] energy edges
;      params: an array of 3 parameters:
;                  params[0]: is N, the normalization
;                  params[1]: is T, the (generalized) temperature
;                  params[2]: is q, the "entropic index"
;
; KEYWORDS:
;      none
;
; OUTPUT:
;      photon spectrum at earth, in units of [...]
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

FUNCTION f_pg_fbar_genexp,e,params,_extra=_extra

;e are energy edges...
edge_products,e,mean=emean

nenbins=n_elements(emean)
intval=fltarr(nenbins)

inf=!values.f_infinity

fname='pg_fbar_integrand'

FOR i=0,nenbins-1 DO BEGIN
   intval[i]=QPINT1D(fname, emean[i], inf, params,functargs={low_limit:emean[i]})
ENDFOR

return,intval/emean;need to divide by eph!

END
