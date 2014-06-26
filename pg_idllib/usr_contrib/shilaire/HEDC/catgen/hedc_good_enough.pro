;	This routine, given some inputs, gives a decision on whether an image should be done or not.
;	Later, it should be improved to give me which parameters to use (detectors, ebands, ...)
;
;


FUNCTION hedc_good_enough, time_intv, eband, imgalg=imgalg
	res=1	; default
	es=0
	CATCH,es
	IF es NE 0 THEN GOTO,BIGLEAP

	oso=hsi_obs_summary()
	oso->set,obs_time_interval=time_intv
	rates=oso->getdata()
	times=oso->getdata(/xaxis)

	rateinfo=oso->get(class_name='rate')	
	estart=0
	eend=rateinfo.N_ENERGY_BANDS -1
	WHILE rateinfo.ENERGY_EDGES(estart+1) LE eband(0) DO estart=estart+1
	WHILE rateinfo.ENERGY_EDGES(eend) GE eband(1) DO eend=eend-1
	
	PRINT,'Ebands used: '+strn(rateinfo.ENERGY_EDGES(estart))+'-'+strn(rateinfo.ENERGY_EDGES(eend+1))+'keV'
	totcts=rateinfo.TIME_INTV*TOTAL(rates(*,estart:eend))
	PRINT,'.......TOTAL EXPECTED COUNTS: '+strn(totcts)
	
	IF KEYWORD_SET(imgalg) THEN BEGIN
		CASE imgalg OF
			'mem':	totcts=totcts*0.3
			ELSE: totcts=totcts*1
		ENDCASE
	ENDIF

	IF totcts LT 1000 THEN res=0
	
	BIGLEAP:
	OBJ_DESTROY,oso
	RETURN,res
END
