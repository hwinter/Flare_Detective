;
;OBSOLETE! NEW version hsi_imseq_plot !
;

;+
; NAME:
;       hsi_imageserie_plot
;
; PURPOSE: 
;       plot a series of images
;
; CALLING SEQUENCE:
;       hsi_imageserie_plot,ptr
;
; INPUTS:
;       ptr: array of pointers to images (at least 4 images
;       required...)
;       him,vim: number of horizontal & vertical images
;       _extra: any keyword accepted by plot_map
;
; OUTPUT:
; 
;
; HISTORY:
;       22-JAN-2002 written
;       23-JAN-2002 added _extra keyword
;
; AUTHOR:
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;-

PRO hsi_imageserie_plot,ptr,him=him,vim=vim,_extra=_extra

print,'Obsolete version! Please use hsi_imseq_plot'
; n=n_elements(ptr)

; IF (NOT keyword_set(him))OR(NOT keyword_set(vim)) THEN BEGIN
; him=floor(sqrt(18.*n/28.)) 
; vim=ceil(n/him)+1
; ENDIF

; oldp=!P
; !P.MULTI=[0,him,vim]


; FOR i=0,n-1 DO BEGIN
; plot_map,*ptr[i],_extra=_extra
; ENDFOR
; end
; !P=oldp

END

