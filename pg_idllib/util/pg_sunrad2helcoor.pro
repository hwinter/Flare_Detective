;+
; NAME:
;   pg_sunrad2helcoor
;
; PURPOSE:
;   transform solar coordinates given in units of the solar radius
;   in heliocentric coordinates (arcseconds from sun center)
;
; INPUT: 
;   rx,ry: coordinates in solar radii units
;   time: time to which the coords refer to
;
; OUTPUT:
;   [x,y]: array of heliocentric coord
;
; KEYWORDS:
;  
;
; HISTORY:
;   written 11-SEP-2003 by Paolo Grigis, ETH Zurich
;   
;-


FUNCTION pg_sunrad2helcoor,time,rx,ry

t=anytim(time,/ex)

sun,t[6],t[5],t[4],t[0]+t[1]/60.,sd=sunradius

x=rx*sunradius
y=ry*sunradius

RETURN,[x,y]

END

