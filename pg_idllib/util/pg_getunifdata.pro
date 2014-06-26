;+
; NAME:
;
; pg_getunifdata
;
; PURPOSE:
;
; returns an array of floats homogeneously spaced
;
; CATEGORY:
;
; various utilities
;
; CALLING SEQUENCE:
;
; out=pg_getunifdata(N,min=min,max=max)
;
; INPUTS:
;
; N: number of leements in the final array
;
; OPTIONAL INPUTS:
;
; min: minimal value for the array
; max: maximal value for the array
; 
;
; KEYWORD PARAMETERS:
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
; 14-MAY-2004 written PG
;
;-
FUNCTION pg_getunifdata,N,min=min,max=max

min=fcheck(min,0)
max=fcheck(max,1)

x=min+findgen(N)/(N-1)*(max-min)

RETURN,x

END
