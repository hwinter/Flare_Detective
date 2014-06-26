;+
; NAME:
;
; pg_ardec2ecliptic
;
; PURPOSE:
;
; convert AR and DEC astronomical coordinates to ecliptical coordinates
;
; CATEGORY:
;
; Astronomical utilities
;
; CALLING SEQUENCE:
;
; pg_ardec2ecliptic,ar,dec,lambda,beta 
;
; INPUTS:
;
; ar: Right ascension coordinates in decimal hours (a float or double between 0 and 24)
; dec: Declination coordinates in decimal degrees (a float or double between -90 and 90)
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
; lambda: ecliptical longitude (decimal degrees from 0 to 360, measured from the vernal 
;          equinox along the ecliptic)
; beta: ecliptical latitude (decimal degrees from -90 to 90, positive if north of the
;       ecliptic, negative if south)
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
; Uses formula 13.1 and 13.2 from "Astronomical Algorithms" by Jean Meeus, 2d edition 1998
;
; EXAMPLE:
;
;
;
; AUTHOR:
;
; Paolo Grigis, pgrigis@cfa.harvard.edu
; 
;
; MODIFICATION HISTORY:
;
; Written 10-NOV-2009 PG
;-

PRO pg_ardec2ecliptic,ar,dec,lambda,beta 

pi=!DPi

;convert AR & DEC in radiantes
arrad=ar/12d *pi
decrad=dec/180d *pi

;computes the inclination of the ecliptic at equinox J2000.0
epsilon=23.4392911d/180d *pi

;computes ecliptic coordinates
lambda=atan(sin(arrad)*cos(epsilon)+tan(decrad)*sin(epsilon),cos(arrad))/pi*180
beta=asin(sin(decrad)*cos(epsilon)-cos(decrad)*sin(epsilon)*sin(arrad))/pi*180

;correct lambda from -180 to 180 range into 0 to 360
ind=where(lambda LT 0, count)
IF count GT 0 THEN BEGIN 
   lambda[ind]=lambda[ind]+360d
ENDIF


END



