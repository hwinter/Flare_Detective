;+
; NAME:
;
; pg_plotsp
;
; PURPOSE:
;
; plot a spectrum with errors
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
; 16-JAN-2006 pg added continuous keyword
; 
;
;-

;.comp pg_plotsp
PRO pg_plotsp,x,sp,espectrum=espectrum,xlog=xlog,ylog=ylog $
              ,xstyle=xstyle,ystyle=ystyle,xrange=xrange,yrange=yrange $
              ,overplot=overplot,_extra=_extra,continuous=continuous $
              ,nodata=nodata

  siz=size(x,/dim)

  IF n_elements(siz) NE 2 THEN BEGIN 
     print,'Please input energy edges!'
  ENDIF

  espectrum=fcheck(espectrum,sp*0.)

  IF keyword_set(xlog) THEN  mean=sqrt(product(x,2)) ELSE mean=0.5*total(x,2)

  IF NOT keyword_set(overplot) THEN BEGIN 
        plot,mean,sp,/nodata,_extra=_extra,xlog=xlog,ylog=ylog $
            ,xstyle=xstyle,ystyle=ystyle,xrange=xrange,yrange=yrange
 
       IF keyword_set(nodata) THEN return    
  ENDIF

  IF NOT keyword_set(continuous) THEN BEGIN 
 
     FOR i=0,n_elements(mean)-1 DO oplot,x[i,[0,1]],sp[i]*[1,1],_extra=_extra
     IF keyword_set(ylog) THEN BEGIN 
        FOR i=0,n_elements(mean)-1 DO oplot,mean[i]*[1,1],(sp[i]+espectrum[i]*[-1,1])>1d-33,_extra=_extra
     ENDIF ELSE BEGIN 
        FOR i=0,n_elements(mean)-1 DO oplot,mean[i]*[1,1],sp[i]+espectrum[i]*[-1,1],_extra=_extra
     ENDELSE
  ENDIF $
  ELSE BEGIN
     oplot,mean,sp,_extra=_extra
  ENDELSE
 
  IF NOT keyword_set(continuous) THEN BEGIN 

     FOR i=0,n_elements(mean)-2 DO oplot,[x[i,1],x[i+1,0]],sp[[i,i+1]],_extra=_extra

  ENDIF 

END
