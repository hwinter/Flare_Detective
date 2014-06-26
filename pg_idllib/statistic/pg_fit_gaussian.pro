;+
; NAME:
;
; pg_fit_gaussian
;
; PURPOSE:
;
; fit a gaussian probability distribution to the input binned data.
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
; parms=pg_fit_gaussian(x_edges,histo,parguess=parguess)
;
; INPUTS:
;
; x_edges: edges of the histogram bins
; histo: values of each bin 
;      
;
; OPTIONAL INPUTS:
;
; parguess: initial guess of the parameters
;
; KEYWORD PARAMETERS:
;
; can be passed to mpfitfun 
;
; OUTPUTS:
;
; parms: array ['A','AVG','STDEV'] width the strength, average and
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

FUNCTION pg_fit_gaussian,x_edges,histo,parguess=parguess,_extra=_extra

modelname='pg_gauss_int'

parinfo=replicate({value:0d,fixed:0,limits:[0.d,0],limited:[0,0],parname:''},3)
parinfo.value=fcheck(parguess,[1.,1.,1.])
parinfo[0].limited=[1,0]
parinfo[2].limited=[1,0]

parinfo.parname=call_function(modelname,/getparnames)

parms=mpfitfun(modelname,x_edges,histo,replicate(1,n_elements(histo)) $
              ,parinfo=parinfo,_extra=_extra)


return,parms


END
