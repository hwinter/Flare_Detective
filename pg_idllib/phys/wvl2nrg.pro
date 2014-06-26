;+
; NAME:
;      WVL2NRG
;
; PURPOSE: 
;      convert wavelengths (Angstroms) to energies (keV)
;
; CALLING SEQUENCE:
;      wvl2nrg(l)
;
; INPUTS:
;      l: wavelength in Angstroms
;
; OUTPUT:
;      energy in keV       
;       
; KEYWORDS:
;      none  
;
; COMMENT:
;       uses Planck constant: h=4.13566727 10^-15 eV s 
;            light velocty:   c=299792458 m s^-1
;       e=hc/l * 10^10 (A/m) * 0.001 (keV/eV)
;       physical constants taken from 1998 CODATA values
;       
;
; VERSION:
;       1.1 01-OCT-2002
; HISTORY:
;       09-JUL-2002 written
;       01-OCT-2002 changed conversion factor slightly
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;-

FUNCTION WVL2NRG,l

   e=double(12.39841856d/l)
   RETURN,e 
  
END



