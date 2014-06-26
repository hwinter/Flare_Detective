;+
; NAME:
;
; pg_gauss_int
;
; PURPOSE:
;
; integal of a gaussian function, syntax can be used with MPFIT
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
; x: function argument: array 2 by N of edges
; par: array of ['A','AVG','STDEV'] such that
;      y[i]=\int _x[i,0] ^x[i,1] A*exp(-1/2*((t-AVG)/STDEV)^2) dt
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

FUNCTION pg_gauss_int,x,par,getparnames=getparnames

IF keyword_set(getparnames) THEN RETURN,['A','AVG','STDEV']

A=par[0]
AVG=par[1]
STDEV=par[2]


y=A*sqrt(!DPi)/2*sqrt(2)*STDEV* $
    ( erf( (x[1,*]-AVG)/(sqrt(2)*STDEV) ) $
     -erf( (x[0,*]-AVG)/(sqrt(2)*STDEV) ) )


RETURN,y

END
