;+
;NAME:
; 	rapp_plt_spg.pro
;PROJECT:
; 	ETHZ Radio Astronomy
;CATEGORY:
; 	Utility
;PURPOSE:
; This routine displays a 2d array (spectrogram) with axes. 
; Modified version of rapp_plt_spg.pro, that allows for greater flexibility.
;
;CALLING SEQUENCE:
; rapp_plot_spectrogram, histp,  xaxisp,  yaxisp, PS=ps  
;      TITLE=title,  XTITLE=xtitle,  YTITLE=ytitle,    $
;      XTICKNAME=xtickname, YTICKNAME=ytickname,       $
;      INTERPOLATE=interpolate,  INVERT=invert,        $
;      YLOG=ylog,  XLOG=xlog,                          $
;      XRESAMPLE=xresample, YRESAMPLE=yresample

;
;INPUT:
; histp	 : 	2d array (spectrogram)
; 
;
;OPTIONAL INPUT:
; xaxisp: 	xaxis values of the spectrogram 
; yaxisp:      	yaxis values of the spectrogram 
;
;KEYWORD INPUT:
; PS	     : 	Generate plot for ps device. Does not change the device itself.
; [X,Y]TITLE :	(string) Title of the plot or the axis 
; [X,Y]LOG   :	plot axis on log scale
; [X,Y]RESAMPLE: takes a vector of new x or y values and resamples the spectrogram
;                accrodingly. If the keyword is set to a scalar integer x, the axis
;                interval is resampled x times.
; INTERPOLATE: 	Interpolate the spectrogram 
; INVERT :	Inverts the spectrogram
; UT :		If set, will use 'utplot' instead of 'plot'.
; _EXTRA: passed on to the plot routine
;
;OUTPUT:
; Plots a spectrogram
;
;CALLS
;	uses only IDL standard routines
;
;
;
;HISTORY:
;	Peter Messmer, 2002/05/02 created
;		messmer@astro.phys.ethz.ch
;
;	PSH 2002/11/18 : added keyword /UT 
;	PSH 2002/11/25 : added _extra keyword to pass along to the plot/utplot routine
;-

PRO rapp_plt_spg,  histp,  xaxisp,  yaxisp,  $
      PS=ps,  XTITLE=xtitle,  YTITLE=ytitle,  $
      TITLE=title,  INTERPOLATE=interpolate,  YLOG=ylog,  XLOG=xlog,$
      xresample=xresample, yresample=yresample, $
      XTICKNAME=xtickname, YTICKNAME=ytickname, INVERT=invert, UT=ut, _extra=_extra

 IF KEYWORD_SET(PS) THEN invert = 1 ELSE invert = 0
 IF NOT KEYWORD_SET(INTERPOLATE) THEN interpolate = 0
 IF NOT KEYWORD_SET(YLOG) THEN ylog = 0
; IF NOT KEYWORD_SET(XTICKNAME) THEN xtickname=''
; IF NOT KEYWORD_SET(YTICKNAME) THEN ytickname=''
 IF KEYWORD_SET(UT) THEN plot_procedure='utplot' ELSE plot_procedure='plot'

 invert = 0

 hist = histp
 if n_elements(histp) eq 1 then return 

 IF (size(hist))(0)  NE 2 THEN hist =  reform(hist)
 nx = (size(hist))[1]
 ny = (size(hist))[2]


 IF (size(xaxisp))(0) EQ 0 THEN xaxisp = lindgen(nx)
 IF (size(yaxisp))(0) EQ 0 THEN yaxisp = lindgen(ny)

 xaxis = xaxisp
 yaxis = yaxisp

 IF keyword_set(invert) THEN hist =  max(hist) - hist


 IF KEYWORD_SET(XRESAMPLE) THEN BEGIN
   xaxis_old = xaxis

   IF n_elements(xresample) eq 1 THEN BEGIN  ; resample according to given resolution
     IF xresample LT 0 THEN nsx = nx ELSE nsx = xresample
     IF NOT KEYWORD_SET(XLOG) THEN BEGIN
      xaxis = findgen(nsx) * (xaxis_old[nx-1] - xaxis_old[0]) / (nsx-1) + xaxis_old[0]
     ENDIF ELSE BEGIN 
      xaxis = (xaxis_old[nx-1]/xaxis_old[0])^(findgen(nsx)/(nsx-1)) * xaxis_old[0]
     ENDELSE

   ENDIF ELSE BEGIN                          ; resample according to given new axis
     xaxis = xresample
     nsx   = n_elements(xresample)
   ENDELSE


   ht = fltarr(nsx, ny)

   FOR i=0, ny-1 DO BEGIN
    ht(*, i) = interpol(hist(*, i), xaxis_old, xaxis)
   END

   hist = ht
   nx = nsx
 ENDIF 

 IF KEYWORD_SET(YRESAMPLE) THEN BEGIN
    yaxis_old = yaxis
    IF n_elements(yresample) eq 1 THEN BEGIN
      IF yresample lt 0  THEN nsy = ny ELSE nsy = yresample
      IF NOT KEYWORD_SET(YLOG) THEN BEGIN
          yaxis = findgen(nsy) * (yaxis_old[ny-1] - yaxis_old[0]) / (nsy-1) + yaxis_old[0]
      ENDIF ELSE BEGIN 
          yaxis = (yaxis_old[ny-1]/yaxis_old[0])^(findgen(nsy)/(nsy-1)) * yaxis_old[0]
      ENDELSE

    ENDIF ELSE BEGIN 
      yaxis = yresample
      nsy = n_elements(yaxis)
    ENDELSE

   ht = fltarr(nx, nsy)

   FOR i=0, nx-1 DO BEGIN
    ht(i, *) = interpol(hist(i, *), yaxis_old, yaxis)
   END

   hist = ht
   ny = nsy
 ENDIF 

 nx = n_elements(xaxis)
 ny = n_elements(yaxis)

 IF NOT KEYWORD_SET(XLOG) THEN BEGIN
   dx =  xaxis(1) - xaxis(0)
   xrange = [xaxis(0)-dx/2., xaxis(nx-1)+dx/2.]
 ENDIF ELSE BEGIN
   dx =  xaxis(1) / xaxis(0)
   xrange = [xaxis(0)/sqrt(dx), xaxis(nx-1)*sqrt(dx)]
 ENDELSE

 IF NOT KEYWORD_SET(YLOG) THEN BEGIN
   dy =  yaxis(1) - yaxis(0)
   yrange = [yaxis(0)-dy/2., yaxis(ny-1)+dy/2.]
 ENDIF ELSE BEGIN
   dy =  yaxis(1) / yaxis(0)
   yrange = [yaxis(0)/sqrt(dy), yaxis(ny-1)*sqrt(dy)]
 ENDELSE



 call_procedure, plot_procedure,  xaxis,  yaxis, /nodata,	$
        xrange = xrange, yrange=yrange,       			$
        xstyle = 1, ystyle = 1,               			$
        xtitle = xtitle,  ytitle=ytitle,  charsize=1.5, 	$
        title = title,  ylog=ylog, xlog=xlog, 			$
        xtickname=xtickname,ytickname=ytickname,_extra=_extra

 im_size = convert_coord(!x.window, !y.window, /normal, /to_device)
 npixx =  round(im_size(0,1) - im_size(0,0))
 npixy =  round(im_size(1,1) - im_size(1,0))
 
 IF keyword_set(PS) THEN BEGIN
  npixx =  npixx / 50.
  npixy =  npixy / 50.
 ENDIF 
 
 hist_tmp = congrid(hist,  npixx,  npixy,  cubic=interpolate)


 IF keyword_set(PS) THEN BEGIN
     tvscl, hist_tmp, !x.window(0), !y.window(0), /normal,  $
     xsize= !x.window(1) - !x.window(0),  $
     ysize=!y.window(1) - !y.window(0)
 ENDIF ELSE BEGIN
    tvscl, hist_tmp, !x.window(0), !y.window(0), /normal
 ENDELSE

 !p.multi[0] = !p.multi[0] + 1 

 ; we have to repaint the axes and ticks as they might have been overwritten
 ; by the tv routine. 
call_procedure, plot_procedure,   xaxis,  yaxis, /nodata,	$
        xrange=xrange, yrange=yrange,          			$
        xstyle=1, ystyle=1,                    			$
        xtitle='',  ytitle='',  charsize=1.5,  			$
        ylog=ylog, xlog=xlog,                  			$
        xtickname=make_array(n_elements(!x.tickname), value=' ', /string), $
        ytickname=make_array(n_elements(!x.tickname), value=' ', /string), $ 
        color=255,_extra=_extra
END 



