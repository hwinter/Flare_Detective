;+
;
; NAME:
;        imseq_subseq
;
; PURPOSE: 
;
;        extract a subsequence
;
; CALLING SEQUENCE:
;
;        out_ptr=imseq_subseq(ptr,min,max)
; 
; INPUTS:
;
;        ptr: array of pointers to imseq
;        min: min frame
;        max: max frame
;                
; OUTPUT:
;        out_ptr: a pointer to the restricted sequence of images
;
; CALLS:
;      
;
; VERSION:
;       
;       25-MAR-2003 written
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;-

FUNCTION imseq_subseq,ptr,min,max

out_ptr=ptrarr(max-min+1)

FOR i=min,max DO BEGIN
    out_ptr[i-min]=ptr[i]
ENDFOR

RETURN,out_ptr

END


