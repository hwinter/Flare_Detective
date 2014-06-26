;+
;NAME:
; rhessi_detector_livetime.pro
;
;PROJECT:
;	HESSI at ETHZ
;
;CATEGORY:
; 
;PURPOSE:
;	Plots the detector livetimes for different RHESSI segments.
;
;
;CALLING SEQUENCE:
; rhessi_detector_livetime,time_interval, segment=segment, PLOT=PLOT
;
;INPUT:
; time_interval = a 2-element array,in a format accepted by ANYTIM
;
;OPTIONAL INPUT:	
;
;OUTPUT:
; Observing Summary Information for that time range
;
;KEYWORDS:
;	REAR
;	SMOOTH
;	+most keywords accepted by PLOT (such as yrange...)
;
;EXAMPLE:
;	rhessi_detector_livetime,'2002/02/26 '+['10:20','10:35']
;
;HISTORY:
;	2003/05/20 written by PSH.
;
;-


PRO rhessi_detector_livetime, time_intv, REAR=REAR, SMOOTH=SMOOTH, _extra=_extra
	mro=hsi_monitor_rate()		
	mro->set,obs_time_interval=time_intv
	mr=mro->getdata()
	utbase=mro->get(/mon_ut_ref)
	OBJ_DESTROY, mro
	
	data=mr.LIVE_TIME
	IF KEYWORD_SET(SMOOTH) THEN FOR i=0,17 DO data[i,*]=SMOOTH(data[i,*],5)

	psh_win,900
	!P.MULTI=[0,3,3]
	
	IF KEYWORD_SET(REAR) THEN BEGIN
		FOR i=9,17 DO BEGIN
			utplot,mr.TIME,data[i,*],base=utbase,ytit='Rear segment '+strn(i+1),charsize=2., xtit='', xmar=[7,1],ymar=[2,1], _extra=_extra
		ENDFOR
	ENDIF ELSE BEGIN
		FOR i=0,8 DO BEGIN
			utplot,mr.TIME,data[i,*],base=utbase,ytit='Front segment '+strn(i+1),charsize=2., xtit='', xmar=[7,1],ymar=[2,1], _extra=_extra
		ENDFOR
	ENDELSE
END




