;+
; NAME:
;      pg_fixarrbound
;
; PURPOSE: 
;      set the boundary of an array (first & last column & row)
;      equal to a linear extrapolation of the 2nd & third row & columns
;
; CALLING SEQUENCE:
;      ans=pg_fixarrbound(arr)
;
; INPUTS:
;      arr: a two dimensional matrix
;
; OUTPUT:
;      ans: a two dimensional matrix
;       
;
; COMMENT:
;      
;
; EXAMPLE:   
;
;
; VERSION:
;       03-JAN-2007 written pg
;
; AUTHOR:
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;       pgrigis@astro.phys.ethz.ch
;-


;.comp  pg_fixarrbound


PRO pg_fixarrbound_test

;a=bytscl(dist(5,5))
a=[[1,2,1,3,2],[3,4,5,8,2],[3,6,4,1,2],[3,4,5,8,2],[0,0,0,0,0]]

print,a
print,pg_fixarrbound(float(a))

END


FUNCTION pg_fixarrbound,arr

dim=size(arr,/dimensions)
n=dim[0]
m=dim[1]

IF n_elements(dim) NE 2 THEN BEGIN
   print,'Please input a 2-dim array'
   return,-1
ENDIF

IF min(dim) LT 5 THEN BEGIN
   print,'Please input at least a 5 by 5 array'
   return,-1
ENDIF

res=arr

col2=arr[1,*]
col3=arr[2,*]
res[0,*]=2*col2-col3

coln2=arr[n-2,*]
coln3=arr[n-3,*]
res[n-1,*]=2*coln2-coln3

row2=arr[*,1]
row3=arr[*,2]
res[*,0]=2*row2-row3

rowm2=arr[*,m-2]
rowm3=arr[*,m-3]
res[*,m-1]=2*rowm2-rowm3

;corners
res[0,0]=res[1,0]+res[0,1]-res[1,1]
res[n-1,m-1]=res[n-2,m-1]+res[n-1,m-2]-res[n-2,m-2]

res[n-1,0]=res[n-2,0]+res[n-1,1]-res[n-2,1]
res[0,m-1]=res[1,m-1]+res[0,m-2]-res[1,m-2]

return,res


END
