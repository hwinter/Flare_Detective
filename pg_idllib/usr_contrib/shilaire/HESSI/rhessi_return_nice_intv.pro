;+
; This routine should return a nice interval for imaging/spectroscopy (free of shutter movements and other annoying stuff)
; If something went amiss, routine won't crash, give best possible result, and set WARNING keyword to 1.
;
; KEYWORDS:
;	check_min_counts	: puts warning flag to 1 if the number of counts/detecteor in the returned interval is less than check_min_counts (12-25 keV band)
;
; RESTRICTIONS:
;	obs_time_intv MUST BE BIGGER than min_wished_spin_periods*spin_period, as well as max_spin_periods*spin_period 
;
; 
;
;;
; EXAMPLE:
;	PRINT,anytim(rhessi_return_nice_intv(time_intv,'2002/02/26 10:26:50',min=12,max=13),/ECS)
;-


FUNCTION rhessi_return_nice_intv, obs_time_intv, wished_time, spin_period=spin_period, min_wished_spin_periods=min_wished_spin_periods, max_spin_periods=max_spin_periods,	$
	warning=warning

	warning=0
	totcounts=0
	IF NOT KEYWORD_SET(spin_period) THEN spin_period=rhessi_get_spin_period(wished_time,/DEF)
	IF NOT KEYWORD_SET(min_wished_spin_periods) THEN min_wished_spin_periods=1
	IF ( (anytim(wished_time) LT anytim(obs_time_intv[0])) AND (anytim(wished_time) GT anytim(obs_time_intv[1])) ) THEN MESSAGE,'.....wished_time must be inside obs_time_intv !'
		
	PRINT,' rhessi_return_nice_intv.pro:-------------------------------------------------------'
	PRINT,' Obs. time intv: '+anytim(obs_time_intv[0],/ECS)+' to '+anytim(obs_time_intv[1],/ECS)
	PRINT,' Wished time: '+anytim(wished_time,/ECS)
	PRINT,' -----------------------------------------------------------------------------------'

	;good_intvs=to_nice_img_intervals(obs_time_intv,mindeltat=min_wished_spin_periods*spin_period,/ATTLOW,/PARTICLES,wait_after_shutter=60.,wait_after_eclipse=120.)
	good_intvs=to_nice_img_intervals(obs_time_intv,mindeltat=min_wished_spin_periods*spin_period,/ATTLOW,wait_after_shutter=60.,wait_after_eclipse=120.)

	;if no good_intvs are given, then go for a single spin period:
	IF N_ELEMENTS(good_intvs) EQ 1 THEN BEGIN
		good_intvs=to_nice_img_intervals(obs_time_intv,mindeltat=1.*spin_period,/ATTLOW,/PARTICLES,wait_after_shutter=60.,wait_after_eclips=120.)
		warning=warning+1	;bit 0
	ENDIF
	;if still bad, then try the whole flare interval !
	IF N_ELEMENTS(good_intvs) EQ 1 THEN the_intv=anytim(obs_time_intv) ELSE BEGIN
		;now, find the good interval nearest to the peak time of the flare: for this, pick the middle of each interval, and compute distance to peak time
		best_ss=0
		FOR j=0, N_ELEMENTS(good_intvs[0,*])-1 DO BEGIN
			cur_time=(anytim(good_intvs[0,j])+anytim(good_intvs[1,j]))/2.
			best_time=(anytim(good_intvs[0,best_ss])+anytim(good_intvs[1,best_ss]))/2.			
			IF abs(cur_time-anytim(wished_time)) LT abs(best_time-anytim(wished_time)) THEN best_ss=j
		ENDFOR
	the_intv=anytim(good_intvs[*,best_ss])
	ENDELSE
	;--------------------------------------------------------------
	;transform interval into multiple of spin period ???
	;limit interval to a maximum of ~1 min, if it is longer ???
	IF KEYWORD_SET(max_spin_periods) THEN BEGIN
		IF (the_intv[1]-the_intv[0]) GT max_spin_periods*spin_period THEN BEGIN

			;if wished_time is on the left of the_intv...
			IF anytim(wished_time) LT anytim(the_intv[0]) THEN BEGIN
				the_intv=the_intv[0]+[0.,max_spin_periods*spin_period]
			ENDIF
			
			;if wished_time is on the right of the_intv...
			IF anytim(wished_time) GT anytim(the_intv[1]) THEN BEGIN
				the_intv=the_intv[1]+[-max_spin_periods*spin_period,0.]
			ENDIF
			
			;if wished_time is within the_time
			IF ((anytim(wished_time) GE the_intv[0]) AND (anytim(wished_time) LE the_intv[1])) THEN BEGIN
				;check within which border it is the closest
				IF (anytim(wished_time)-the_intv[0]) LT (the_intv[1]-anytim(wished_time)) THEN BEGIN
					;the left boundary is nearest wished_time
					IF (anytim(wished_time)-the_intv[0]) GE 0.5*max_spin_periods*spin_period THEN the_intv=anytim(wished_time)+[-0.5,0.5]*max_spin_periods*spin_period ELSE the_intv=the_intv[0]+[0.,max_spin_periods*spin_period]
				ENDIF ELSE BEGIN
					;the right boundary is nearest wished_time
					IF (the_intv[1]-anytim(wished_time)) GE 0.5*max_spin_periods*spin_period THEN the_intv=anytim(wished_time)+[-0.5,0.5]*max_spin_periods*spin_period ELSE the_intv=the_intv[1]+[-max_spin_periods*spin_period,0.]
				ENDELSE				
			ENDIF
		ENDIF
	ENDIF
	;--------------------------------------------------------------
;	IF KEYWORD_SET(check_min_counts) THEN BEGIN
;		osro=hsi_obs_summ_rate()
;		osro->set,obs_time=the_intv
;		rates_struct=osro->getdata()
;		deltat=osro->get(/time_intv)
;		OBJ_DESTROY,osro
;		totcounts=deltat*TOTAL(rates_struct.COUNTRATE[2])
;		IF totcounts LT check_min_counts THEN warning=warning+2	;bit 1
;	ENDIF	

	RETURN,the_intv
END

