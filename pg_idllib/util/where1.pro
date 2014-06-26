;+
; NAME:
;       WHERE1
;
; PURPOSE: 
;       convert where2 output to where output
;
; CALLING SEQUENCE:
;       where1,w,xsize,ysize 
;
; INPUTS:
;       w: where2 output
;       xsize,ysize: x,y dim of the array
;
; OUTPUT:
;       an array of 1dim indices
;
; VERSION
;       1.0 12-NOV-2002
;
; HISTORY
;       written 12-NOV-2002
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;-

FUNCTION where1,w,xsize,ysize

dim=size(w)
ww=intarr(dim[2])

FOR i=0,dim[2]-1 DO $
   ww[i]=w[0,i]+w[1,i]*ysize

RETURN,ww

END
