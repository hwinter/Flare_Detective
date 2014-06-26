;+
; NAME:
;
; pg_shs_getrd
;
; PURPOSE:
;
; find the indices of the rise/decay phase number x
;
; CATEGORY:
;
; util for shs project
;
; CALLING SEQUENCE:
;
; indst=pg_shs_getrd(n,riset=riset,decat=decat)
;
; INPUTS:
;
; n: progressive number of the phase
;
; OPTIONAL INPUTS:
;
;
;
; KEYWORD PARAMETERS:
;
;
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
; AUTHOR:
;
; Paolo Grigis, Institute of Astronomy, ETH Zurich
; 
;
; MODIFICATION HISTORY:
;
; 10-MAY-2004 written
;
;-

FUNCTION pg_shs_getrd,n,riset=riset,decat=decat,stp=stp

IF NOT exist(n) THEN return,-1

n=fix(n)

IF exist(riset) THEN $
   timet=riset ELSE $
   IF exist(decat) THEN $
      timet=decat ELSE $
      RETURN,-1

nprog=lonarr((size(timet,/dimensions))[0])

FOR i=0,n_elements(nprog)-1 DO BEGIN
   dummy=where(timet[i,*,0] NE '',count)
   nprog[i]=count
ENDFOR

ncum=fix(total(nprog,/cumulative))

ind=min(where(ncum GT n)); & print,ind

flare=stp[ind]

tarr =reform(timet[ind,*,*])

tagname='XSELECT'
xsel=pg_getptrstrtag(stp[ind],tagname)
time=anytim((*stp[ind]).date)+0.5*total(xsel,1)


IF ind GT 0 THEN actnumb=n-ncum[ind-1] ELSE actnumb=n

time_intv=anytim(reform(tarr[actnumb,*]))

indices=where(time GE time_intv[0] AND time LE time_intv[1],count)

return,{flare_nr:ind,ind:indices}

END


