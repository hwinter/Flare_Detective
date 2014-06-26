;+
;
; NAME:
;       Flux model of a thermal bremsstrahlung plus double broken power-law
;
; PURPOSE:
;       This function returns the differential photon spectrum seen at the Earth
;       for a two component model comprised of an optically thin thermal bremsstrahlung
;       function normalized to the Sun-Earth distance plus a non-thermal broken power-law
;       function normalized to the incident flux on the detector.
;
; CATEGORY
;
; CATEGORY:
;       SPECTRA, XRAYS
;
; CALLING SEQUENCE:
;       Flux = F_VTH_BPOW( E, A )
;
; CALLS:
;       F_VTH, F_BPOW, EDGE_PRODUCTS, CHECKVAR
;
; INPUTS:
;       E -energy vector in keV, 2XN edges or N mean energies
;       A -model parameters defined below
;       For the thermal function using F_VTH.PRO:
;         a(0)= emission measure in units of 10^49 cm-3
;         a(1)= KT       plasma temperature in keV
;
;
;       For the "non-thermal" function it uses the broken power law function, F_BPOW.PRO:
;         a(2) - normalization of broken power-law at Epivot (usually 50 keV)
;         a(3) - negative power law index below break 1
;         a(4) - break 1 energy
;         a(5) - negative power law index above break 1
;         a(6) - second break energy
;         a(7) - negative power law index above second break
;         a(8) - low energy cutoff for power-law, spectrum goes as E^(-1.5)
;         a(9) - spectral index below cutoff between -1.5 and -2.0
;         default parameters - a(6) and a(7) default to 10 keV and -1.5
;         can be overwritten by values in common function_com
;
; COMMON BLOCKS:
;       FUNCTION_COM
;
; HISTORY:
;       VERSION 1, RAS, ~1991
;       VERSION 2, RAS, MAY 1996, FULLY DOCUMENTED
;       Version 3, ras, 26-oct-2002, pass 2xn format for e to f_vth
;-
function pg_f_vth_tpow, e, a

if (size(e))(0) eq 2 then edge_products, e, mean=em else em=e

@function_com
;FUNCTION_COM - Common and common source for information on fitting functions
;
;common function_com, f_model, Epivot, a_cutoff

checkvar,apar,fltarr(10)

npar = n_elements(a)
apar(0) = a(0: (npar-1)< (n_elements(apar)-1) )
if total(abs(apar(8:9))) eq 0.0 then apar(8)=a_cutoff

ans = f_3pow(em,apar(2:9)) + f_vth(e, apar(0:1))


return,ans
end
