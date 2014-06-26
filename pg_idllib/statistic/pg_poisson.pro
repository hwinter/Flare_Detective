;+
; NAME:
;
; pg_poisson
;
; PURPOSE:
;
; returns the poisson probability distribution function
;
; CATEGORY:
;
; statistic util
;
; CALLING SEQUENCE:
;
; y=pg_poisson(x,lambda=lambda)
;
; INPUTS:
;
; x: function argument, if not integer will be rounded!
; lambda: average of the distribution
;
; OPTIONAL INPUTS:
;
;
;
; KEYWORD PARAMETERS:
;
;
; OUTPUTS:
;
;
; OPTIONAL OUTPUTS:
;
;
; COMMON BLOCKS:
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
; 23-AUG-2006 written PG
;
;-

FUNCTION pg_poisson,x,lambda=lambda;,y2=y2

lambda=fcheck(lambda,1)

y=exp(-lambda+round(x)*alog(lambda)-lngamma(round(x)+1))
;y2=exp(-lambda+x*alog(lambda)-lngamma(x+1))

RETURN,y

END
