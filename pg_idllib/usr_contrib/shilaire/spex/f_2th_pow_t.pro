;+
;
; NAME:
;       Flux model of two thermal bremsstrahlung plus photon power-law from electron power-law with cutoff
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
;         a[2]= emission measure in units of 10^49 cm-3
;         a[3]= KT       plasma temperature in keV
;
;
;       For the "non-thermal" function it uses the broken power law function, F_BPOW.PRO:
;         a[4] - normalization of broken power-law at Epivot (usually 50 keV)
;         a[5] - negative power law index
;         a[6] - turnover energy
;
; COMMON BLOCKS:
;       FUNCTION_COM
;
; HISTORY:
;	PSH, 2004/07/08
;
;-
function f_2th_pow_t, e, a

if (size(e))[0] eq 2 then edge_products, e, mean=em else em=e

@function_com

ans = f_pow_turnover(em,a[4:6]) + f_vth(e, a[0:1]) + f_vth(e, a[2:3])

return,ans
end
