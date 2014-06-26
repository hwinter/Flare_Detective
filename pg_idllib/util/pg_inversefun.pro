;+
; NAME:
;
; pg_inversefun
;
; PURPOSE:
;
; calculates the numerical inverse function x=g(y) for an input array, given
; the name of the function f such that g(f(x))=x
;
; CATEGORY:
;
; various utilities, numerical math
;
; CALLING SEQUENCE:
;
; y=pg_inversefun(x,name)
;
; INPUTS:
;
; x: input (float or array of floats)
; name: string with the name of the function whose inverse has to be computed
;
; OPTIONAL INPUTS:
;
; range: range over which to compute the original function to use for
;        the numerical inversion. DEFAULT: min(x)-10%, max(x)+10%
;
; Ncomp: number of points at which the original function has to be
; computed. if higher the precision of the results will increase, but
; also the time taken to compute them and the memory used. 
;
; KEYWORD PARAMETERS:
;
;
;
; OUTPUT:
;
; NONE
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
; AUTHOR:
;
; Paolo Grigis, Institute of Astronomy, ETH Zurich
; pgrigis@astro.phys.ethz.ch
;
; MODIFICATION HISTORY:
;
; 18-AUG-2004 written P.G.
;
;-

FUNCTION pg_inversefun,x,name,range=range,Ncomp=Ncomp,_extra=extra

IF n_elements(range) NE 2 THEN BEGIN
   range=[0.,10.]
ENDIF

Ncomp=fcheck(Ncomp,1001)

yinput=findgen(Ncomp)/(Ncomp-1)*(max(range)-min(range))+min(range) 

IF n_elements(extra) GT 0 THEN $
      xoutput=call_function(name,yinput,_extra=extra) $
ELSE $
      xoutput=call_function(name,yinput)

;interpolate result
result=fltarr(n_elements(x))

FOR i=0,n_elements(x)-1 DO BEGIN
   result[i]=interpol(yinput,xoutput,x[i])
ENDFOR

RETURN, result

END
