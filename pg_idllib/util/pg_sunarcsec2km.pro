;+
; NAME:
;   pg_sunarcsec2km
;
; PURPOSE:
;   give the length in kilometers of an arcsecond at the center
;   of the surface of the sun as seen from the earth
;
; INPUT: 
;   time: time reference for the transformation
;
; OPTIONAL INPUT:
;
; OUTPUT:
;   lenght in km
;
; KEYWORDS:
;  
;
; HISTORY:
;   written 08-FEB-2005 by Paolo Grigis, ETH Zurich
;   pgrigis@astro.phys.ethz.ch
;-


FUNCTION pg_sunarcsec2km,time

t=anytim(time,/ex)

au=1.49598d8; AU in kilometers
sunradius=6.95d5 ;solar radius in km

sun,t[6],t[5],t[4],t[0]+t[1]/60.,dist=sundistance

sundistance=sundistance*au-sunradius

arcsec=!DPi/(180.*3600.)*sundistance

RETURN, arcsec

END

