;+
; NAME:
;
; pg_gauss
;
; PURPOSE:
;
; gaussian function, syntax can be used with MPFIT
;
; CATEGORY:
;
; statistic & fitting util
;
; CALLING SEQUENCE:
;
; y=pg_gauss(x,par)
;
; INPUTS:
;
; x: function argument
; par: array of ['A','AVG','STDEV'] such that y=A exp(-1/2*((x-AVG)/STDEV)^2)
;      
;
; OPTIONAL INPUTS:
;
;
;
; KEYWORD PARAMETERS:
;
; getparnames: return the parameter names
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
; 07-SEP-2004 written PG
;
;-

FUNCTION pg_gauss,x,par,getparnames=getparnames

IF keyword_set(getparnames) THEN RETURN,['A','AVG','STDEV']

A=par[0]
AVG=par[1]
STDEV=par[2]

y=A*exp(-0.5d*((x-AVG)/STDEV)^2)

RETURN,y

END
