;+
; NAME:
;      plot46
;
; PURPOSE: 
;      plot a lightcurve of a given (RHESSI) spectrogram in the bin
;      1+2
;      (RHESSI 4-6 keV) 
;
; INPUTS:
;      spg: a spectrogram structure like the one produced
;             by hsi_spg_ragfitswrite
;      int:rebin factor (1: 4 sec, 15: 1 min etc...)
;      timerange:time interval for the plot
;       
; KEYWORDS:
;        
;
; HISTORY:
;       modification of hsi_plot_lowen
;       29-OCT-2002 written
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;
;-

PRO plot46,int=int,timerange=timerange,spg=spg


   IF not exist(int) THEN int=1

  
   l=spg.spectrogram
   time0=anytim(spg.x[0])
   dt=spg.x[1]-spg.x[0]

   dim=size(l)

   IF not keyword_set(timerange) THEN timerange=[min(spg.x),$
                                                 max(spg.x)]

   
   dok=dim[1]/int ;

   IF int NE 1 THEN BEGIN
   ll=l[0:dok,*]
   ll=rebin(l[0:dok*int-1,*],dok,dim[2])
   ENDIF $
   ELSE ll=l

   
   lll=fltarr((size(ll))[1],6)

   FOR i=0,(size(ll))[1]-1 DO lll[i,0]=total(ll[i,1:2])

   ll=lll
 
   min=0
   max=max(lll)*1.1
 
   utplot,dindgen(dok)*int*dt,ll[*,0],anytim(time0,/hxrbs), $
          timerange=anytim(timerange,/hxrbs),$
          yrange=[min,max], $
          ytitle='counts (scaled)'$
          ,xtitle=title,xstyle=1,ystyle=1;,$;ytickformat='exponent'$
          ;,yminor=9,charsize=1.25

   ;FOR i=1,2 DO $
   ;outplot,dindgen(dok)*int*dt,a[i]*ll[*,i];,anytim(time,/hxrbs);,psym=10

  
   ;IF keyword_set(file) THEN BEGIN

   ;filename='/global/tethys/data1/pgrigis/vlahessi/graphs/' $
   ;        +'plotltcD'+anytim(time,/ccsds)+'.png'

   ;img=tvrd(/true) 
   ;tvlct,r,g,b,/GET
   ;write_png,filename,img,r,g,b

   ;ENDIF
   
END











