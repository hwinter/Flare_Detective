;+
; NAME:
;
; pg_getnsigpoints
;
; PURPOSE:
;
; return an array of indices to points lying in a region of N sigma
; around the central peak of a 2-dim gaussian distribution
; 
; CATEGORY:
;
; shs tool
;
; CALLING SEQUENCE:
;
; ind=pg_getnsigpoints(x,y,par,n=n)
;
; INPUTS:
;
; x,y: points coordinates
; par: peak parameters
;
; OPTIONAL INPUTS:
;
; n: in units of sigma (def: 3)
;
; KEYWORD PARAMETERS:
;
;
; OUTPUTS:
; ind: output index array
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
; 10-SEP-2004 written PG
;
;-
FUNCTION pg_getnsigpoints,x,y,par,n=n

   n=fcheck(n,3d)

   threshold=exp(-0.5*n^2)

   yfit2=pg_mp2dpeak(x, y, [par[0],1d,par[2:6]])

   index=where(yfit2 GE threshold)

   return,index

END
