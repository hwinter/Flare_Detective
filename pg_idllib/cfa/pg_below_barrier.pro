;+
; NAME:
;
;  pg_below_barrier
;
; PURPOSE:
;
; find if a data point is below a given function
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
;
; AUTHOR:
;
; Paolo Grigis (pgrigis@cfa.harvard.edu)
;
; MODIFICATION HISTORY:
; written 14-MAY-2008
;-

FUNCTION pg_below_barrier,x,y,barx=barx,bary=bary,count=count,compind=compind

res=interpol(bary,barx,x)
ind=where(y LE res,count,complement=compind)
return,ind

END

