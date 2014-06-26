; this routine will display the time evolution of the spectral index and some 
; lightcurves. Everything is taken from Obs. Summary.
;
; If backtime is given, then the background obs. summ. lightcurve is subtracted 
; from the flare lightcurve.
;
; All times must be entered in ANYTIM format ! 




PRO hedc_spectral_index,time_intv,backtime=backtime

hedc_win,768,512
myct3
!P.MULTI=[0,1,2]

oso=hsi_obs_summary()

oso->set,obs_time_interval=time_intv
rates_struct=oso->getdata()
rates=rates_struct.COUNTRATE
rates=DOUBLE(rates)
times=oso->getdata(/time)

title='Ratio 25-50/12-25 (from Obs. Summary) -- NOT background subtracted'

t0=anytim(times[0])
clear_utplot
utplot,times-t0,rates[2,*],t0,title='Obs. Summ. count rates',ytit='cts/s/det'
outplot,times-t0,rates[2,*],t0,color=249
XYOUTS,/DATA,(times[N_ELEMENTS(times)-1]-t0)*0.9,0.9*MAX(rates[2,*]),'12-25 keV',color=249
outplot,times-t0,rates[3,*],t0,color=250
XYOUTS,/DATA,(times[N_ELEMENTS(times)-1]-t0)*0.9,0.8*MAX(rates[2,*]),'25-50 keV',color=250

IF KEYWORD_SET(backtime) THEN BEGIN
	oso->set,obs_time_interval=backtime
	back_rates_struct=oso->getdata()
	back_rates=back_rates_struct.COUNTRATE
	back_rates=DOUBLE(back_rates)
	back_rates_avg=avg(back_rates,1)
	FOR i=0,8 DO rates[i,*]=rates[i,*]-back_rates_avg[i]
	title='Ratio 25-50/12-25 (from Obs. Summary) -- background subtracted'
ENDIF

OBJ_DESTROY,oso

ratio=REFORM(rates[3,*]/rates[2,*])

good_ss_1=WHERE(rates[2,*] GE 3.)
good_ss_2=WHERE(rates[3,*] GE 3.)
match,good_ss_1,good_ss_2,sub1,sub2
good_ss=good_ss_1[sub1]
IF good_ss[0] NE -1 THEN utplot,times[good_ss]-t0,ratio[good_ss],t0,ytit='ratio',title=title,timerange=time_intv	;,psym=-7

!P.MULTI=0
END


