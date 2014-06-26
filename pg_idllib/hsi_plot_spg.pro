;+
; NAME:
;       HSI_PLOT_SPG
;
; PURPOSE: 
;       Plot a spectrogram. Need a spg structure as input.
;
; CALLING SEQUENCE:
;       hsi_plot_spg,spg
;
; INPUTS:
;       time_intv: time range to plot
;       
; KEYWORDS:
;       highenergy: if set, a spectrogram with energy range from 3 to
;		    1?00 keV with logarithmic scale is displayed.
;		    In the other case the spectrogram goes from 3 to 50
;		    keV with a linear scale
;
; VERSION
;       0.1 14-JAN-2002
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;-

PRO HSI_PLOT_SPG,spg,time_intv=time_intv,loadcolor=loadcolor,_extra=_extra

IF keyword_set(loadcolor) THEN loadct,5

time=spg.x
energy=spg.y
data=spg.spectrogram

time0=time[0]
time=time-time0

IF n_elements(time_intv) EQ 2 THEN BEGIN
    xrange=[anytim(time_intv[0])-time0,anytim(time_intv[1])-time0]
    ;time0=anytim(time_intv[0])
ENDIF $
ELSE $
  xrange=[min(time),max(time)]

set_utplot,xrange=xrange,utbase=time0

spg_max_value=max(data)       
lev=findgen(256)/255*alog(spg_max_value)
lev=exp(lev)-1
            
contour,data,time,energy,xrange=xrange,/fill,/ylog,levels=lev,ystyle=1, $
        yrange=[min(energy),max(energy)],xstyle=1, $
        ytitle='Energy (keV)',title='RHESSI Spectrogram.'+ $
        ' MAX Counts per second per keV:'+ $
        string(spg_max_value), $
        xtitle=anytim(time0,/yohkoh,/date),_extra=_extra


END



