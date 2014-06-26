;+
; NAME:
;
; pg_plotsp
;
; PURPOSE:
;
; plot the residuals from spectral fitting
;
; CATEGORY:
;
; spectral util
;
; CALLING SEQUENCE:
;
; pg_plotsp,e,sp,espectrum=espectrum [,all keyword accepted by plot]
;
; INPUTS:
;
; e: energy edges for the spectrum
; sp: spectrum values
;
; OPTIONAL INPUTS:
;
; espectrum: error spectrum
;
; KEYWORD PARAMETERS:
;
; 
;
; OUTPUTS:
;
; 
;
; OPTIONAL OUTPUTS:
;
;
;
; COMMON BLOCKS:
;
;
;
; SIDE EFFECTS:
;
;
;
; RESTRICTIONS:
;
;
;
; PROCEDURE:
;
;
;
; EXAMPLE:
;
;
;
; AUTHOR:
; Paolo Grigis, Institute for Astronomy, ETH Zurich
; pgrigis@astro.phys.ethz.ch 
;
; MODIFICATION HISTORY:
;
; 07-NOV-2006 pg written
; 
;
;-

;.comp pg_plotspres
PRO pg_plotspres,x,spectrum=spectrum,modspectrum=modspectrum,espectrum=espectrum,xlog=xlog,ylog=ylog $
              ,xstyle=xstyle,ystyle=ystyle,xrange=xrange,yrange=yrange $
              ,overplot=overplot,_extra=_extra

  siz=size(x,/dim)

  IF n_elements(siz) NE 2 THEN BEGIN 
     print,'Please input energy edges!'
  ENDIF

  IF keyword_set(xlog) THEN  mean=sqrt(product(x,2)) ELSE mean=0.5*total(x,2)

  residuals=(spectrum-modspectrum)/espectrum


  IF NOT keyword_set(overplot) THEN BEGIN 
     plot,mean,residuals,/nodata,_extra=_extra,xlog=xlog,ylog=ylog $
         ,xstyle=xstyle,ystyle=ystyle,xrange=xrange,yrange=yrange
  ENDIF

  FOR i=0,n_elements(mean)-1 DO oplot,x[i,[0,1]],residuals[i]*[1,1],_extra=_extra
  FOR i=0,n_elements(mean)-2 DO oplot,[x[i,1],x[i+1,0]],residuals[[i,i+1]],_extra=_extra

END
