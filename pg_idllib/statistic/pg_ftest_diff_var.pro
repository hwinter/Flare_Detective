;+
; NAME:
;
; pg_ftest_diff_var
;
; PURPOSE:
;
; perform F-test on two distribution x and y to check whether
; they have a significantly different variance
;
; CATEGORY:
;
; statistic utils
;
; CALLING SEQUENCE:
;
; prob= pg_ftest_diff_var(x,y,f=f)
;
; INPUTS:
;
; x,y: two array (they may have a different number of elements)
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
; prob: confidence level that the two distributions have the same
;      variance (if prob less than 5% or 1%, than the distr. have
;      significantly different variance)
;
; OPTIONAL OUTPUTS:
;
; f:...
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
; Paolo Grigis, Institute for Astronomy, ETH Zurich
; pgrigis@astro.phys.ethz.ch
;
; MODIFICATION HISTORY:
;
; 02-MAR-2004 compute written
;
;-

FUNCTION pg_ftest_diff_var,x,y,f=f

nx=float(n_elements(x))-1;number of degrees of freedom for x,y
ny=float(n_elements(y))-1;

avx=total(x)/nx;mean of x,y
avy=total(y)/ny;

varx=total((x-avx)^2)/nx;variance of x,y
vary=total((y-avy)^2)/ny;

IF varx GT vary THEN BEGIN
   f=varx/vary
   df1=nx
   df2=ny
ENDIF ELSE BEGIN
   f=vary/varx
   df1=ny
   df2=nx
ENDELSE

;ibeta is the same as betai in num. rec.
prob=2*ibeta(0.5*df2,0.5*df1,df2/(df2+df1*f),/double)

IF prob GT 1 THEN prob=2-prob

return,prob

END

