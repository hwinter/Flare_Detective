;+
; NAME:
;
; pg_student_diff_mean
;
; PURPOSE:
;
; perform student's t test on two distribution x and y wih the same
; variance to see whether they have a significantly different mean
; see numerical recipes in c, section 14.2
;
; CATEGORY:
;
; statistic utils
;
; CALLING SEQUENCE:
;
; out= pg_student_diff_mean(x,y,t=t)
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
; out: confidence level that mean is different, ok if > 0.99
;
; OPTIONAL OUTPUTS:
;
; t: Student's t
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
; 01-MAR-2004 written
; 02-MAR-2004 compute ibeta in double precision
;
;-

FUNCTION pg_student_diff_mean,x,y,t=t,diff=diff

nx=float(n_elements(x))
ny=float(n_elements(y))

IF keyword_set(diff) THEN BEGIN 
   mx=moment(x)
   my=moment(y)
   t=(mx[0]-my[0])/sqrt(mx[1]/nx+my[1]/ny)
   nf=(mx[1]/nx+my[1]/ny)^2/((mx[1]/nx)^2/(nx-1)+(my[1]/ny)^2/(ny-1))
ENDIF $
ELSE BEGIN 


   nf=nx+ny-2.                  ;number of degrees of freedom
   t=(avx-avy)/sd

ENDELSE

avx=total(x)/nx;mean of x,y
avy=total(y)/ny;

tvarx=total((x-avx)^2); "total" variance of x,y
tvary=total((y-avy)^2)



sd=sqrt((tvarx+tvary)/(nx+ny-2)*(1/nx+1/ny))

;ibeta is the same as betai in num. rec.
prob=1-ibeta(0.5*nf,0.5,nf/(nf+t*t),/double)

return,prob

END

