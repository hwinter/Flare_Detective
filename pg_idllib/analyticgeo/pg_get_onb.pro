;+
;
; NAME:
;        pg_get_onb
;
; PURPOSE: 
;
;        returns a positively oriented 3D orthonormal basis, the first
;        element of which is a vector parallel to the input vector v
;
; CALLING SEQUENCE:
;
;        onb=pg_get_onb(v)
;    
; 
; INPUTS:
;
;        v: a three-dimensional vector
;
; KEYWORDS:
;        
;                
; OUTPUT:
;        onb: 3 by 3 matrix, the column contains the basis vectors
;
; CALLS:
;        
;
;       
; HISTORY:
;       
;       24-AUG-2005 written pg
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;       pgrigis@astro.phys.ethz.ch
;
;-

FUNCTION pg_get_onb,v_in

v=v_in

IF total(abs(v)) EQ 0 THEN BEGIN 
   print,'INVALID INPUT: V MUST NOT BE [0,0,0]!'
   RETURN,-1
ENDIF

norm=sqrt(v[0]*v[0]+v[1]*v[1]+v[2]*v[2])
IF norm NE 1d THEN v=v/norm

b1=replicate(0d,3)
b2=b1

;find b1 perpendicular to v
ind=where(v EQ 0, nzero)
IF nzero EQ 0 THEN BEGIN 
   b1[0]=1d/v[0] 
   b1[1]=-1d/v[1]
ENDIF $
ELSE BEGIN 
   b1[ind[0]]=1d
ENDELSE 

norm=sqrt(b1[0]*b1[0]+b1[1]*b1[1]+b1[2]*b1[2])
IF norm NE 1d THEN b1=b1/norm

b2[0]=v[1]*b1[2]-v[2]*b1[1]
b2[1]=v[2]*b1[0]-v[0]*b1[2]
b2[2]=v[0]*b1[1]-v[1]*b1[0]
 
onb=dblarr(3,3)
onb[0,*]=v
onb[1,*]=b1
onb[2,*]=b2

RETURN,onb

END











