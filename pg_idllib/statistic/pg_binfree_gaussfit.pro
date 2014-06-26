;+
; NAME:
;
; pg_binfree_gaussfit
;
; PURPOSE:
;
; fit a gaussian probability distribution to the input UN-binned data.
; The total probability in the bin is the integral of the (gaussian)
; probability density
; 
;
; CATEGORY:
;
; statistic & fitting util
;
; CALLING SEQUENCE:
;
; parms=pg_binfree_gaussfit(x,parguess=parguess)
;
; INPUTS:
;
; x: data to fit
; 
;
; OPTIONAL INPUTS:
;
; parguess: initial guess of the parameters
;
; KEYWORD PARAMETERS:
;
; are passed to mpfitfun 
;
; OUTPUTS:
;
; parms: array ['AVG','STDEV'] with the strength, average and
; standard deviation of the peak
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
; 08-SEP-2004 written PG
;
;-

FUNCTION pg_binfree_gaussfit,x,parguess=parguess,_extra=_extra


xin=x[sort(x)]

nx=n_elements(xin)

y=-1d +(findgen(nx)+1)*2d /(nx+1)

modelname='pg_norm_erf'

parinfo=replicate({value:0d,fixed:0,limits:[0.d,0],limited:[0,0],parname:''},2)
parinfo.value=fcheck(parguess,[1.,1.])
parinfo[1].limited=[1,0]
parinfo.parname=call_function(modelname,/getparnames)

parms=mpfitfun(modelname,xin,y,replicate(0.01,nx) $
              ,parinfo=parinfo,_extra=_extra)



RETURN,parms

END 

