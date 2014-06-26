;+
; NAME:
;      hsi_plot_lowen
;
; PURPOSE: 
;      plot the low energy RHESSI channels lightcurves 
;
; INPUTS:
;      spg: a spectrogram structure like the one produced
;             by hsi_spg_ragfitswrite
;      int:rebin factor (1: 4 sec, 15: 1 min etc...)
;      timerange:time interval for the plot
;      min,max: plot y coordinates
;       
; KEYWORDS:
;        
;
; HISTORY:
;       7-OCT-2002 (re)written, based on makelight & hessiplot
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;
;-

PRO hsi_plot_lowen,int=int,timerange=timerange,spg=spg,$
                   min=min,max=max


   IF not exist(int) THEN int=1

  
   l=spg.spectrogram
   time0=anytim(spg.x[0])
   dt=spg.x[1]-spg.x[0]

   dim=size(l)

   IF not keyword_set(timerange) THEN timerange=[min(spg.x)-60,$
                                                 max(spg.x)+60]

   print,anytim(timerange,/yohkoh)

   IF not keyword_set(min) THEN min=0.0002
   IF not keyword_set(max) THEN max=1200
   
   dok=dim[1]/int ;
   IF int NE 1 THEN BEGIN
   ll=l[0:dok,*]
   ll=rebin(l[0:dok*int-1,*],dok,dim[2])
   ENDIF $
   ELSE ll=l

   dim=size(y)

   ;a=[8.,27,90,140,135,80,15,3,4.5,7.7,2.3,1];for uncalibrated spectrograms

   ;good starting point for relatively quiet times, semicalibrated
   a=[1,0.25,0.15,0.1,0.05,0.025,0.005,0.001,0.00125,0.0025,0.001,0.0005] 

   utplot,dindgen(dok)*int*dt,a[0]*ll[*,0],anytim(time0,/hxrbs), $
          timerange=anytim(timerange,/hxrbs),$
          /ylog,yrange=[min,max], $
          ytitle='counts (scaled)'$
          ,xtitle=title,xstyle=1,ystyle=1,ytickformat='exponent'$
          ,yminor=9,charsize=1.25

   FOR i=1,11 DO $
   outplot,dindgen(dok)*int*dt,a[i]*ll[*,i];,anytim(time,/hxrbs);,psym=10

  
   ;IF keyword_set(file) THEN BEGIN

   ;filename='/global/tethys/data1/pgrigis/vlahessi/graphs/' $
   ;        +'plotltcD'+anytim(time,/ccsds)+'.png'

   ;img=tvrd(/true) 
   ;tvlct,r,g,b,/GET
   ;write_png,filename,img,r,g,b

   ;ENDIF
   
END











