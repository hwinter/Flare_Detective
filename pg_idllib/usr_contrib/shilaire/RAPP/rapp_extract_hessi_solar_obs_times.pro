; This routines, when given a time interval (ANYTIM format), outputs the list of times when HESSI
; was in GAP-free, S/C Sunlight, in anytim format, or in a special format to make it compatible 
; with previous routines by P. Messmer if /QV is set.
; Returns -1 if failed for any reason, or if no sunlit interval was found.
;
; Pascal Saint-Hilaire (shilaire@astro.phys.ethz.ch) , 2002/11/24 written.
;

FUNCTION rapp_to_qv_time_format, anytimeintv, QV=QV
	IF KEYWORD_SET(QV) THEN BEGIN
		tmp1=anytim(anytimeintv[0],/EX)
		tmp2=anytim(anytimeintv[1],/EX)		
		output=int2str(tmp1[0],2)+int2str(tmp1[1],2)+'  '+int2str(tmp2[0],2)+int2str(tmp2[1],2)
	ENDIF ELSE output=anytim(anytimeintv,/ECS)
	RETURN,output
END


FUNCTION rapp_extract_hessi_solar_obs_times, time_intv, QV=QV
	   
	err=0
	CATCH,err
	IF err NE 0 THEN BEGIN
		CATCH, /CANCEL
		HELP, /Last_Message, Output=theErrorMessage
		FOR j=0,N_Elements(theErrorMessage)-1 DO PRINT, theErrorMessage[j]
		intv=-1
		GOTO,THEEND
	ENDIF
	
	fobj=OBJ_NEW('hsi_obs_summ_flag')
	fobj->set,obs_time_interval=anytim(time_intv)
	tmp=fobj->getdata()
	if (datatype(tmp) EQ 'INT') THEN IF tmp[0] EQ -1 THEN RETURN,-1		; most probably a time intv without obs. summary....
	SC_fdata=fobj->get(flag_name='SC_IN_SUNLIGHT')
		ss=WHERE(SC_fdata GT 90)
		SC_fdata=BYTARR(N_ELEMENTS(SC_fdata))
		IF ss[0] NE -1 THEN SC_fdata[ss]=1
	GAP_fdata=fobj->get(flag_name='GAP_FLAG')
	ftimes=fobj->get(/time)

	; find valid ss
	fdata=SC_fdata*(1-GAP_fdata)
	valid_ss=WHERE(fdata NE 0)
	IF valid_ss[0] EQ -1 THEN RETURN,-1

	;find changes in valid_ss flags.
	mod_ss=get_array_changes(fdata)

	IF (mod_ss[0] EQ -1) THEN BEGIN
		IF fdata[0] NE 0 THEN RETURN,rapp_to_qv_time_format(time_intv,QV=QV) ELSE RETURN,-1
	ENDIF

	; now make a loop, after some initialization
	mod_ss=[0,mod_ss]
	ss_beg=-1
	intv=-1
	FOR i=0L, N_ELEMENTS(fdata)-1 DO BEGIN
		tmp=WHERE(mod_ss EQ i) ;is it a change ?
		IF (tmp[0] NE -1) THEN BEGIN
			;yes, it was a change. Check whether the previous interval was a good one, and act.
			IF ss_beg NE -1 THEN BEGIN
				;we were in a good interval...
				IF datatype(intv) EQ 'INT' THEN intv=rapp_to_qv_time_format([ftimes[ss_beg],ftimes[i]],QV=QV) $
				ELSE intv=[[intv],[rapp_to_qv_time_format([ftimes[ss_beg],ftimes[i]],QV=QV)]]
				ss_beg=-1; now, we must be starting a bad interval...
			ENDIF ELSE ss_beg=i	; we just started a good interval...			
		ENDIF
	ENDFOR
	
	THEEND:
	IF datatype(fobj) EQ 'OBJ' THEN OBJ_DESTROY,fobj
	RETURN,REFORM(intv)
END


