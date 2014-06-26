; NAME:
;       HEDC_HSI_SPG_BGS
;
; PURPOSE: 
;       Make a spectrogram from RHESSI data, with background subtraction
;
; CALLING SEQUENCE:
;       hedc_hsi_spg, time_intv, bg_time_intv, /high_energy
;
; INPUTS:
;       time_intv: an anytim time interval, e.g. a 2-array of seconds
;                  from 1-Jan-1979. time_intv[1]-time_intv[0] should
;                  be a multiple of 4
;       bg_time_intv: time interval to use for background subtraction
;       
; KEYWORDS:
;       highenergy: if set, a spectrogram with energy range from 3 to
;		    1?00 keV with logarithmic scale is displayed.
;		    In the other case the spectrogram goes from 3 to 50
;		    keV with a linear scale
;
; VERSION
;       1.0 28-03-2002
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich


PRO HEDC_HSI_SPG,time_intv,bg_time_intv,high_energy=e

   IF keyword_set(e) THEN $
      BEGIN
;
;     the energy bins are unevenly spaced:   1 kev in the range 3-100
;					    10 kev in the range 100-1000
;                                          100 kev in the range 1000-17000
;
      energy_band=fltarr(348)
      energy_band[0:97]=findgen(98)+3  
      energy_band[98:187]=(1+findgen(90))*10+100
      energy_band[188:347]=(1+findgen(160))*100+1000
      y=energy_band[0:346]
      ymax=max(y)     
      ENDIF $
   ELSE $
      BEGIN

;
;     energy bin of 1 kev from 3 to 50
;
      energy_band=findgen(49)+3 
      y=findgen(48)+3
      ymax=50
      ENDELSE
 
      lc=hsi_lightcurve()
      lc->set,obs_time_interval=time_intv
      lc->set,ltc_time_resolution=4 
      lc->set,seg_index_mask=[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1] 
      lc->set,ltc_energy_band=energy_band

      delta_t=time_intv[1]-time_intv[0]
      x=findgen(delta_t/4)*4
      lc->set,ltc_time_range=[0,delta_t]

      spectrogram=lc->getdata()
      spectrogram=spectrogram/4 

;
; Background subtraction
;
      tmp=size(bg_time_intv)
      IF tmp[0] NE 0 THEN $
         BEGIN
         bg_delta_time=bg_time_intv[1]-bg_time_intv[0]
         lc->set,obs_time_interval=bg_time_intv
         lc->set,ltc_time_range=[0,bg_delta_time]
         background=lc->getdata()

         tmp=size(y)
         FOR i=0,(tmp[1]-1) DO $
            spectrogram[*,i]=spectrogram[*,i]- $
            total(background[*,i])/bg_delta_time
 
        spectrogram=spectrogram>0
         ENDIF
;
;
;
      loadct,5
      spg_max_value=max(spectrogram)
      spg_min_value=min(spectrogram)


      IF (spg_max_value GT 0) THEN $
         BEGIN
;
;        the colour scale is logarithmic
;
         lev=findgen(256)/255*alog(spg_max_value)
         lev=exp(lev)-1

         IF keyword_set(e) THEN $
            BEGIN
;
;           compute the number of counts per second per keV
;
            spectrogram[*,96:186]=spectrogram[*,96:186]/10
            spectrogram[*,187:346]=spectrogram[*,187:346]/100           
;
            contour,spectrogram,x,y,/fill,/ylog,levels=lev,ystyle=1, $
	    yrange=[3,1500],xrange=[0,delta_t],xstyle=1, $
            ytitle='Energy (keV)',title='RHESSI Spectrogram.'+ $
            ' MAX Counts per second per keV:'+ $
            string(spg_max_value), $
            xtitle='Seconds from '+anytim(time_intv[0],/yohkoh)
	    ENDIF $
         ELSE $
            contour,spectrogram,x,y,/fill,levels=lev,ystyle=1, $
            yrange=[3,ymax], xrange=[0,delta_t], xstyle=1, $
            ytitle='Energy (keV)',title='RHESSI Spectrogram.'+ $
            ' MAX Counts per second per keV:'+ $
            string(spg_max_value), $
            xtitle='Seconds from '+anytim(time_intv[0],/yohkoh)     
      ENDIF $
      ELSE $
         BEGIN
         print,'Problems with the data!'
         ENDELSE   
END
