;+
; NAME:
;      plot_hsi_spg
;
; PURPOSE: 
;      plot a spectrogram using contourplot from an input spectrogram
;      structure
;      
;
; CALLING SEQUENCE:
;      plot_hsi_spg,spg
;
; INPUTS:
;      spg: a spectrogram structure
;
; KEYWORDS:
;  
;
; OUTPUT:
;   
;       
;
; COMMENT:
;    
;
; VERSION:
;      
;       04-OCT-2002 written, based on hsi_spg_bgs
;
; AUTHOR:
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;-


PRO plot_hsi_spg,spg

   spectrogram=spg.spectrogram
   x=spg.x
   y=spg.y

   x=anytim(x)
   x=x-min(x)
   
   dt=(x[1]-x[0])/2

   spg_max_value=max(spectrogram)
   spg_min_value=min(spectrogram)


   IF (spg_max_value GT 0) THEN BEGIN
;
;        the colour scale is logarithmic
;
      lev=findgen(256)/255*alog(spg_max_value)
      lev=exp(lev)-1

      contour,spectrogram,x,y,/fill,/ylog,levels=lev,ystyle=1, $
	    yrange=[min(y),max(y)],xrange=[0,max(x)],xstyle=1, $
            ytitle='Energy (keV)',title='RHESSI Spectrogram.'+ $
            ' MAX Counts :'+ $
            string(spg_max_value), $
            xtitle='Seconds from '+anytim(min(anytim(spg.x)-dt),/yohkoh)
   ENDIF $
   ELSE BEGIN
     print,'Problems with the data!'
   ENDELSE   

END









