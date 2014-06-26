;+
;
; NAME: f_vth_thick
; Flux model of a thermal bremsstrahlung plus thick target broken
; power law (GHolman)
;
; PURPOSE:
; This function returns the differential photon spectrum seen at the Earth
; for a two component model comprised of an optically thick thermal
; bremsstrahlung function normalized to the Sun-Earth distance plus a
; non-thermal broken power-law function normalized to the incident
; flux on the detector.
;
; CATEGORY:
;       SPECTRA, XRAYS
;
; CALLING SEQUENCE:
;       Flux = F_VTH_THICK( E, A )
;
; CALLS:
;       F_VTH, F_BPOW, EDGE_PRODUCTS, CHECKVAR
;
; INPUTS:
; E -energy vector in keV, 2XN edges or N mean energies
; A -model parameters defined below
; For the thermal function using F_VTH.PRO:
;   a(0)= emission measure in units of 10^49 cm-3
;   a(1)= KT   plasma temperature in keV
;   a(2) - normalization factor (electron flux), i.e. nonthermal electron density * area
;          * electron velocity
;          densty = number density of nonthermal electrons (cm^-3);
;          area = area of the radiating source region (cm^2).;
;   a(3) - Power-law index of the electron distribution function below
;          eebrk.
;   a(4) - Break energy in the electron distribution function (in keV)
;   a(5) - Power-law index of the electron distribution function above
;          eebrk.
;   a(6) - Low energy cutoff in the electron distribution function
;          (in keV).
;   a(7) - High energy cutoff in the electron distribution function (in keV).
;
; COMMON BLOCKS:
; FUNCTION_COM
;
; HISTORY:
; VERSION 1, RAS, ~1991
; VERSION 2, RAS, MAY 1996, FULLY DOCUMENTED
; 2002/12/12 Linhui Sui-- fix infinity and nan output
;                 and avoid spextra index = 1.
;   26-mar-2003, richard.schwartz@gsfc.nasa.gov - call f_vth with 2xN energy edges.
; 2003/3/28, Linhui Sui-- in ans expression, change 1.0e25 to 1.0e35 for consistence of
;                 change from density distribution to flux distribution
; 2003/10/31, PSH: added ALBEDO corrections...
;
;-
function f_vth_thick, e, a

@function_com
;FUNCTION_COM - Common and common source for information on fitting functions
;
;common function_com, f_model, Epivot, a_cutoff

if (size(e))(0) eq 2 then edge_products, e, mean=em else em=e

checkvar,apar,fltarr(8)

npar = n_elements(a)
apar(0) = a(0: (npar-1)< (n_elements(apar)-1) )
if total(abs(apar(6:7))) eq 0.0 then apar(6)=a_cutoff

;spectral index 1.0 will cause NaN flux
if (apar[3] eq 1.0) then apar[3] = 1.01
if (apar[5] eq 1.0) then apar[5] = 1.01

ans = apar[2]* 1.0e35 * brm_bremthick(em,apar(2:7))
	;ALEXANDER ALBEDO CORRECTION (only fir low-E power law part...)
	ans=ans*alexander_albedo_correction(em,apar[3]-1) 
ans=ans + f_vth(e, apar(0:1))

;If output is infinity or nan, set them to small number
NaNInd = where((finite(ans, /infinity) eq 1) or (finite(ans, /nan) eq 1))
if (NaNInd[0] ge 0) then ans[NaNInd] = 1.0e-27

return,ans
end





