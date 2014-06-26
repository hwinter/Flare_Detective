;+
;
; NAME:
;        pg_vector_prod,v1,v2
;
; PURPOSE: 
;
;        returns the vector product of 2 3d vectors v1 and v2
;
; CALLING SEQUENCE:
;
;        v3=pg_vector_prod(v1,v2)
;    
; 
; INPUTS:
;
;        v1,v2: three-dimensional vectors
;
; KEYWORDS:
;        
;                
; OUTPUT:
;        
;        v3: three-dimensional vectors
;
; CALLS:
;        
;
;       
; HISTORY:
;       
;       25-JAN-2007 written pg
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;       pgrigis@astro.phys.ethz.ch
;
;-

FUNCTION pg_vector_prod,v1,v2

v3=v1*0.

v3[0]=v1[1]*v2[2]-v1[2]*v2[1]
v3[1]=v1[2]*v2[0]-v1[0]*v2[2]
v3[2]=v1[0]*v2[1]-v1[1]*v2[0]

return,v3

END











