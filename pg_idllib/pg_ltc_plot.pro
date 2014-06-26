;+
; NAME:
;
;   pg_ltc_plot
;
; PURPOSE:
;   plot many lightcurves on a single plot
;
;
; CATEGORY:
; 
;   spectrogram utilities
;
; CALLING SEQUENCE:
;
;   pg_ltc_plot,spg, [ ...]
;
; INPUTS:
;
;   spg: a spectrogram structure
;
; OPTIONAL INPUTS:
;
;
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
;
;   Paolo Grigis, Institute for Astronomy, ETH, Zurich
;   pgrigis@astro.phys.ethz.ch
;
; MODIFICATION HISTORY:
;
;   13-FEB-2004 written, based on hsi_plot_lowen2
;
;-


;
; INPUTS:
;      spg: a spectrogram structure like the one produced
;             by hsi_spg_ragfitswrite
;      int:rebin factor (1: 4 sec, 15: 1 min etc...)
;      timerange:time interval for the plot
;      min,max: plot y coordinates
;       

PRO pg_ltc_plot,spg,int=int,timerange=timerange,min=min,max=max $
                ,a=a,title=title,auto=auto,factor=factor


   IF not exist(int) THEN int=1

  
   l=spg.spectrogram
   time0=anytim(spg.x[0])
   dt=spg.x[1]-spg.x[0]

   dim=size(l)

   IF not keyword_set(timerange) THEN timerange=[min(spg.x)-60,$
                                                 max(spg.x)+60]

;   print,anytim(timerange,/yohkoh)

   IF not keyword_set(min) THEN min=0.01
   IF not keyword_set(max) THEN max=200000.
   
   dok=dim[1]/int 
   IF int NE 1 THEN BEGIN
      ll=l[0:dok,*]
      ll=rebin(l[0:dok*int-1,*],dok,dim[2])
   ENDIF $
   ELSE ll=l


   ;rebin part
   checkvar,energy_band,[3,6,9,12,18,25,50]
   
   lll=fltarr((size(ll))[1],n_elements(energy_band)-1)

   FOR i=0,(size(ll))[1]-1 DO BEGIN
      FOR j=0,n_elements(energy_band)-2 DO BEGIN
         ind=where(spg.y GE energy_band[j] AND spg.y LE energy_band[j+1],count)
         IF count GT 0 THEN $
           lll[i,j]=total(ll[i,min(ind):max(ind)])
      ENDFOR
   ENDFOR
   ll=lll

   ;a=[8.,27,90,140,135,80,15,3,4.5,7.7,2.3,1];for uncalibrated spectrograms

   ;good starting point for relatively quiet times, semicalibrated
   ;a=[1,0.25,0.15,0.1,0.05,0.025,0.005,0.001,0.00125,0.0025,0.001,0.0005] 
   checkvar,a,[10,1.25,1,1,0.25,0.01]

   ;proposal FOR automatic fining a...

   checkvar,factor,0.1

   IF keyword_set(auto) THEN BEGIN
      a=dblarr(n_elements(energy_band)-1)
      a[0]=1.
      FOR i=1,n_elements(a)-1 DO BEGIN
         a[i]=(factor^i)*max(ll[*,0])/max(ll[*,i])
      ENDFOR
   ENDIF
   
   ;a=a
   ;stop
   
   ;print,a
   b=n_elements(a)-1
 
   utplot,dindgen(dok)*int*dt,a[0]*ll[*,0],anytim(time0,/hxrbs), $
          timerange=anytim(timerange,/hxrbs),$
          /ylog,yrange=[1e-5,max(ll[*,0])*2], $
          ytitle='counts (scaled)'$
          ,xstyle=1,ystyle=1,ytickformat='exponent'$
          ,yminor=9,charsize=1.25,title=title

   FOR i=1,5 DO $
   outplot,dindgen(dok)*int*dt,a[i]*ll[*,i];,anytim(time,/hxrbs);,psym=10

  
   
END











