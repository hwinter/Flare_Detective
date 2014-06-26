;+
; NAME:
;
; pg_get_normalvector
;
; PURPOSE:
;
; return a 2D vector normal to another one, with a given length
; the two vectors cros t the midpoint of the first
;
; CATEGORY:
;
; 2D geometry
;
; CALLING SEQUENCE:
;
; pg_get_normalvector,p1x,p1y,p2x,p2y,length=length,v1x=v1x,v1y=v1y,v2x=v2x,v2y=v2y
;
; INPUTS:
;
; p1x: x of 1st point
; p1y: y of 1st point
; p2x: x of 2nd point
; p2y: y of 2nd point
;
; OPTIONAL INPUTS:
;
; length: length of perpendicular vector (default: 1)
;
; KEYWORD PARAMETERS:
;
;
;
; OUTPUTS:
;
; v1x: x of 1st point of normal vector
; v1y: y of 1st point of normal vector
; v2x: x of 2st point of normal vector
; v2y: y of 2st point of normal vector
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
; pg_get_normalvector,0.,0.,0.,1.,v1x=v1x,v1y=v1y,v2x=v2x,v2y=v2y
;
; AUTHOR
;
; Paolo Grigis pgrigis@cfa.harvard.edu
;
; MODIFICATION HISTORY:
;
; written 23-NOV-2009 PG
;
;-

PRO pg_get_normalvector,p1x,p1y,p2x,p2y,length=length,v1x=v1x,v1y=v1y,v2x=v2x,v2y=v2y

length=fcheck(length,1.0)

;computes midpoint
mx=0.5*(p1x+p2x)
my=0.5*(p1y+p2y)

;computes perpendicular unit vector

px=(p2y-p1y)
py=-(p2x-p1x)
norm=sqrt(px*px+py*py)

v1x=mx+px/norm*length*0.5
v1y=my+py/norm*length*0.5
v2x=mx-px/norm*length*0.5
v2y=my-py/norm*length*0.5



END


