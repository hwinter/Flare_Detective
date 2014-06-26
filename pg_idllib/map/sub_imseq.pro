;+
;
; NAME:
;        sub_imseq
;
; PURPOSE: 
;        get a sequence of subimages from an image sequence 
;      
;
; CALLING SEQUENCE:
;
;        out_ptr=sub_imseq(ptr,xrange=xrange,yrange=yrange)
; 
;
; INPUTS:
;
;        ptr : an image sequence (pointer format)
;
; KEYWORDS:
;        xrange=[x1,x2]: min/max x-coord's (data units)
;        yrange=[y1,y2]: min/max y-coord's (data units)
;
;                
; OUTPUT:
;        out_ptr: subimage sequence
; CALLS:
;        sub_map
;
; VERSION:
;       
;        13-MAR-2003 written
;
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;-

FUNCTION sub_imseq,ptr,xrange=xrange,yrange=yrange

n=n_elements(ptr)
ptr2=ptr

FOR i=0,n-1 DO BEGIN
    IF ptr[i] NE ptr_new() THEN BEGIN
        sub_map,*ptr[i],submap,xrange=xrange,yrange=yrange
        ptr2[i]=ptr_new(submap)    
    ENDIF
ENDFOR

RETURN,ptr2

END

