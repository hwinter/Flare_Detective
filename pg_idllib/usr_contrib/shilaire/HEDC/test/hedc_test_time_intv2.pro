;+
;to test the time intervals found by hedc_automatic2.pro ...
;
; V2: 	;If any of the flarelist flares are in within this gev, take the time_intv of the first flarelist item event to the last flarelist item.

;
;.run hedc_test_time_intv2
;-

;time_intv='2003/07/06 '+['00:00','03:00']
;time_intv='2003/10/31 '+['00:00','24:00']
;time_intv='2003/10/31 '+['16:40','17:30']
;time_intv='2002/02/20 '+['11:00','11:20']
;time_intv='2003/10/31 '+['20:00','22:00']
time_intv='2005/01/01 '+['00:00','02:00']

;;;;;;;;;;;;;;;;;
PRINT,'Interval of interest: '+anytim(time_intv[0],/ECS)+' to '+anytim(time_intv[1],/ECS)

flo=hsi_flare_list()	
flo->set,obs_time_interval=time_intv
fl=flo->getdata()
;flinfo=flo->get()
OBJ_DESTROY,flo
gev=rapp_get_gev(time_intv)
IF datatype(gev) NE 'INT' THEN already_done_gev=BYTARR(N_ELEMENTS(gev))

IF datatype(fl) NE 'STC' THEN BEGIN
	PRINT,'.........No flares in the flare list for that time interval. Aborting now.'
	GOTO,THEEND
ENDIF

nbrtried=0
nbrdone=0
FOR j=0,N_ELEMENTS(fl)-1 DO BEGIN
	doit=1	; doit =2 is for minimal event creation.
	
	es=0
	IF KEYWORD_SET(DEBUG) THEN BEGIN
		REMOVE_FROM_HEDC=0
	ENDIF ELSE BEGIN
		REMOVE_FROM_HEDC=1
		CATCH,es
	ENDELSE
	IF KEYWORD_SET(NOREPLACE) THEN REMOVE_FROM_HEDC=0
	
	IF es NE 0 THEN BEGIN
		es=0
		PRINT,'...............................CAUGHT ERROR !......................'
		HELP, CALLS=caller_stack
		PRINT, 'Error index: ', es
		PRINT, 'Error message:', !ERR_STRING
		PRINT,'Error caller stack:',caller_stack
		HELP, /Last_Message, Output=theErrorMessage
		FOR k=0,N_Elements(theErrorMessage)-1 DO PRINT, theErrorMessage[k]
		GOTO,NEXTPLEASE					
	ENDIF

;FLARE selection:-----------------------------------------------------------------------------------------------------------------------------------------
	;info setup:
	flare_intv=anytim([fl[j].START_TIME,fl[j].END_TIME])
	flare_duration=fl[j].END_TIME-fl[j].START_TIME

	;Is this jimm flare simultaneous to a gev ?
	cur_gev_ss=-1
	IF datatype(gev) NE 'INT' THEN BEGIN
		FOR k=0,N_ELEMENTS(gev)-1 DO BEGIN
			IF has_overlap([fl[j].START_TIME,fl[j].END_TIME],[gev[k].START_TIME,gev[k].END_TIME]) THEN BEGIN
				cur_gev_ss=k
;;;;;;;;;;;;;;;;;;;;;;;;;If any of the flarelist flares are in within this gev, take the time_intv of the first flarelist item event to the last flarelist item.
				IF m_has_overlap([gev[k].START_TIME,gev[k].END_TIME],TRANSPOSE([[fl.START_TIME],[fl.END_TIME]]),inter=inter) THEN BEGIN				
					flare_intv=[MIN(inter),MAX(inter)]
					flare_duration=anytim(flare_intv[1])-anytim(flare_intv[0])
				ENDIF
;;;;;;;;;;;;;;;;;;;;;;;;;
			ENDIF
		ENDFOR
	ENDIF	

	;GOES stuff:
	goo=OBJ_NEW('goes')
	goo->read,anytim(flare_intv[0],/yoh),anytim(flare_intv[1],/yoh),err=err
	IF err EQ '' THEN BEGIN
		goesdata=goo->getdata()
		goesmax=MAX(goesdata[*,0])
	ENDIF ELSE goesmax=-1
	goo->flush,1
	OBJ_DESTROY,goo

	oso=hsi_obs_summary()
	oso->set,obs_time=anytim(fl[j].PEAK_TIME)+[0.,8.]
	flagdata_struct=oso->getdata(class='hsi_obs_summ_flag')	
	OBJ_DESTROY,oso	

	qmro=hsi_qlook_monitor_rate(obs_time_interval=anytim(fl[j].PEAK_TIME)+[0.,8.])
	qmr=qmro->getdata()
	;qmrtimes=qmro->getdata(/xaxis)
	OBJ_DESTROY,qmro
	
;decisions:
	
	;do min:
	IF fl[j].PEAK_COUNTRATE LT 8. THEN doit=2		;//PSH 2003/02/12: changed from 20 to 8
	IF fl[j].TOTAL_COUNTS LT 2000 THEN doit=2
	;IF flagdata_struct[0].FLAGS[24] NE 0 THEN doit=2 ;does not work good enough anymore... will use monitor rates...
	IF ((goesmax LT 1e-5) AND (TOTAL(qmr[0].PARTICLE_RATE) GT 25)) THEN doit=2	;25 is a pretty arbitrary number...

	;don't do:
	IF flare_duration LT 10. THEN doit=0
	IF ( (anytim(fl[j].PEAK_TIME) LT anytim(time_intv[0])) OR (anytim(fl[j].PEAK_TIME) GT anytim(time_intv[1])) ) THEN doit=0	
	IF KEYWORD_SET(GOESmin) THEN BEGIN
		IF GOESmin EQ 1 THEN GOESmin=1e-5 ; M1.0
		IF goesmax LT GOESmin THEN doit=0
	ENDIF
	IF cur_gev_ss NE -1 THEN BEGIN
		IF already_done_gev[cur_gev_ss] EQ 1 THEN doit=0
	ENDIF
;-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
	PRINT,'===================================================================================================================='
	IF doit NE 0 THEN BEGIN
		nbrtried=nbrtried+1				
		PRINT,'...................Doing '+anytim(/ECS,fl[j].peak_time)+' ................'
		IF doit EQ 2 THEN PRINT,'.................... (MINIMUM) ......................'
		;hedc_solar_event,flare_intv,STD=2-doit,MINIMUM=doit-1,/ZBUFFER,newdatadir=newdatadir,backgndtime=[fl[j].BCK_TIME[0],fl[j].BCK_TIME[1]-30],REMOVE_FROM_HEDC=REMOVE_FROM_HEDC,DEBUG=DEBUG, flarelistid=fl[j].ID_NUMBER
		nbrdone=nbrdone+1
		IF cur_gev_ss NE -1 THEN already_done_gev[cur_gev_ss]=1
	ENDIF ELSE PRINT,'...................NOT doing '+anytim(/ECS,fl[j].peak_time)+' ................'
		ptim,flare_intv
	PRINT,'===================================================================================================================='

	NEXTPLEASE:
	CATCH,/CANCEL
	HEAP_GC
	bla='sdf'
	READ,bla
ENDFOR;j

PRINT,'............There were '+strn(N_ELEMENTS(fl))+' flares in the flarelist.'
PRINT,'............Only '+strn(nbrtried)+' were attempted.'
PRINT,'............'+strn(nbrdone)+' were completed.'

THEEND:
PRINT,'IDL-OK'

END
