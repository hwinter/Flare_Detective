;+
;
; NAME:
;        validpointer
;
; PURPOSE: 
;
;        return the indices of the non null pointer of a pointer array
;
; CALLING SEQUENCE:
;
;        ind=validpointer(ptr)
; 
; INPUTS:
;
;        ptr: array of pointer
;                
; OUTPUT:
;        ind: array of indices
;
; CALLS:
;      
;
; VERSION:
;       
;       5-FEB-2002 written
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;-

FUNCTION validpointer,ptr

N=n_elements(ptr)
ind=lonarr(N)

FOR i=0L,N-1 DO BEGIN
    IF ptr[i] EQ ptr_new() THEN ind[i]=0 ELSE ind[i]=1
ENDFOR

RETURN,where(ind)

END


