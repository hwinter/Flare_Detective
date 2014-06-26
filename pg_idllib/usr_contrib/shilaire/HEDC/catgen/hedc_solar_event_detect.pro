;
;
; Uses the Obs. Summ. count rates to look for solar flares.
;
;
;"time_intv" is typically a whole day, from S/C night to S/C night.
;If ECLIPSE_FLAG not present at start and/or end time_intv, the start/end 
;	time_intv are modified to the NEXT s/c night
;
;
;	flare_intvs=hedc_solar_event_detect('2002/04/10')
;
;======================================================================================================================




;======================================================================================================================
FUNCTION hedc_fulfilled_conditions_solar_event,mincountrateperdetector1225,icur,count_rate_per_detector_12_25,saa_flag,night_flag,front_ratio,Modulation,INITIALCONDITION=INITIALCONDITION
	;as SAA_FLAG and ECLIPSE_FLAG are not totally trustworthy.... CAREFUL
		
	IF KEYWORD_SET(INITIALCONDITION) THEN IF ((count_rate_per_detector_12_25(icur) GE mincountrateperdetector1225) AND (saa_flag(icur) EQ 0) AND (night_flag(icur) EQ 0) AND (front_ratio(icur) GE 25) AND (Modulation(icur) GE 1.5) $
		AND (saa_flag(icur-8) EQ 0)) THEN RETURN,1 ELSE RETURN,0 $
	ELSE IF ((count_rate_per_detector_12_25(icur) GE mincountrateperdetector1225) AND (saa_flag(icur) EQ 0) AND (night_flag(icur) EQ 0)) THEN RETURN,1 ELSE RETURN,0
END
;======================================================================================================================
FUNCTION hedc_return_good_day_index_intv, anyday, NightFlagdata, Flagtimes
	
	ss=WHERE(FlagTimes GE anytim(anyday))
	istart=ss(0)
	WHILE (NightFlagData(istart) NE 1) DO BEGIN
		istart=istart+1
		IF istart GE N_ELEMENTS(FlagTimes) THEN RETURN,'Problem'
	ENDWHILE
		
	ss=WHERE(FlagTimes GE (anytim(anyday)+86399))
	iend=ss(0)
	IF iend EQ -1 THEN BEGIN
		iend=N_ELEMENTS(FlagTimes)-1
		RETURN,[istart,iend]
	ENDIF
	WHILE (NightFlagData(iend) NE 1)  DO BEGIN
		iend=iend+1
		IF iend GE N_ELEMENTS(NightFlagData) THEN BEGIN
			ss=WHERE(NightFlagData NE 0, nbr)
			iend=ss(nbr-1)
			RETURN,[istart,iend]
		ENDIF
	ENDWHILE
RETURN,[istart,iend]
END
;======================================================================================================================
;======================================================================================================================
;======================================================================================================================
;======================================================================================================================
;======================================================================================================================
FUNCTION hedc_solar_event_detect, anyday,	$
	countrate=countrate,			$
	beforetime=beforetime,			$
	aftertime=aftertime,			$
	LOUD=LOUD
	
	IF NOT KEYWORD_SET(countrate) THEN countrate=8		; cts/s/detector  
	IF NOT KEYWORD_SET(beforetime) THEN beforetime=600	; 10 mins before flare begin...	
	IF NOT KEYWORD_SET(aftertime) THEN aftertime=600	; 30 mins after flare begin...
	
	;INITIALIZE:
	flare_intvs='No flares'

	es=0
	CATCH,es
	IF es NE 0 THEN BEGIN flare_intvs='Bad day...' & GOTO,LABEL01 & ENDIF

	oso=hsi_obs_summary()
	oso->set,obs_time_interval=anytim(anyday,/date_only)+[0,86399+7200]
	
	FlagData=oso->getdata(class_name='obs_summ_flag')
	NightFlagData=FlagData(1,*)
	SAAFlagData=FlagData(0,*)
	FrontFlagData=FlagData(15,*)
	FlagTimes=oso->getdata(class_name='obs_summ_flag',/time)
	ModVar=oso->getdata(class_name='mod_variance')
	;ModVar=SMOOTH(ModVar,10)
	ModVar=TOTAL(ModVar,1)/2
	
	index_intv=hedc_return_good_day_index_intv(anytim(anyday,/date_only), NightFlagData,FlagTimes)
	IF datatype(index_intv) EQ 'STR' THEN RETURN,-1

	; NOW, CHECK FOR FLARES !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	;get lc(12-25 keV) data:
	lc_all=oso->getdata()
	lc=lc_all(2,*)
;	;Correct lc for attenuator states
;		AttenData=FlagData(14,*)
;		ss=WHERE(AttenData NE 0, nbr)
;		IF ss(0) NE -1 THEN FOR j=0,nbr-1 DO lc(ss(j))=lc(ss(j))*10.^AttenData(ss(j))	; very approximative...
	;Correct lc for decimation:
		ss=WHERE(FlagData(19,*) NE 1,nbr)
		IF ss(0) NE -1 THEN BEGIN
			;Here, I suppose that if decimation is going on, then it occurs also in the 12-25 keV range.
			FOR j=0,nbr-1 DO lc(ss(j))=lc(ss(j))*FlagData(19,ss(j))
		ENDIF
	
	IF KEYWORD_SET(LOUD) THEN BEGIN
		CLEAR_UTPLOT
		UTPLOT,flagtimes,lc,title='Cts/s/sc. Very roughly corrected for attenuation and decimation'
	ENDIF
	
	istart=index_intv(0)
	iend=index_intv(1)
	IF KEYWORD_SET(LOUD) THEN PRINT,'Index start and end: '+strn(istart)+','+strn(iend)

	icur=istart
	WHILE icur LT iend DO BEGIN
		IF hedc_fulfilled_conditions_solar_event(countrate,icur,lc,SAAFLagData,NightFlagData,FrontFlagData,ModVar,/INITIAL) THEN BEGIN
			;found a flare ?
			IF (hedc_fulfilled_conditions_solar_event(countrate,icur+1,lc,SAAFLagData,NightFlagData,FrontFlagData,ModVar)) THEN BEGIN
				fstart=icur
				WHILE hedc_fulfilled_conditions_solar_event(countrate,icur+1,lc,SAAFLagData,NightFlagData,FrontFlagData,ModVar) DO BEGIN
					icur=icur+1
					IF (icur+1) GE N_ELEMENTS(FlagTimes) THEN BREAK
				ENDWHILE
				fend=icur
				IF N_ELEMENTS(flare_intvs) EQ 1 THEN flare_intvs=[anytim(FlagTimes(fstart)-beforetime,/ECS),anytim(FlagTimes(fend)+aftertime,/ECS)] ELSE flare_intvs=[[Flare_intvs],[anytim(FlagTimes(fstart)-beforetime,/ECS),anytim(FlagTimes(fend)+aftertime,/ECS)]]
				icur=icur+aftertime/4 ; next flare search will start "aftertime" after current flare's end.				
			ENDIF ELSE icur=icur+2	; false alarm					
		ENDIF ELSE icur=icur+1	
	ENDWHILE

	LABEL01:
	OBJ_DESTROY,oso
	RETURN,flare_intvs
END
;======================================================================================================================
;======================================================================================================================
;======================================================================================================================
;======================================================================================================================
;======================================================================================================================
;======================================================================================================================

