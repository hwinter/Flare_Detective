;+
; NAME:
;
;   pg_polyfit
;
; PURPOSE:
;
;   perform a polynomial fitting. It calls MPFITFUN to do the fitting,
;   such that the results can be better compared with other fitting by
;   MPFITFUN (instead of, say, using IDL's builtin poly_fit).
;
; CATEGORY:
;
;   fitting tools
;
; CALLING SEQUENCE:
;
;   result=pg_polyfit(x,y,degree=degree,weights=weights)
;
; INPUTS:
;
;   x,y: the coordinates of the points to fit 
;
; OPTIONAL INPUTS:
;
;   degree: the degree of the polynomial to fit. Must be GE than 0 (floats are
;     rounded to the nearest integer) and LE 100. If not set, defaults to 2.
;   weights: an array of weights for the y value. If not defined, an identical
;     weight for all points is used.
;   start_params: an array of starting guess values for the polynomial
;     coefficient. If given, then the degree keyword is ignored.
;   verbose: if set, the MPFITFUN output is not supressed
;
; KEYWORD PARAMETERS:
;
;
;
; OUTPUTS:
;
;   result: an array of degree element with the polynomial coefficients
;   (coefficients ordered in decreasing power)
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
;    Paolo Grigis
;    pgrigis@astro.phys.ethz.ch
;
; MODIFICATION HISTORY:
;
;    29-MAR-2007 written
;
;-

;.comp pg_polyfit

FUNCTION pg_polyfit_poly,x,apar

  result=x*0.+apar[0]

  FOR i=1,n_elements(apar)-1 DO result=temporary(result)*x+apar[i]

  RETURN,result
  
END



FUNCTION pg_polyfit,x,y,degree=degree,weights=weights $
                   ,start_params=start_params,verbose=verbose



  degree=fcheck(degree,2)
  degree=round(degree>0<100)

  weights=fcheck(weights,replicate(1.,n_elements(y)))

  IF NOT exist(start_params) THEN BEGIN 
     start_params=replicate(0d,degree+1)
     start_params[0]=1.
  ENDIF 

  dummy=mpfitfun('pg_polyfit_poly',x,y,0,start_params,weights=weights $
                ,quiet=1-keyword_set(verbose))
  
  return,dummy


END

