;+
; NAME:
;       expo     
;
; PURPOSE: 
;       generate an array of data with the shape of an exponential
;       with given FWHM. The area is 1. The exponential is centered
;       on mu. Coordinates are required!
;
; CALLING SEQUENCE:
;      
;
; INPUTS:
;       x:    coordinates
;       mu:   peak location
;       fwhm: FWHM in array unit
;
; OUTPUT:
;             
;       
; KEYWORDS:
;        
;
; VERSION:
;       0.1 11-JUL-2002
;       0.2 12-JUL-2002 switched to coordinates mode
;           06-JAN-2002 imported in rapp_idl
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;-

FUNCTION expo,x,mu,fwhm

dim=size(x)
d=dim[2]

sigma=fwhm*0.4246609

RETURN,0.3989423/sigma*exp(-(x-mu)*(x-mu)/(2*sigma*sigma))
END



;
;
