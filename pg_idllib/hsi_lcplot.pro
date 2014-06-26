;+
; NAME:
;      hsi_lcplot
;
; PURPOSE: 
;      plot lightcurves from a spectrogram structure 
;
; INPUTS:
;      spg: a spectrogram structure like the one produced
;             by hsi_spg_ragfitswrite
;      int:rebin factor (1: 4 sec, 15: 1 min etc...)
;      timerange:time interval for the plot
;      min,max: plot y coordinates
;      energy_band: energy bands to plot
;       
; KEYWORDS:
;      autoscale: try to find a good scaling automatically  
;      autotitle: automatic x title with energy bands used
;      divbychannel: normalize dividing by the channel number
;
; HISTORY:
;       10-DEC-2002 written, based upon hsi_plot_lowen, but more
;       flexible
;       14-JAN-2003 added autoscale capabilities+autotitle
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;
;-

PRO hsi_lcplot,int=int,timerange=timerange,spg=spg,exponent=exponent, $
               min=min,max=max,energy_band=energy_band,_extra=_extra, $
               scaling=scaling,overplot=overplot,offset=offset, $
               autoscale=autoscale,printfactor=printfactor,outscaling=a, $
               autotitle=autotitle,divbychannel=divbychannel


   IF not exist(offset) THEN offset=0

   IF not exist(int) THEN int=1

   ;IF keyword_set(ylog) THEN print,'ylog'
  
   l=spg.spectrogram
   time0=anytim(spg.x[0])
   dt=spg.x[1]-spg.x[0]

   dim=size(l)

   IF not keyword_set(timerange) THEN timerange=[min(spg.x)-60,$
                                                 max(spg.x)+60]

   ;print,anytim(timerange,/yohkoh)
  
   dok=dim[1]/int ;
   IF int NE 1 THEN BEGIN
   ll=l[0:dok,*]
   ll=rebin(l[0:dok*int-1,*],dok,dim[2])
   ENDIF $
   ELSE ll=l


   IF n_elements(energy_band) GT 1 THEN BEGIN
 
       dim=size(energy_band)
           
       IF dim[0] EQ 1 THEN BEGIN
           channum=dim[1]-1
           lll=fltarr((size(ll))[1],dim[1]-1)

           ;print,channum
           
           FOR i=0,channum-1 DO BEGIN

               ind=where((spg.y GE energy_band[i]) AND $
                         (spg.y LE energy_band[i+1]))

               ;print,ind,' --- '
              

               FOR j=0,(size(ll))[1]-1 DO lll[j,i]=total(ll[j,ind])


           ENDFOR         
  
           IF keyword_set(divbychannel) THEN BEGIN
               lll=lll/n_elements(ind)
               print,n_elements(ind)
           ENDIF

       ENDIF $
       ELSE BEGIN
           IF dim[0] EQ 2 THEN BEGIN
               channum=dim[2]
               lll=fltarr((size(ll))[1],dim[2])
               FOR i=0,channum-1 DO BEGIN

                   ind=where((spg.y GE energy_band[0,i]) AND $
                             (spg.y LE energy_band[1,i]))
                   ;print,ind,' --- '   
                   FOR j=0,(size(ll))[1]-1 DO lll[j,i]=total(ll[j,ind])

               IF keyword_set(divbychannel) THEN BEGIN
                   lll=lll/n_elements(ind)
                   print,n_elements(ind)
               ENDIF

               ENDFOR 
           ENDIF $
           ELSE RETURN
    
       ENDELSE
   
   ENDIF $
   ELSE BEGIN
       RETURN
   ENDELSE
   

;
;a allow to scale the different bands
;

   index=where(dindgen(dok)*int*dt GT anytim(timerange[0])-time0 AND dindgen(dok)*int*dt LT anytim(timerange[1])-time0)
   

   IF keyword_set(autoscale) THEN BEGIN ;autoscaling

       d=(size(lll))[2]
       scaling=dblarr(d)
       min0=min(lll[index,0])>1d-2

       scaling[0]=1
       FOR i=1,d-1 DO $
           scaling[i]=(10d^(-i))*min0/(min(lll[index,i])>1d-2)
       ;stop
       a=scaling

       IF keyword_set(printfactor) THEN $
         print,a
       ;print,min0
       ;print,min(lll[index,1])

   ENDIF $
   ELSE BEGIN $
     
       IF NOT exist(scaling) THEN $
           a=replicate(1.,channum) $
       ELSE BEGIN
           IF (n_elements(scaling) EQ channum) AND $
              ((size(scaling))[0] EQ 1) THEN $
              a=scaling $
           ELSE RETURN
       ENDELSE
   ENDELSE
 

;
; offset set a constant offset to the data
;
lll=lll+offset



   IF not keyword_set(min) THEN min=(min(lll[index,*])*min(a))>1e-6
   IF not keyword_set(max) THEN max=max(lll[index,*])
 

IF keyword_set(autotitle) THEN BEGIN
    str=strtrim(energy_band,2)
    title='Energy Bands:'
    FOR i=0,(size(str))[1]-2 DO $
        title=title+' '+str[i]+'-'+str[i+1]
    title=title+' keV'
END


IF not keyword_set(overplot) THEN $
   IF keyword_set(exponent) THEN $
   utplot,dindgen(dok)*int*dt,a[0]*lll[*,0],anytim(time0,/hxrbs), $
          timerange=anytim(timerange,/hxrbs) $
          ,yrange=[min,max], $
          ytitle='counts (scaled)'$
          ,title=title,xstyle=1,ystyle=1,ytickformat='exponent' $
          ,yminor=9,charsize=1.25,_extra=_extra $
   ELSE $
   utplot,dindgen(dok)*int*dt,a[0]*lll[*,0],anytim(time0,/hxrbs), $
          timerange=anytim(timerange,/hxrbs),$
          yrange=[min,max], $
          ytitle='counts (scaled)'$
          ,title=title,xstyle=1,ystyle=1$
          ,yminor=9,charsize=1.25,_extra=_extra $
ELSE  outplot,dindgen(dok)*int*dt,a[0]*lll[*,0],anytim(time0,/hxrbs),_extra=_extra


   FOR i=1,channum-1 DO $
   outplot,dindgen(dok)*int*dt,a[i]*lll[*,i],anytim(time0,/hxrbs),_extra=_extra

 
END











