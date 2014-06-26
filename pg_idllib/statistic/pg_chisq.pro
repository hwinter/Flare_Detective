;+
; NAME:
;
; pg_chisq
;
; PURPOSE:
;
; returns the chi square distribution
;
; CATEGORY:
;
; util, statistics
;
; CALLING SEQUENCE:
;
; dist=pg_chisq(x,k)
;
; INPUTS:
;
; x: real number
; k: degree of the distribution
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
;
; 
; MODIFICATION HISTORY:
;
; 22-JAN-2007 written
; 
;-

;.comp pg_chisq

FUNCTION pg_chisq,x,k,cumulative=cumulative

k=fcheck(k,1d)

ind=where(x LE 0, count)

res=exp(0.5*k*alog(0.5)+(0.5*k-1)*alog(x)-0.5*x-lngamma(0.5*k))

IF keyword_set(cumulative) THEN res=igamma(0.5*k,0.5*x)


IF count GT 0 THEN res[ind]=0

return,res

;return,exp(0.5*k*alog(0.5))*x^(0.5*k-1)*exp(-0.5*x)/gamma(0.5*k)

  
END
