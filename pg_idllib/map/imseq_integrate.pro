;+
;
; NAME:
;        imseq_integrate
;
; PURPOSE: 
;        produces a new image sequence with each image as the sum of n
;        images of the inout sequence
;      
;
; CALLING SEQUENCE:
;
;        out_ptr=imseq_integrate(ptr,n)
; 
;
; INPUTS:
;        ptr : a pointer array to map structures
;        n: an integer number
;
; KEYWORDS:
;        
;                
; OUTPUT:
;        out_ptr: the integrated image sequence        
;
; CALLS:
;       
;
; VERSION:       
;        18-MAR-2003 written
;
; AUTHOR
;        Paolo Grigis, Institute for Astronomy, ETH, Zurich
;-

FUNCTION imseq_integrate,ptr,n

nel=n_elements(ptr)
d=(nel/n)
out_ptr=ptrarr(d)

FOR i=0,d-1 DO BEGIN
  map=summaps(ptr,min=i*n,max=(i+1)*n-1)
  out_ptr[i]=ptr_new(map)
ENDFOR

RETURN,out_ptr

END



