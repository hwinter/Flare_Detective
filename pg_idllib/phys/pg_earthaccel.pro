;+
; NAME:
;      pg_earthaccel
;
; PURPOSE: 
;      computes the gravitational acceleration of a point on the
;      surface of the earth, as a function of height and latitude.
;
; CALLING SEQUENCE:
;      g=pg_earthaccel(l,h)
;
; INPUTS:
;      l: latitude (in degrees)
;      h: height (in meters)
;
; OUTPUT:
;      g: gravitational acceleration
;       
; KEYWORDS:
;        
;
; HISTORY:
;       30-NOV-2005 written
;       
;
; COMMENT:
;       reference ???
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;       pgrigis@astro.phys.ethz.ch
;-

FUNCTION pg_earthaccel,l,h

lrad=l/180d *!Dpi

g=9.780318d + 9.780318d*5.3024d-3*sin(lrad)^2 $
 +9.780318d*5.9d-6*sin(2*lrad)^2+9.780318d*3.15d-7*h

RETURN,g
  
END



