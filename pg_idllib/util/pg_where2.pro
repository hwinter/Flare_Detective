;+
; NAME:
;       PG_WHERE2
;
; PURPOSE: 
;       return IDL's where for 2 dim arrays in [index0,index1] form
;       instead of a single index. If the array is not two-dim, return
;       IDL's where
;
; CALLING SEQUENCE:
;       where2,a 
;
; INPUTS:
;       a: 2 dimensional array
;
; OUTPUT:
;       an array of 2 dim indices
;
; VERSION
;       1.0 30-SEP-2002
;
; HISTORY
;       written 30-SEP-2002
;       20-JUL-2004 renamed PG_WHERE2 to avoid name conflicts
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;-

function pg_where2,a

s=size(a)

IF s[0] NE 2 THEN $
   RETURN,where(a) ELSE $
   BEGIN
   w=where(a)
   n=n_elements(w)
   ww=intarr(n,2)

   FOR i=0,n-1 DO ww[i,*]=[w[i] mod s[1],floor((w[i])/s[1])]

   return,transpose(ww)
   ENDELSE

END
