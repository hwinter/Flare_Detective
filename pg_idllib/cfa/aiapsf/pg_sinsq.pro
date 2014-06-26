;+
; NAME:
;
; pg_sinsq
;
; PURPOSE:
;
; computes the function a*(sin(k*x)/k*x)^2
; the parameters in input are in array format to be compatible with mpfit
; par[0]=a par[1]=k
; additionally the value of the central point is given by  par[2] and
; independent form everything else
;
; CATEGORY:
;
; math util
;
; CALLING SEQUENCE:
;
; y=pg_sinsq(x,par)
;
; INPUTS:
;
; x: array of values of the function argument
; par: array with parameters
;      par[0]: lim x->0 pg_sinsq(x)
;      par[1]: wave-vector
;      par[2]: value of function at x=0 
;
; OPTIONAL INPUTS:
;
; eps: value under which the input is considered to be 0
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
; MODIFICATION HISTORY:
;
; written 5-APR-2011 Paolo Grigis
;
;-


FUNCTION pg_sinsq,x,par,eps=eps

k=par[1]
a=par[0]

y=a*(sin(x*k)/(x*k))^2

eps=fcheck(eps,1e-5)
ind=where(abs(x) LT eps,count0)

;stop

IF count0 GT 0 THEN y[ind]=par[2]

RETURN,y

END 
