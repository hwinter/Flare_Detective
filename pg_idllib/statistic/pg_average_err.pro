;+
; NAME:
;
; pg_average_err
;
; PURPOSE:
;
; returns the average of a finite distribution with its error
; the error is estimated from a student T test, and is good especially
; for distributions with few elements. Inputs are the distribution
; and a confidence value for the error (for instance, 95%)
;
; CATEGORY:
;
; statistic utils
;
; CALLING SEQUENCE:
;
; pg_average_err,x,confid=confid,mean=mean,errmean=errmean
;
; INPUTS:
;
; x: array of floats or doubles
; confid: confidence range for the error (def. 95%)
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
; mean: the average
; errmean its error (that is, conf range is [mean-err...mean+err],
; sure at confid%)
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
; Paolo Grigis, Institute for Astronomy, ETH Zurich
; pgrigis@astro.phys.ethz.ch
;
; MODIFICATION HISTORY:
;
; 05-SEP-2005 written
; 
;
;-

PRO pg_average_err,x,confid=confid,mean=mean,errmean=errmean

IF NOT exist(x) THEN BEGIN
   print,'Please input an array of real numbers!'
   RETURN
ENDIF

confid=fcheck(confid,0.95)

n=n_elements(x)

m=moment(x)

mean=m[0]
s=sqrt(m[1])

t=t_cvf(0.5d*(1d -confid),n-1)

errmean=t*s/sqrt(n)

END

