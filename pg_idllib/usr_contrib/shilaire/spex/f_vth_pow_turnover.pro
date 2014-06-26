;+
;
; NAME:
;       Flux model of a thermal bremsstrahlung plus photon power-law from electron power-law with cutoff
;
;
; CATEGORY
;
; CATEGORY:
;       SPECTRA, XRAYS
;
; CALLING SEQUENCE:
;
; CALLS:
;       F_VTH, F_POW_TURNOVER, EDGE_PRODUCTS, CHECKVAR
;
; INPUTS:
;       E -energy vector in keV, 2XN edges or N mean energies
;       A -model parameters defined below
;       For the thermal function using F_VTH.PRO:
;         a[0]= emission measure in units of 10^49 cm-3
;         a[1]= KT       plasma temperature in keV
;
;
;       For the "non-thermal" function it uses the broken power law function, F_BPOW.PRO:
;         a[2] - normalization of broken power-law at Epivot (usually 50 keV)
;         a[3] - negative power law index
;         a[4] - turnover energy
;
; COMMON BLOCKS:
;       FUNCTION_COM
;
; HISTORY:
;	PSH, 2003/10/22
;
;-
function f_vth_pow_turnover, e, a

if (size(e))[0] eq 2 then edge_products, e, mean=em else em=e

@function_com

ans = f_pow_turnover(em,a[2:4]) + f_vth(e, a[0:1])

return,ans
end
