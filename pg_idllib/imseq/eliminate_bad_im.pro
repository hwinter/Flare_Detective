;+
;
; NAME:
;        eliminate_bad_im
;
; PURPOSE: 
;        eliminate bad images from a sequence
;
; CALLING SEQUENCE:
;
;        ptr_out=eliminate_bad_im(ptr_in)
;
; INPUTS:
;
;        ptr_in: pointer ot an image seq
;
; OUTPUT:
;        ptr_out: pointer to an image seq  
;
; VERSION:
;
;        10-JUN-2003 written
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;-

FUNCTION eliminate_bad_im,ptr_in

notgood=bytarr(n_elements(ptr_in))

FOR i=0,n_elements(ptr_in)-1 DO BEGIN

    tot=total(finite((*ptr_in[i]).data))

    IF tot EQ 0 THEN notgood[i]=1B  

ENDFOR

wh=where(notgood EQ 0,count)
IF count GT 0 THEN BEGIN
    ptr_out=ptrarr(count)
    ptr_out=ptr_in[wh]
ENDIF ELSE ptr_out=ptr_new()

RETURN,ptr_out

END











