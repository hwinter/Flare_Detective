;+
; NAME:
;      cm2mhz
;
; PURPOSE: 
;      convert wavelength (cm) to frequency (Mhz) for radio waves
;      propagating at c
;  
; CALLING SEQUENCE:
;      f=kel2kev(l)
;
; INPUTS:
;      l: wavelength 
;
; OUTPUT:
;      f: frequency 
;       
; KEYWORDS:
;        
;
; HISTORY:
;       10-OCT-2002 written
;
; COMMENT:
;       f=c/l   c=299'792'458*m*Hz * 100*cm*m^-1 * (0.000001) MHz*Hz^-1  
;       physical constants taken from 1998 CODATA values
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;-

FUNCTION cm2mhz,l

   f=double(29979.2458/l)
   RETURN,f
  
END



