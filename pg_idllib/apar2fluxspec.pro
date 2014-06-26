;+
; NAME:
;       apar2fluxspec
;
; PURPOSE: 
;       convert apar array from spex to flux, spectral index
;       for the second part of the power_law
;
; CALLING SEQUENCE:
;       out=apar2fluxspec(apar_arr)
;
; INPUTS:
;
;       apar_arr: form spex
;
; OUTPUTS:
;
;       out: [flux,spec]
;       
; KEYWORDS:
;       
;
; EXAMPLE:
;       
;
; VERSION:
;       
; HISTORY:
;       15-SEP-2003 written
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;-

FUNCTION apar2fluxspec,apar_arr,en=en

IF NOT exist(en) THEN en=45.

flux_0=apar_arr[2,*]

ep=50. ;'pivot' energy, usually 50 keV (from spex EPIVOT)

eb=apar_arr[4,*]; break energy

d1=apar_arr[3,*]; power law above break

d2=apar_arr[5,*]; power law under break



flux=flux_0*(ep/eb)^d1*(eb/en)^d2

RETURN,[flux,d2]

END






