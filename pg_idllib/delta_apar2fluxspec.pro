;+
; NAME:
;       delta_apar2fluxspec
;
; PURPOSE: 
;       convert apar_sigma array from spex to delta_flux, delta_spectral index
;       for the second part of the power_law
;
; CALLING SEQUENCE:
;       out=delta_apar2fluxspec(apar_arr,apar_sigma)
;
; INPUTS:
;
;       apar_arr,apar_sigma : form spex
;
; OUTPUTS:
;
;       out: [delta_flux,delta_spec]
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
;       16-SEP-2003 written
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;-

FUNCTION delta_apar2fluxspec,apar_arr,apar_sigma,en=en

IF NOT exist(en) THEN en=35.

flux_0=apar_arr[2,*]
delta_flux0=apar_sigma[2,*]

ep=50. ;'pivot' energy, usually 50 keV (from spex EPIVOT)

eb=apar_arr[4,*]; break energy
delta_eb=apar_sigma[4,*]


d1=apar_arr[3,*]; power law above break
delta_d1=apar_sigma[3,*]

d2=apar_arr[5,*]; power law under break
delta_d2=apar_sigma[5,*]


flux=flux_0*(ep/eb)^d1*(eb/en)^d2

delta_flux=flux*sqrt((delta_flux0/flux0)^2 + $
                     alog(d2)^2*delta_d2^2+alog(d1)^2*delta_d1^2 + $
                     (delta_eb/eb)^2*(d2-d1)^2)

RETURN,[delta_flux,delta_d2]

END






