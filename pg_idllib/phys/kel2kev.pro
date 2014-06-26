;+
; NAME:
;      kel2kev
;
; PURPOSE: 
;      convert temperature (Kelvin) to energy (keV)
;
; CALLING SEQUENCE:
;      e=kel2kev(t)
;
; INPUTS:
;      t: temperature in Kelvin 
;
; OUTPUT:
;      e: energy in keV 
;       
; KEYWORDS:
;        
;
; HISTORY:
;       12-JUL-2002 written
;       30-SEP-2002 changed the conversion factor slightly
;
; COMMENT:
;       e=k_b *t   k_b=Boltzmann constant
;                  k_b=8.617342(15)*10^-5 eV K^-1
;       physical constants taken from 1998 CODATA values
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;-

FUNCTION kel2kev,t

   e=double(8.617342d-8*t)
   RETURN,e 
  
END



