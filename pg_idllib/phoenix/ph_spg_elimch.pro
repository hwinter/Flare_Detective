;+
; NAME:
;       ph_spg_elimch
;
; PURPOSE: 
;       eliminate wrong channels from an array of pointer to spectrograms
;
; CALLING SEQUENCE:
;       outptr=ph_spg_elimch(ptr)
;
; INPUTS:
;       ptr: a pointer array, each pointer should point to a
;       spectrogram (null pointers allowed)
;
; OUTPUT:
;       ptr, an array of pointer to spg structures
;
; HISTORY:
;       18-DEC-2002 written
;
; AUTHOR:
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;-

FUNCTION ph_spg_elimch,ptr

ptr2=ptrarr((size(ptr))[1])

FOR i=0,(size(ptr))[1]-1 DO BEGIN
    IF ptr[i] NE ptr_new() THEN BEGIN
        image=(*ptr[i]).spectrogram
        x=(*ptr[i]).x
        y=(*ptr[i]).y
        ElimWrongChannels,image,anytim(x,/time),y,/show
  
        ptr2[i]=ptr_new({spectrogram:image,x:(*ptr[i]).x,y:y})
  
    ENDIF
ENDFOR

RETURN,ptr2

END
