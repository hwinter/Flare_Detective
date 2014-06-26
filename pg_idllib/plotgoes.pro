;+
; NAME:
;      plotgoes
;
; PURPOSE: 
;      get, rebin & plot goes data
;
; CALLING SEQUENCE:
;      plotgoes,time [ ,optional keywords]
;
; INPUTS:
;      time: time_interval for the plot (any format accepted by anytim)
;
; KEYWORDS:
;      int: integrate the goes data by a factor int (must be a byte)
;           default:1
;      channel: 1= low_energy, 2= high_energy, 3= both
;               default: 1 
;      mulfactor: multiplicative factor for the flux, useful for
;                 plotting the high energy channel over the low energy
;                 channel. Affects only the plots, not the returned data
;                 default=1 
;      sat: goes satellite number (only 8 and 10 allowed, 8 default)
;      timegoes: time array (rebinned by a factor int) 
;      datagoes: data array (rebinned by a factor int); can have 1 or 2
;                element depending on the value of channel        
;      noplot: inhibits plotting
;      overplot: overplots instead of plotting
;      all the keyword allowed accepted by (ut)plot are allowed  
;
; OUTPUT:
;      timegoes & datagoes return the (rebinned) goes times & data 
;       
;
; COMMENT:
;      GOES 3 seconds data from goes 8 or 10 must be present locally.
;      That can be installed using ydb_install.
;      If they aren't installed, the routine will crash
;      Somewhat easier to use than goesplot, here you can use all 
;      keyword accepted by plot. 
;
; EXAMPLE   
;  time_intv=['22-JUL-2002 22:00','23-JUL-2002 04:00']
;  linecolors
;  plotgoes,time_intv,/ylog,int=5,yticklen=1,color=9,yrange=[1e-8,1e-3]
;  plotgoes,time_intv,int=5,color=12,channel=2,/over 
;
;
;
; VERSION:
;       24-JUN-2002 written
;       ...         changed several times
;       03-OCT-2002 extensively rewritten & renamed to avoid conflict
;                   with ssw/packages/goes/idl/goesplot.pro
;                   Now the keyword for plotting are given directly to
;                   utplot, if a range is not specified an automatic
;                   choice will be made. Old keyword won't work
;                   anymore
;       24-OCT-2002 modified loop index variable to be of longword type
;
; AUTHOR:
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;-

PRO plotgoes,time,int=int,timegoes=timegoes,datagoes=datagoes,$
             channel=channel,_extra=e,overplot=overplot,sat=sat,$
             mulfactor=mulfactor,noplot=noplot

;----------------------------------------
;error checking & variable initialization
;----------------------------------------

   IF n_elements(time) NE 2 THEN time='26-FEB-2002 '+['10:20','10:40']

   IF NOT exist(mulfactor) THEN mulfactor=1
   IF mulfactor EQ 0 THEN return

   IF NOT exist(sat) THEN sat=8

   IF exist(int) THEN n=fix(int>1) ELSE n=1  

   IF NOT exist(channel) THEN channel=1


;-----------------------------------------------------
;get goes 3 seconds data
;if data is not present in the right directory will halt
;use ydb_install first!
;-----------------------------------------------------

   IF sat EQ 10 THEN $
      rd_goes,timegoes,datagoes,trange=anytim(time,/yohkoh),/goes10 $
   ELSE $
      rd_goes,timegoes,datagoes,trange=anytim(time,/yohkoh),/goes8 

   IF NOT exist(datagoes) THEN BEGIN
      print,'No goes data available in the time range '+$
            anytim(time[0],/yohkoh)+' to '+$
            anytim(time[1],/yohkoh)
      return
   ENDIF

;-----------------------------------------------------
;data rebinning
;----------------------------------------------------

   dim=size(datagoes)
   d=dim[1]
   max=d
 
   timegoes=anytim(timegoes)
   dimm=size(timegoes)
  
   max=d/n*n ; looks kind of magic, but it works...| IDL>print,5/2 
             ;                                     |       2
             ; rebin need that the size of the original array is a
             ; multiple of the rebin factor, therefore the last few
             ; elements of datagoes are dumped. max is the greatest
             ; integer number LE d that is divisible by n

   datagoes=rebin(datagoes[0:max-1,*],max/n,2)
        
   modtim=dblarr(max/n); now rebin the times

   FOR i=0L,((max/n)-1) DO BEGIN
      modtim[i]=timegoes[i*n]+(n-1)*3/2.
   ENDFOR

   timegoes=anytim(modtim,/hxrbs)

;------------------------------------------------------
;select only the data from the wanted channel
;------------------------------------------------------


   tmp=datagoes
   IF channel EQ 1  THEN BEGIN
   datagoes=dblarr((size(tmp))[1])
   datagoes=tmp[*,0]
   END

   IF channel EQ 2  THEN BEGIN
   datagoes=dblarr((size(tmp))[1])
   datagoes=tmp[*,1]
   END
   

;------------------------------------------------------
;Data plotting, if needed
;------------------------------------------------------ 

   IF NOT keyword_set(noplot) THEN BEGIN
 
      datagoes=datagoes*mulfactor
      IF channel NE 3 THEN BEGIN

         IF keyword_set(overplot) THEN $
            outplot,timegoes,datagoes[*,0],_extra=e $
         ELSE BEGIN
            ymin=0.9*min(datagoes)
            ymax=1.1*max(datagoes)
            utplot,timegoes,datagoes,timerange=time,$
                   ytitle='GOES flux',$;ytitle='W m!A-2',
                   yrange=[ymin,ymax],ytickformat='tickgoes',_extra=e
         ENDELSE   
      ENDIF $
      ELSE BEGIN
         IF keyword_set(overplot) THEN BEGIN
            outplot,timegoes,datagoes[*,0],_extra=e
            outplot,timegoes,datagoes[*,1],_extra=e
         ENDIF $
         ELSE BEGIN 
            ymin=0.9*min(datagoes[*,1])
            ymax=1.1*max(datagoes[*,0])
            utplot,timegoes,datagoes[*,0],timerange=time,$
                   ytitle='Goes flux',$;ytitle='W m!A-2',
                   yrange=[ymin,ymax],ytickformat='tickgoes',_extra=e
            outplot,timegoes,datagoes[*,1]

         ENDELSE
      ENDELSE
      datagoes=datagoes/mulfactor

   ENDIF

END







