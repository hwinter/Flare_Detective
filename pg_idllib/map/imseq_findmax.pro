;+
;
; NAME:
;        imseq_findmax
;
; PURPOSE: 
;        find the maximal value in an image sequence
;      
;
; CALLING SEQUENCE:
;
;        max=imseq_findmax(ptr,frame=frame)
;
; INPUTS:
;        ptr: array of pointers to map
;        frame: frame where the max occur
;
; KEYWORDS:
;        
;                
; OUTPUT:
;        max: value of the max
; CALLS:
;        
;
; VERSION:
;       
;        14-MAR-2003 written
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;-

FUNCTION imseq_findmax,ptr,frame=frame

n=n_elements(ptr)
maxim=fltarr(n)

FOR i=0,n-1 DO $
  IF ptr[i] NE ptr_new() THEN maxim[i]=max((*ptr[i]).data)

maxx=max(maxim)
frame=where(maxim EQ maxx)

RETURN,maxx

END

