;+
;Name:
;   F_VTH
;PURPOSE:
;   This function returns the optically thin thermal bremsstrahlung radiation function
;   as differential spectrum seen at Earth in units of photon/(cm2 s keV)
;
;CATEGORY:
;   SPECTRA, XRAYS (>1 keV)
;INPUTS:
;   E  energy vector in keV
;   apar(0)  em_49, emission measure units of 10^49
;   apar(1)  KT, plasma temperature in keV
;KEYWORD INPUTS:
;   NOLINE - Returns only MEWE_KEV continuum non-line flux.
;   f_vth_funct - a string, either 'MEWE_KEV' (default) or 'CHIANTI_KEV'.  Specifies
;     the function to be used when energies are less than 8 keV.
;CALLS:
;   VLTH, BREM_49, MEWE_KEV, CHIANTI_KEV
;
;Common Blocks:
;
;
;Method:
;   If energy array starts at lt 8 keV, then mewe_kev is used to
;   compute the spectrum including lines.
;   If not, then the spectrum is pure free-free continuum from
;            the Brem_49 function.
; History:
;   ras, 17-may-94
;   ras, 14-may-96, checked for 2xn energies, e
;   Version 3, 23-oct-1996, revised check for 2xn energies, e
;   ras, 10-apr-2002, ras, default to vlth() when bottom energy
;   is less than 8 keV.
;   ras, 2-may-2003, support relative abundance pass through to mewe_kev
;     call mewe_kev directly, no longer uses interpolation table in vlth.pro
;   ras, 25-jun-2003, added NOLINE keyword passed through to mewe_kev
;   Kim Tolbert, 2004/03/04 - added _extra so won't crash if keyword is used in call
;   ras, 31-aug-2005, modified to allow calls to chianti_kev via VTH_METHOD environment var.
;-
function f_gtest, e, apar, noline=noline, f_vth_funct=f_vth_funct, _extra=_extra

;stop


;common f_vth, rel_abun
;rel_abun = keyword_set( rel_abun ) ? rel_abun : reform( [26, 1.0, 28, 1.0], 2,2)
e_1 = e
if (size(e_1))(0) eq 2  then begin

    if e_1(0) lt 8.0 then begin
       if keyword_set( f_vth_funct) then begin
        if strupcase( f_vth_funct) ne 'CHIANTI_KEV' then f_vth_funct = 'MEWE_KEV'
        endif else begin

            if stregex('chianti', getenv( 'VTH_METHOD' ),/fold_case,/boolean)  $
             then f_vth_funct=  'CHIANTI_KEV'  $
            else f_vth_funct= 'MEWE_KEV'
       endelse
       result = apar(0)* $
       float( call_function(f_vth_funct,  /photon,/edges,/keV,/earth, apar(1)/.08617 , e_1,$
         noline=noline, _extra=_extra )*1e5)

    endif
    endif


return, Not keyword_set( result ) ? apar(0)*brem_49(get_edges(e,/mean),apar(1)) : result
end
