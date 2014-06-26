;+
; NAME:
;
; pg_juggleindex
;
; PURPOSE:
;
; 
;
; CATEGORY:
;
; 
;
; CALLING SEQUENCE:
;
; 
;
; INPUTS:
;
; 
;
; OPTIONAL INPUTS:
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
; COMMON BLOCKS:
;
;
; SIDE EFFECTS:
;
;
; RESTRICTIONS:
;
;
; PROCEDURE:
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
; 14-DEC-2005 written P.G.
;
;-

PRO pg_juggleindex_test

dimarr=[2L,3,3]
indarr=[1L,2,3,4,5,6,8]
res=pg_juggleindex(dimarr,indarr)


END

FUNCTION pg_juggleindex,dimarr,indarr_in

indarr=indarr_in

ndim=n_elements(dimarr)
dimprod=product(dimarr,/cumulative)

nind=n_elements(indarr)

indarr=indarr > 0L < dimprod[ndim-1]

res=lonarr(ndim,nind)
 
res[0,*]=indarr MOD dimarr[0]

FOR j=1L,ndim-1 DO BEGIN 
    res[j,*]=(indarr/dimprod[j-1]) MOD dimarr[j]  
ENDFOR

RETURN,res

END
