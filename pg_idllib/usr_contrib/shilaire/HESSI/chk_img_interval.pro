; this routines checks whether a certain time interval is OK for image accumulation.
;
; needs a proper obs. summary ot work !!!
; does not check for count rates...!
;
; returns 0 if a check was failed, returns 1 otherwise
;
; AT LEAST ONE KEYWORD MUST BE ENTERED (e.g. /ALL)
;

FUNCTION chk_img_interval, time_intv, 		$
	ATTENUATORSTATE=ATTENUATORSTATE,	$
	DECIMATIONSCHEME=DECIMATIONSCHEME,	$
	NIGHT=NIGHT,				$
	SAA=SAA,				$
	GAP=GAP,				$
	CHANGE=CHANGE,				$	; all 'changes' flags
	PRESENCE=PRESENCE,			$	; all 'presence' flags
	ALL=ALL						; all checks


	IF KEYWORD_SET(ALL) THEN BEGIN
		CHANGE=1
		PRESENCE=1		
	ENDIF
	IF KEYWORD_SET(CHANGE) THEN BEGIN
		ATTENUATORSTATE=1
		DECIMATIONSCHEME=1		
	ENDIF
	IF KEYWORD_SET(PRESENCE) THEN BEGIN
		NIGHT=1
		SAA=1
		GAP=1		
	ENDIF


;-------------------------------------------------------------------------------------------------
	result=1
	oso=OBJ_NEW('hsi_obs_summary')
;-------------------------------------------------------------------------------------------------
	es=0
	CATCH,es
	IF es NE 0 THEN BEGIN
		PRINT,'...............................CAUGHT ERROR !......................'
		HELP, CALLS=caller_stack
                PRINT, 'Error index: ', es
                PRINT, 'Error message:', !ERR_STRING
                PRINT,'Error caller stack:',caller_stack
		PRINT,'...................................................................'
		OBJ_DESTROY,oso
		RETURN,1
	ENDIF
;-------------------------------------------------------------------------------------------------
	
	oso->set,obs_time_interval=time_intv

	rates=oso->getdata()
	;times=oso->getdata(/time)
	flagdata=oso->getdata(class_name='obs_summ_flag')
	;flaginfo=oso->get(class_name='obs_summ_flag')
	;flagtimes=oso->getdata(class_name='obs_summ_flag',/time)

	;check#1 : change of attenuator states
	IF KEYWORD_SET(ATTENUATORSTATE) THEN BEGIN
		tmp=flagdata[14,0]
		ss=WHERE(flagdata[14,*] NE tmp)
		IF ss[0] NE -1 THEN RETURN,0
	ENDIF
	;check#2 : change of decimation scheme
	IF KEYWORD_SET(DECIMATIONSCHEME) THEN BEGIN
		tmp=flagdata[18,0]
		ss=WHERE(flagdata[18,*] NE tmp)
		IF ss[0] NE -1 THEN RETURN,0
		tmp=flagdata[19,0]
		ss=WHERE(flagdata[19,*] NE tmp)
		IF ss[0] NE -1 THEN RETURN,0
	ENDIF
	;check#3 : presence of SAA flags ?
	IF KEYWORD_SET(SAA) THEN BEGIN
		ss=WHERE(flagdata[0,*] NE 0)
		IF ss[0] NE -1 THEN RETURN,0
	ENDIF
	;check#4 : presence of NIGHT flags ?
	IF KEYWORD_SET(NIGHT) THEN BEGIN
		ss=WHERE(flagdata[1,*] NE 0)
		IF ss[0] NE -1 THEN RETURN,0		
	ENDIF
	;check#5 : presence of GAP FLAG ?
	IF KEYWORD_SET(GAP) THEN BEGIN
		ss=WHERE(flagdata[17,*] NE 0)
		IF ss[0] NE -1 THEN RETURN,0		
	ENDIF
	;check#? : pmtras ~ok?
	

	RETURN,result
END

