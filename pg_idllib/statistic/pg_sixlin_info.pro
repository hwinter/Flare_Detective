;+
; NAME:
;
; pg_sixlin_info 
;
; PURPOSE:
;
; prints relevant information for sixlin OLS fittings
;
; CATEGORY:
;
; statistic & regression util
;
; CALLING SEQUENCE:
;
; pg_sixlin_info,a,siga,b,sigb
;
; INPUTS:
;
; a,siga,b,sigb: ouput drom the sixlin routine
;
; OPTIONAL INPUTS:
;
;
;
; KEYWORD PARAMETERS:
;
;
;
; OUTPUTS:
;
;
;
; OPTIONAL OUTPUTS:
;
;
;
; COMMON BLOCKS:
;
;
;
; SIDE EFFECTS:
;
;
;
; RESTRICTIONS:
;
;
;
; PROCEDURE:
;
;
;
; EXAMPLE:
;
;
;
; AUTHOR:
;
; Paolo Grigis, Institute of Astronomy, ETH Zurich
; pgrigis@astro.phys.ethz.ch
;
; MODIFICATION HISTORY:
;
; 24-MAR-2004 written PG
;
;-

PRO pg_sixlin_info,a,siga,b,sigb

print,'Information on sixlin regression Y=A+B*X'
print,'--------------------------------------------------'
print,'OLS(Y|X)'
print,'A='+strtrim(string(a[0],format='(f12.4)'),2) $
     +'+-'+strtrim(string(siga[0],format='(f12.4)'),2)
print,'B='+strtrim(string(b[0],format='(f12.4)'),2) $
     +'+-'+strtrim(string(sigb[0],format='(f12.4)'),2)
print,'--------------------------------------------------'
print,'OLS(X|Y)'
print,'A='+strtrim(string(a[1],format='(f12.4)'),2) $
     +'+-'+strtrim(string(siga[1],format='(f12.4)'),2)
print,'B='+strtrim(string(b[1],format='(f12.4)'),2) $
     +'+-'+strtrim(string(sigb[1],format='(f12.4)'),2)
print,'--------------------------------------------------'
print,'OLS BISECTOR'
print,'A='+strtrim(string(a[2],format='(f12.4)'),2) $
     +'+-'+strtrim(string(siga[2],format='(f12.4)'),2)
print,'B='+strtrim(string(b[2],format='(f12.4)'),2) $
     +'+-'+strtrim(string(sigb[2],format='(f12.4)'),2)
print,'--------------------------------------------------'
print,'ORTHOGONAL REGRESSION (MAJOR AXIS)'
print,'A='+strtrim(string(a[3],format='(f12.4)'),2) $
     +'+-'+strtrim(string(siga[3],format='(f12.4)'),2)
print,'B='+strtrim(string(b[3],format='(f12.4)'),2) $
     +'+-'+strtrim(string(sigb[3],format='(f12.4)'),2)
print,'--------------------------------------------------'
print,'REDUCED MAJOR AXIS [GEOMETRIC MEAN OF OLS(X|Y) AND OLS(Y|X)]'
print,'A='+strtrim(string(a[4],format='(f12.4)'),2) $
     +'+-'+strtrim(string(siga[4],format='(f12.4)'),2)
print,'B='+strtrim(string(b[4],format='(f12.4)'),2) $
     +'+-'+strtrim(string(sigb[4],format='(f12.4)'),2)
print,'--------------------------------------------------'
print,'MEAN OLS'
print,'A='+strtrim(string(a[5],format='(f12.4)'),2) $
     +'+-'+strtrim(string(siga[5],format='(f12.4)'),2)
print,'B='+strtrim(string(b[5],format='(f12.4)'),2) $
     +'+-'+strtrim(string(sigb[5],format='(f12.4)'),2)
print,'--------------------------------------------------'



END
