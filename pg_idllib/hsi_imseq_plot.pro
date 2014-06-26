;+
; NAME:
;       hsi_imseq_plot
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
;       minframe,maxframe: restrict the plot to images lying
;       between minframe and maxframe
;       _extra: any keyword accepted by plot_map
;
; OUTPUT:
; 
;
; HISTORY:
;       22-JAN-2003 written
;       23-JAN-2003 added _extra keyword
;       27-JAN-2003 renamed & added null pointer check
;       10-MAR-2003 added minframe & maxframe and beam keywords
;
; AUTHOR:
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;-

PRO hsi_imseq_plot,ptr,him=him,vim=vim,minframe=minframe $
                  ,maxframe=maxframe,beam=beam,_extra=_extra

n=n_elements(ptr)

IF (NOT keyword_set(him))OR(NOT keyword_set(vim)) THEN BEGIN
him=floor(sqrt(18.*n/28.)) 
vim=ceil(n/him)+1
ENDIF

oldp=!P
!P.MULTI=[0,him,vim]

startn=0
endn=n-1
IF keyword_set(minframe) THEN startn=minframe
IF keyword_set(maxframe) THEN endn=maxframe

FOR i=startn,endn DO BEGIN
    IF ptr[i] NE ptr_new() THEN BEGIN
        plot_map,*ptr[i],_extra=_extra
        IF keyword_set(beam) THEN BEGIN
            IF !D.NAME EQ 'PS' THEN BEGIN
                beamcolor=0
                bgcolor=255
            ENDIF ELSE BEGIN
                beamcolor=1
                bgcolor=0
            ENDELSE
            beam_plot,beam,beamcolor=beamcolor,bgcolor=bgcolor
        ENDIF
    ENDIF
ENDFOR
end
!P=oldp

END

