;+
; NAME:
;      kev2kel
;
; PURPOSE: 
;      convert energy (keV) to temperature (Kelvin)
;
; INPUTS:
;      e: energy in keV  
;
; OUTPUT:
;      t: temperature in Kelvin 
;       
; KEYWORDS:
;        
;
; HISTORY:
;       12-JUL-2002 written
;       16-JUL-2002 changed the conversion factor slightly
;
; COMMENT:
;       e=k_b *t --> t=k_b^-1 *e  k_b=Boltzmann constant
;                                 k_b=8.617342(15)*10^-5 eV K^-1
;       physical constants taken from 1998 CODATA values
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;-

FUNCTION kev2kel,e

   t=double(11604506d*e)
   RETURN,t
  
END



