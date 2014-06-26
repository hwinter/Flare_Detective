;+
; NAME:
;
; pg_get_connession_index
;
; PURPOSE:
;
; get indices of the connected part of an array x
; if x is [1,2,3,5,7,8,9], the result is [2,3], that is elements=3,5 
;
; CATEGORY:
;
; connectivity util
;
; CALLING SEQUENCE:
;
; ind=pg_get_connession_ind(x)
;
; INPUTS:
;
; x: numerical array
;
;
;
; OUTPUTS:
;
; none
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
; 18-FEB-2004 written
; 09-NOV-2004 corrected docs and added tol parameter
;-

FUNCTION pg_get_connession_index,x,tol=tol

   tol=fcheck(tol,1d-6)

   dx=reform(x-shift(x,1))
   dx=dx[1:n_elements(dx)-1]

   dy=dx-shift(dx,1)>0.

   ind=where(dy GT tol)

   return,ind

END





