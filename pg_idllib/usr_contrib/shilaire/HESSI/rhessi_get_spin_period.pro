
;+
;NAME:
;	rhessi_get_spin_period.pro
;PROJECT:
;	HESSI at ETHZ
;CATEGORY:
; 
;PURPOSE:
;	This functions returns HESSI's spin period (in seconds), given input time.
;	If something went wrong, a value of 4. is returned, and err is set to a non-zero value.
;	
;CALLING SEQUENCE:
;	spin_period=rhessi_get_spin_period(time,err=err)
;
;INPUT:
;	time : a time in ANYTIM format, or a time interval (2-element array of such times)
;		If a single time is given, routine assumes a time interval of 1 min (-30 to +30 secs.)
;		This should be ok most of the time.
;
;OPTIONAL INPUT:	
;	DEFAULT_ON_FAILURE: if set, will not return a -1 upon failure, but a value of 4 seconds
;
;OUTPUT:
;	The spin period, in seconds, or -1 if something went amiss.
;
;INPUT KEYWORDS:
;	None
;
;OUTPUT KEYWORDS:
;	err: if equal to zero, everything was fine. If non-zero, a problem occured.
;
;EXAMPLE:
;	spin_period=rhessi_get_spin_period('2002/02/26 10:27:00',err=err)
;
;HISTORY:
;	PSH, 2002/12/06 written.
;
;-

FUNCTION rhessi_get_spin_period, time, err=err, DEFAULT_ON_FAILURE=DEFAULT_ON_FAILURE
	err=0	
	CATCH,err
	IF err NE 0 THEN BEGIN 
		CATCH,/CANCEL 
		IF NOT KEYWORD_SET(DEFAULT_ON_FAILURE) THEN BEGIN
			PRINT,'........rhessi_get_spin_period.pro: problem! Returning -1...' 
			spin_period=-1
		ENDIF ELSE BEGIN
			PRINT,'........rhessi_get_spin_period.pro: problem! Returning a default 4.0 seconds...' 
			spin_period=4.			
		ENDELSE
		GOTO,THEEND
	ENDIF
	
;OLD WAY:	;(accuracy could be as bad as 2ms, as the result was file-averaged...)
	;pmtras_analysis,hsi_filedb_filename(time),avperiod=spin_period,PMTRAS_DIAGNOSTIC=0

;NEW WAY:

	CASE N_ELEMENTS(time) OF
		1: time_intv=anytim(time)+[-15.,15.]
		2: time_intv=anytim(time)
		ELSE: BEGIN PRINT,".......'time' is not properly defined!" & MESSAGE,'Will return a default value...' & END
	ENDCASE
	
	ao=hsi_aspect_solution() 
	ao->set,aspect_cntl_level=0     
	ao->set,obs_time_interval=anytim(time_intv)
	;ao->set,aspect_time_range=anytim(time_intv)    
	as=ao->getdata()
	IF datatype(as) EQ 'INT' THEN BEGIN PRINT,'.......problem with aspect object...' & MESSAGE,'Will return a default value...' & END
	
	times=as.time * 2d^(-7)
	;t0=hsi_sctime2any(as.t0)	; actually not needed...
	spin_period=2*!dPI/MEAN(DERIV(times,as.ROLL))
THEEND:
	IF datatype(ao) EQ 'OBJ' THEN OBJ_DESTROY,ao
	RETURN,spin_period
END
