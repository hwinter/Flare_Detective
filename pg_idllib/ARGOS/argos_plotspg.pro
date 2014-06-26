;+
; NAME:
;      argos_plotspg
;
; PURPOSE: 
;      produce a nice overview plot of a spectrum 
;
; PROCEDURE:
;      
;
; CALL SEQUENCE:
;      argos_plotspg,spg [,n_spec=n_spec]
;
;
; INPUTS:
;     spg: a spectrogram
;     n_spec: optional parameter to indicate which spectrum to plot,
;             if not specified, the integrated spectrum is plotted
;             
;  
; OUTPUTS:
;     
;
; HISTORY:
;     17-MAR-2004 written PG
;     
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;       pgrigis@astro.phys.ethz.ch
;
;-

PRO argos_plotspg,spg,n_spec=n_spec,err=err,overplot=overplot,_extra=_extra

err=0

;input checking
IF (size(spg,/tname) NE 'STRUCT') THEN BEGIN
    print,'Please input a valid spectrogram!'
    err=1
    RETURN
ENDIF

;check if I have to integrate the calibration spectra...
ntime=n_elements(spg.x)

IF NOT exist(n_spec) THEN  BEGIN
    IF ntime EQ 1 THEN $
        sp=spg.spectrogram[0,*] $
    ELSE BEGIN 
        spgint=argos_intspg(spg)
        sp=spgint.spectrogram[0,*]
    ENDELSE 
ENDIF ELSE BEGIN
    IF (n_spec GE 0) AND (n_spec LE (ntime-1)) THEN $
        sp=spg.spectrogram[n_spec,*] $
    ELSE BEGIN
        err=1
        print,'INVALID n_spec!'
        RETURN
    ENDELSE
ENDELSE

IF tag_exist(spg,'YOFFSET') THEN yoffset=spg.yoffset ELSE yoffset=0.


IF NOT keyword_set(overplot) THEN $
    plot,spg.y+yoffset,sp,_extra=_extra $
ELSE $
    oplot,spg.y+yoffset,sp,_extra=_extra
 
END



