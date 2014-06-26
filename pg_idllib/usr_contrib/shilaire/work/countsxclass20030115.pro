;	.r countsxclass20030115


time_intv=['2002/10/01','2002/11/01']
minpeakcounts=10
mintotcounts=1000



flo=hsi_flare_list()
flo->set,obs_time=time_intv
fl=flo->getdata()
OBJ_DESTROY,flo

n_flares=N_ELEMENTS(fl)
flares=-1

FOR i=0L,n_flares-1 DO BEGIN
	ok=1
	IF fl[i].PEAK_COUNTRATE LT minpeakcounts THEN ok=0
	IF fl[i].TOTAL_COUNTS LT mintotcounts THEN ok=0
	IF (fl[i].END_TIME-fl[i].START_TIME) LT 8. THEN ok=0
		;oso=hsi_obs_summary()
		;oso->set,obs_time=anytim(fl[j].PEAK_TIME)+[0.,8.]
		;flagdata_struct=oso->getdata(class='hsi_obs_summ_flag')	
		;OBJ_DESTROY,oso
	;IF flagdata_struct[0].FLAGS[24] NE 0 THEN doit=2

	IF ok NE 0 THEN BEGIN
		goesclass='-'
		;find maximum
		rd_goes,timegoes,datagoes,trange=anytim([fl[i].START_TIME,fl[i].END_TIME],/yohkoh),/goes8
		IF datatype(datagoes) EQ 'UND' THEN GOTO,NEXTPLEASE
		tmp=alog10(MAX(datagoes))
		IF tmp GT -8 THEN goesclass='A'+strn(floor(100.*(8.+tmp))/10.,format='(f5.1)')		
		IF tmp GT -7 THEN goesclass='B'+strn(floor(100.*(7.+tmp))/10.,format='(f5.1)')		
		IF tmp GT -6 THEN goesclass='C'+strn(floor(100.*(6.+tmp))/10.,format='(f5.1)')				
		IF tmp GT -5 THEN goesclass='M'+strn(floor(100.*(5.+tmp))/10.,format='(f5.1)')
		IF tmp GT -4 THEN goesclass='X'+strn(floor(100.*(4.+tmp))/10.,format='(f5.1)')
		
		str=anytim(fl[i].PEAK_TIME,/ECS)+' '+strn(fl[i].PEAK_COUNTRATE)+' '+strn(fl[i].TOTAL_COUNTS)+' '+goesclass
		IF datatype(flares) EQ 'INT' THEN flares=str ELSE flares=[flares,str]		
	ENDIF
	NEXTPLEASE:
ENDFOR

prstr,flares
END





;RESULTS: October: 
