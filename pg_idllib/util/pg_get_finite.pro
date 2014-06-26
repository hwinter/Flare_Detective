;+
; NAME:
;   pg_get_finite
;
; PURPOSE:
;   return the finite elements of the input array
;
; CALLING SEQUENCE:
;
;   y=pg_get_finite(x)
;
; INPUT: 
;   x: an array of floats or doubles
;
; OUTPUT:
;   y: array of the same type as x
;
; KEYWORDS:
;  
;
; HISTORY:
;   written 24-JAN-2005
;
; AUTHOR:
; Paolo Grigis, ETH Zurich
; pgrigis@astro.phys.ethz.ch
;  
;-


FUNCTION pg_get_finite,x

ind=where(finite(x),count)

IF count EQ 0 THEN BEGIN
   print,'WARNING! No finite elements in array x'
   RETURN,-1
ENDIF

RETURN,x[ind]

END

