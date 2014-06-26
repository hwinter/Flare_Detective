;+
; NAME:
;      pg_interpolate
;
; PURPOSE: 
;      Returns the interpolation of an array y, defined for a grid x,
;      over a set of point z. The array is passed by a keyword, such
;      that this function is suited for use in conjunction with
;      numerical integration routines (such as QPINT1D etc.)
;
; CALLING SEQUENCE:
;      ans=pg_interpolate(z,xin=xin,yin=yin)
;
; INPUTS:
;      z: number or array of points at which the interpolated value
;         is sought
;      xin: x values corresponding to the points in yin
;      yin: array of values
;
; KEYWORDS:
;      
;
; OUTPUT:
;      
;
; COMMENT:
;
;       a convenient wrapper for interpol to use with QPINT1D
;
; EXAMPLE   
;
;
;
; VERSION:
;       17-OCT-2005 written PG
;       
; AUTHOR:
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;-

FUNCTION pg_interpolate,z,xin=xin,yin=yin,_extra=_extra

RETURN,interpol(yin,xin,z,_extra=_extra)

END
