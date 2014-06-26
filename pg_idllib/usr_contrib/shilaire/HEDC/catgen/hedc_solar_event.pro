; 
;
;
;	EXAMPLE:
;		hedc_solar_event,'2002/07/23 '+['00:18:00','01:16:00'],/Zbuff,/STD,/BREAK,backgndtime='2002/07/23 '+['00:15:00','00:16:00']
;		hedc_solar_event,'2002/02/20 '+['10:55:00','11:15:00'],/Zbuff,/STD,/BREAK
;
;		hedc_solar_event,'2003/10/28 '+['11:00','11:40'],/STD,/ZBUFFER,newdatadir='NEWHEDCDATA/',/REMOVE_FROM_HEDC, flarelistid='3102825'
;
;		hedc_solar_event,'2002/04/16 '+['13:10','13:12'],/STD,/ZBUFFER,newdatadir='TEMP/',/DEBUG
;
;
; HISTORY:
;	before 2003/11/19: so long....
;	2003/11/19: modified imaging spectroscopy: uses hedc_migen.pro, and skips some time_intvs beyond 1 min after peak time...
;	2004/02/11: added automated movie making (psh_movie.pro) + some additional cleanup.
;	2004/03/11: added eventcode keyword...
;	2005/03/24: added keyword DELETE_BIG_FITS
;
;=======================================================================================================================
;=======================================================================================================================
; the following is to write an .einfo ascii file readable by Etzard for import.
PRO write_hedc_event,a,filename

b={HEDC_EVENT_SCHEMA_1,									$		
	s12_hle_code 	: a.EVENT_CODE,							$
	i07_hle_eventID : a.EVENT_ID_NUMBER,						$
	c04_hle_eventType : a.EVENT_TYPE,						$
	i05_hle_minEnergy : a.MIN_ENERGY_FOUND,						$
	i05_hle_MAXENERGY :	a.MAX_ENERGY_FOUND,					$
	f12_hle_totalCounts : a.TOTAL_COUNTS_12_25,					$
	f04_hle_distanceSun : -9999.,							$
	f04_hle_xpos : '-9999',								$
	f04_hle_ypos : '-9999',								$
	dat_hle_creationDate : anytim2oracle(a.CREATION_DATE),				$
	dat_hle_startDate : anytim2oracle(a.START_DATETIME),				$
	i08_hle_startTime : a.START_TIMEOFDAY,						$
	dat_hle_endDate	: anytim2oracle(a.END_DATETIME),				$
	i08_hle_endTime : a.END_TIMEOFDAY,						$
	i08_hle_duration : a.DURATION,							$
	dat_hle_pDate_3_6k	: anytim2oracle(a.PEAK_DATETIME_3_12),			$
	i08_hle_pTime_3_6k	: a.PEAK_TIMEOFDAY_3_12,				$
	f10_hle_pCts_3_6k	: a.PEAK_COUNTRATE_3_12,				$
	i08_hle_dura_3_6k	: a.TOTAL_COUNTS_3_12,					$
	dat_hle_pDate_12_25k: anytim2oracle(a.PEAK_DATETIME_12_25),			$	
	i08_hle_pTime_12_25k: a.PEAK_TIMEOFDAY_12_25,					$
	f10_hle_pCts_12_25k	: a.PEAK_COUNTRATE_12_25,				$
	i08_hle_dura_12_25k	: a.TOTAL_COUNTS_12_25,					$
	dat_hle_pDate_1_20M	: anytim2oracle(a.PEAK_DATETIME_25_100),		$
	i08_hle_pTime_1_20M	: a.PEAK_TIMEOFDAY_25_100,				$
	f10_hle_pCts_1_20M	: a.PEAK_COUNTRATE_25_100,				$
	i08_hle_dura_1_20M	: a.TOTAL_COUNTS_25_100,				$
	f06_hle_peakRatio	: STRN(a.PEAK_RATIO,format='(f12.3)'),			$
	i02_hle_multiplicity : a.MULTIPLICITY,						$
	s06_hle_activeRegion : STRING(a.ACTIVE_REGION),					$
	boo_hle_simulatedData: a.SIMULATED,						$
	boo_hle_saa :	a.SAA_FLAG,							$
	boo_hle_eclipse : a.ECLIPSE_FLAG,						$
	f10_hle_backgndRate : a.BCKGND_RATE_12_25,					$
	txt_hle_files : a.RELATED_FILES,						$
	s20_hle_reserve1	: a.RESERVE1,						$
	s20_hle_reserve2	: a.GOESCLASS,						$
	s20_hle_reserve3	: a.RESERVE3,						$
	s20_hle_reserve4	: a.RESERVE4,						$
	i10_hle_reserve1	: a.FLARELISTNBR,					$
	i10_hle_reserve2	: a.RESERVE6,						$
	f10_hle_reserve1	: a.GOESFLUX,						$
	f10_hle_reserve2	: a.RESERVE8,						$
	txt_hle_comments	: a.COMMENTS	}
		
if a.DISTANCE_FROM_SUN_CENTER ne -9999. then b.f04_hle_distanceSun = STRN(a.DISTANCE_FROM_SUN_CENTER,format='(f6.1)')
if a.X_OFFSET ne -9999. then BEGIN
	tmp=999.9 < (a.X_OFFSET > (-999.9))
	b.f04_hle_xpos = STRN(tmp,format='(f6.1)')
ENDIF
if a.Y_OFFSET ne -9999. then BEGIN
	tmp=999.9 < (a.Y_OFFSET > (-999.9))
	b.f04_hle_ypos = STRN(tmp,format='(f6.1)')
ENDIF

IF a.TOTAL_COUNTS_3_12 GT 99999999 THEN i08_hle_dura_3_6k=99999999

FILE_DELETE,filename,/QUIET
printai,a
printai,b
printai,b,filename=filename
END
;=======================================================================================================================
PRO hedc_make_event_struct,time_interval,etype,idnbr,a,	$
	creator=creator,einfodir=einfodir

if not keyword_set(einfodir) then einfodir=getlog('HEDC_DATA_DIR')

a={			EVENT_CREATOR: 'HEDC',				$
			EVENT_TYPE:'-9999',				$
			EVENT_CODE:'HEC',				$
			EVENT_ID_NUMBER:-9999L,				$
			MIN_ENERGY_FOUND:-9999,				$
			MAX_ENERGY_FOUND:-9999,				$
			X_OFFSET:-9999.,				$
			Y_OFFSET:-9999.,				$
			DISTANCE_FROM_SUN_CENTER:-9999.,		$
						
			START_DATETIME:	'-9999',			$
			START_TIMEOFDAY:-9999.D,			$
			END_DATETIME: 	'-9999',			$
			END_TIMEOFDAY:	-9999.D,			$
			DURATION: 	-9999.D,			$
			
			PEAK_DATETIME_12_25:'-9999',			$
			PEAK_TIMEOFDAY_12_25:-9999.D,			$
			PEAK_COUNTRATE_12_25:-9999.D,			$
			TOTAL_COUNTS_12_25:-9999L,			$			

			PEAK_RATIO	:-9999.,			$
			MULTIPLICITY	:-9999,				$
			ACTIVE_REGION	:-9999,				$
			
			PEAK_DATETIME_3_12: '-9999',		$
			PEAK_TIMEOFDAY_3_12:-9999.D,		$
			PEAK_COUNTRATE_3_12:-9999.D,		$
			TOTAL_COUNTS_3_12:-9999L,		$
			
			PEAK_DATETIME_25_100	:'-9999',	$
			PEAK_TIMEOFDAY_25_100	:-9999.D,	$
			PEAK_COUNTRATE_25_100	:-9999.D,	$
			TOTAL_COUNTS_25_100	:-9999L,	$	
			
			SIMULATED	:-9999,			$
			SAA_FLAG	:-9999,			$
			ECLIPSE_FLAG	:-9999,			$
			
			BCKGND_RATE_12_25:-9999.D,		$
			
			RESERVE1	:'-9999',				$	
			GOESCLASS	:'-9999',				$			
			RESERVE3	:'-9999',				$
			RESERVE4	:'-9999',				$
			
			FLARELISTNBR	:-9999L,				$
			RESERVE6	:-9999,					$			
			
			GOESFLUX	:-9999.D,				$
			RESERVE8	:-9999.D,				$
			
			RELATED_FILES : '',					$
			
			CREATION_DATE	:'-9999',				$
			COMMENTS	:'-9999'}



a.EVENT_TYPE=etype
a.EVENT_ID_NUMBER=idnbr
if keyword_set(creator) then a.EVENT_CREATOR=creator
if not keyword_set(stdoutmarker) then stdoutmarker='HEDCout '

;SIMULATED
a.SIMULATED=0

;CREATION_DATE
bla=systime()
bla=strmid(bla,8,2)+'-'+strmid(bla,4,3)+'-'+strmid(bla,22,2)+' '+strmid(bla,11,8)
a.CREATION_DATE=anytim(bla,/ECS)

; COMMENTS :
;;;;a.COMMENTS='None. //'+'None again. //'

;write to stdoutput with everything...
printai,a
END
;=======================================================================================================================



;=======================================================================================================================
;=======================================================================================================================
;=======================================================================================================================
;=======================================================================================================================
;=======================================================================================================================
;=======================================================================================================================
PRO hedc_solar_event,flare_time_interval,			$
	;ENV keywords:
	newdatadir=newdatadir,					$
	ZBUFFER=ZBUFFER,					$
	pictype=pictype,					$
	charsize=charsize,					$	
	BREAKONDPERROR=BREAKONDPERROR,				$
	NOFLAGCHECK=NOFLAGCHECK,				$	; IF set, will NOT check for SAA and NIGHT flags.
	addOBStime=addOBStime,					$	; at both ends, for a better overview..
	NO_ROLL_SOLUTION=NO_ROLL_SOLUTION,			$	; if set, does NOT use PMTRAS for as_roll_solution
	NOCHECKFILES=NOCHECKFILES,				$	; if set, will not check whether the fits files for the whole interval are present, according to hsi_filedb.fits ...
	REMOVE_FROM_HEDC=REMOVE_FROM_HEDC,			$	; if set, will erase all HLEs on HEDC with similar eventcode
	DELETE_BIG_FITS=DELETE_BIG_FITS,			$	; if set, will erase pten and imsp fits files at the very end...
	
	;info keywords:
	eventcode=eventcode,					$
	eventtype=eventtype,					$
	eventidnbr=eventidnbr,					$	
	creator=creator	,					$
	flarelistid=flarelistid,				$

	;the following keywords, if not set, will imply processing:
	xyoffset=xyoffset,					$	;SIDE EFFECT IF NOT SET: a full sun IMAGE is created
	backgndtime=backgndtime,				$	;FOR COUNTS and SPEX (not yet implemented), CAN be outside obs_time_interval
	NOFLARELISTSEARCH=NOFLARELISTSEARCH,			$

	;'to do' keywords
	FINE_FULLSUN=FINE_FULLSUN,				$	; will make a fine full sun image (i.e. 512x512 instead of 128x128))
	SC_IMG=SC_IMG,						$
	MEM_ROI=MEM_ROI,					$	; if set, will make a MEM image of ROI at peak time
	OS_PAGE=OS_PAGE,					$
	HSPG=HSPG,						$
	PHOENIX=PHOENIX,					$
	HP_SPG=HP_SPG,						$
	TRUE_COLOR=TRUE_COLOR,					$
	IMGPANEL=IMGPANEL,					$
	MINIMGPANEL=MINIMGPANEL,				$
	NO_LCO=NO_LCO,						$
	SOURCEMULTIPLICITY=SOURCEMULTIPLICITY,			$
	TIMEPROF=TIMEPROF,					$
	IMSPEC=IMSPEC,						$
	MOVIE=MOVIE,						$

	DEBUG=DEBUG,						$	;for debugging only!!!
	MINIMUM=MINIMUM,					$	
	STD=STD
;================================================================	
resolve_routine,'mpfit',/EITHER,/COMPILE_FULL,/NO_RECOMPILE

	startsystime=SYSTIME(/SEC)
	
	;Some parameters...
	DPjobNbr=0
	DPjobDone=0
	es=0	;Error_Status
	
	IF NOT KEYWORD_SET(SC_IMG) THEN SC_IMG=0
	IF NOT KEYWORD_SET(OS_PAGE) THEN OS_PAGE=0
	IF NOT KEYWORD_SET(HSPG) THEN HSPG=0
	IF NOT KEYWORD_SET(PHOENIX) THEN PHOENIX=0
	IF NOT KEYWORD_SET(MEM_ROI) THEN MEM_ROI=0
	IF NOT KEYWORD_SET(HP_SPG) THEN HP_SPG=0	
	IF NOT KEYWORD_SET(TRUE_COLOR) THEN TRUE_COLOR=0	
	IF NOT KEYWORD_SET(IMGPANEL) THEN IMGPANEL=0
	IF NOT KEYWORD_SET(MINIMGPANEL) THEN MINIMGPANEL=0
	IF NOT KEYWORD_SET(NO_LCO) THEN NO_LCO=0
	IF NOT KEYWORD_SET(TIMEPROF) THEN TIMEPROF=0
	IF NOT KEYWORD_SET(IMSPEC) THEN IMSPEC=0
	IF NOT KEYWORD_SET(MOVIE) THEN MOVIE=0
	IF KEYWORD_SET(STD) THEN BEGIN
		OS_PAGE=1 & TIMEPROF=1 & HP_SPG=1 & SC_IMG=0 & MEM_ROI=1 & HSPG=1  & TRUE_COLOR=0 & IMGPANEL=1 & MINIMGPANEL=0 & NO_LCO=1 & SOURCEMULTIPLICITY=1 & IMSPEC=1 & MOVIE=0 & DELETE_BIG_FITSFILES=0
		;OS_PAGE=1 & TIMEPROF=1 & HP_SPG=0 & SC_IMG=0 & MEM_ROI=0 & HSPG=0  & TRUE_COLOR=0 & IMGPANEL=1 & MINIMGPANEL=0 & NO_LCO=1 & SOURCEMULTIPLICITY=0 & IMSPEC=0 & MOVIE=1
		;IMSPEC will only be done if GOES class is above C3.0 level.
	ENDIF	
	IF KEYWORD_SET(MINIMUM) THEN BEGIN	
		OS_PAGE=1 & TIMEPROF=1 & MEM_ROI=0 & HP_SPG=1 & HSPG=1 & SOURCEMULTIPLICITY=1 & NOFLARELISTSEARCH=0 & IMGPANEL=0 & MINIMGPANEL=1 & NO_LCO=1 & IMSPEC=0 ;& NOFLAGCHECK=1 & MOVIE=0 & DELETE_BIG_FITSFILES=0
	ENDIF	
	IF KEYWORD_SET(DEBUG) THEN BEGIN
		BREAKONDPERROR=1 & REMOVE_FROM_HEDC=0 & SOURCEMULTIPLICITY=0
		NO_LCO=1  & OS_PAGE=0 & TIMEPROF=0 & HP_SPG=0 & SC_IMG=0 & MEM_ROI=0 & HSPG=0  & TRUE_COLOR=0 & IMGPANEL=1 & MINIMGPANEL=0 & FINE_FULLSUN=0 & IMSPEC=0 & MOVIE=0 & DELETE_BIG_FITSFILES=0 & NOCHECKFILES=1
	ENDIF
	IF exist(DELETE_BIG_FITS) THEN DELETE_BIG_FITSFILES=DELETE_BIG_FITS ELSE DELETE_BIG_FITSFILES=0
					
	CBAR=1
	DO_IMG=1
	
	;ENV:
	IF NOT KEYWORD_SET(newdatadir) THEN newdatadir='~/NEWHEDCDATA/'	;'/global/hercules/users/shilaire/NEWHEDCDATA/'	
	IF NOT KEYWORD_SET(addOBStime) THEN addOBStime=90.	; on both sides !!!
	obs_time_interval=anytim(flare_time_interval)+addOBStime*[-1.,1.]
	t0=anytim(obs_time_interval[0])
	IF KEYWORD_SET(ZBUFFER) THEN BEGIN
		old_device=!D.NAME
		SET_PLOT,'Z',/COPY
	ENDIF
	hedc_win
	!P.MULTI=0
	hessi_ct,/QUICK
	TVLCT,r,g,b,/GET
	IF NOT KEYWORD_SET(pictype) THEN pictype='png'
	IF NOT KEYWORD_SET(charsize) THEN BEGIN
		IF NOT KEYWORD_SET(ZBUFFER) THEN charsize=1.2 ELSE charsize=1.0
	ENDIF

	;info:
	IF NOT KEYWORD_SET(eventtype) THEN eventtype='S'
	IF NOT KEYWORD_SET(eventidnbr) THEN eventidnbr=-9999L	; not used, now (2002/04/26)
	IF NOT KEYWORD_SET(creator) THEN creator='HEDC'

; check whether the HESSI fits files are present or not.
	IF NOT KEYWORD_SET(NOCHECKFILES) THEN BEGIN
		tmp=all_hessi_files_present(obs_time_interval)
		IF tmp LT 1 THEN MESSAGE,'................... Some or all of the HESSI fits files are not there -- aborting............'			
	ENDIF
	

;//create ev_struct
	hedc_make_event_struct,flare_time_interval,eventtype,eventidnbr,ev_struct,CREATOR=creator,einfodir=newdatadir
	; at this point, we have all that is needed in ev_struct for future hedc_write_info_file.pro, except MIN & MAX energy found... (who cares: only for os01 DPs...)
	;	AND MOST IMPORTANTLY, EVENT_CODE !!!

	;processing:
	IF NOT KEYWORD_SET(backgndtime) THEN backgndtime=anytim(obs_time_interval[0])+[0.,60.]	
;=========================================================================================================================
	;FIRST: LIGHTCURVES !!!!
IF NOT KEYWORD_SET(NO_LCO) THEN BEGIN
		;must do a lightcurve...and find XXXtim...
		lco=hsi_lightcurve()
		ebands=[3,6,12,25,50,100,300]		; should never change this value .... I assumed some stuff, later on...
		TIMEBIN=4.  				; should never change this value .... I assumed some stuff, later on...
		lco->set,ltc_time_res=TIMEBIN,ltc_energy_band=ebands,SEG_INDEX_MASK=[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1]	;,/SP_SEMI_CAL
		
		lco->set,time_range=anytim(backgndtime)
		back_lc=lco->getdata()
	IF N_ELEMENTS(back_lc) EQ 1 THEN RETURN
		PRINT,'.........................RETRIEVING BACKGROUND LIGHTCURVE'
		back_times=lco->getdata(/xaxis)
		PRINT,' Mean of background at 12-25 keV: '+strn(MEAN(back_lc[*,2]))+' counts (timebinning: '+strn(TIMEBIN)+' seconds.)'
		PRINT,' Sigma of background at 12-25 keV: '+strn(STDEV(back_lc[*,2]))

	;average out to get the mean backgnd levels:
		FOR i=0,N_ELEMENTS(ebands)-2 DO BEGIN
			IF NOT EXIST(backgnd_lvl) THEN backgnd_lvl=MEAN(back_lc[*,i]) ELSE backgnd_lvl=[backgnd_lvl,MEAN(back_lc[*,i])]
		ENDFOR
		
		lco->set,time_range=anytim(obs_time_interval)
		PRINT,'.........................RETRIEVING RAW LIGHTCURVE'
		raw_lc=lco->getdata()
	IF N_ELEMENTS(raw_lc) EQ 1 THEN RETURN
		lc_all=raw_lc

;BACKGROUND SUBTRACTION
;	PRINT,'....... SUBTRACTING BACKGROUND LEVELS FROM LIGHTCURVES...'
;		FOR i=0,N_ELEMENTS(ebands)-2 DO lc_all[*,i]=raw_lc[*,i]-backgnd_lvl[i]
		
		taxis=lco->getdata(/xaxis)
ENDIF ELSE BEGIN
	oso=hsi_obs_summary()
	oso->set,obs_time=obs_time_interval
	tmp=oso->getdata(class_name='hsi_obs_summ_rate')
	TIMEBIN=oso->get(class_name='hsi_obs_summ_rate',/TIME_INTV)
	lc_all=TRANSPOSE(tmp.COUNTRATE[0:5])*TIMEBIN*9.
	taxis=oso->getdata(class_name='hsi_obs_summ_rate',/TIME_arr)
ENDELSE
;------------------------------------------------------------------------------------------------------------------------
	;peaktim = where it is highest in 12-25 range
		maxcounts=max(lc_all[*,2],ss)
		ss_peak=ss[0]
		PRINT,'Peak number of counts in our timebin: '+strn(maxcounts)
		peaktim=taxis[ss_peak]
		print,'PEAK TIME is: '+anytim(peaktim,/ECS)
		ev_struct.PEAK_DATETIME_12_25=anytim(peaktim,/ECS)
		ev_struct.PEAK_TIMEOFDAY_12_25=anytim(peaktim,/time_only)


;//define eventcode : need peaktim
	tmp=anytim(peaktim,/ex)
	IF NOT KEYWORD_SET(eventcode) THEN eventcode='HX'+eventtype+int2str(tmp[6]-2000,1)+int2str(tmp[5],2)+int2str(tmp[4],2)+int2str(tmp[0],2)+int2str(tmp[1],2)
	ev_struct.EVENT_CODE=eventcode

	;peak rates
		ev_struct.PEAK_COUNTRATE_12_25=lc_all[ss[0],2]/TIMEBIN
		ev_struct.PEAK_RATIO=lc_all[ss[0],3]/lc_all[ss[0],2]	; 25-50/12-25

	;ss_beg and ss_end:
		ss=WHERE(taxis GE anytim(flare_time_interval[0]))
		ss_beg=ss[0]
		ss=WHERE(taxis GE anytim(flare_time_interval[1]))
		ss_end=ss[0]

	;get halftim1&2
		;OLD WAY:
		;ss=WHERE(lc_all[*,2] ge maxcounts*0.5)
		;halftim1=taxis[ss[0]]
		;halftim2=taxis[ss[N_ELEMENTS(ss)-1]]
		;NEW WAY:
		halftim1=0.5*(taxis[ss_beg]+taxis[ss_peak])
		halftim2=0.5*(taxis[ss_peak]+taxis[ss_end])
		print,'HALF TIMES are: '+anytim(halftim1,/ECS)+' and '+anytim(halftim2,/ECS)

		tmp=taxis[ss_beg]
		ev_struct.START_DATETIME=anytim(tmp,/ECS)
		ev_struct.START_TIMEOFDAY=anytim(tmp,/time_only)
		tmp=taxis(ss_end)
		ev_struct.END_DATETIME=anytim(tmp,/ECS)
		ev_struct.END_TIMEOFDAY=anytim(tmp,/time_only)
		ev_struct.DURATION=anytim(ev_struct.END_DATETIME)-anytim(ev_struct.START_DATETIME)

		ev_struct.TOTAL_COUNTS_3_12=	TOTAL(lc_all[ss_beg:ss_end,0:1])/1000.
		ev_struct.TOTAL_COUNTS_12_25=	TOTAL(lc_all[ss_beg:ss_end,2])/1000.
		ev_struct.TOTAL_COUNTS_25_100=	TOTAL(lc_all[ss_beg:ss_end,3:4])/1000.

		tmp=max(TOTAL(lc_all(*,0:1),2),ss)
		ev_struct.PEAK_DATETIME_3_12=anytim(taxis[ss[0]],/ECS)
		ev_struct.PEAK_COUNTRATE_3_12=tmp/TIMEBIN
		ev_struct.PEAK_TIMEOFDAY_3_12=anytim(taxis[ss[0]],/time_only)

		tmp=max(TOTAL(lc_all[*,3:4],2),ss)
		ev_struct.PEAK_DATETIME_25_100=anytim(taxis[ss[0]],/ECS)
		ev_struct.PEAK_COUNTRATE_25_100=tmp/TIMEBIN
		ev_struct.PEAK_TIMEOFDAY_25_100=anytim(taxis[ss[0]],/time_only)

IF NOT KEYWORD_SET(NO_LCO) THEN BEGIN
		info=lco->get()
		hedc_win,768,512
		myct3
		TVLCT,r,g,b,/GET
	;PLOT & SAVE linear lightcurve:
		DPjobnbr=DPjobnbr+1		
		IF NOT KEYWORD_SET(BREAKONDPERROR) THEN BEGIN CATCH,es & IF es NE 0 THEN BEGIN es=0 & CATCH,/CANCEL & GOTO,LABEL01 & ENDIF & ENDIF
		rootfil=newdatadir+'HEDC_DP_lc00_'+eventcode
		;lco->plot,charsize=charsize,title='Non-calibrated HESSI counts'
			draw_hsi_lc,lco,title='Non-calibrated HESSI counts, all segments',ebands=[3,6,12,25,50,100,300]
			TVLCT,r,g,b,/GET
		;DISPLAY BACKGROUND interval:
			tmp=REPLICATE(0.18*(!Y.CRANGE(1)-!Y.CRANGE[0])+!Y.CRANGE[0],N_ELEMENTS(back_times))
			oplot,back_times-t0,tmp,thick=3,color=250
			XYOUTS,/DATA,back_times[0]-t0,0.2*(!Y.CRANGE[1]-!Y.CRANGE[0])+!Y.CRANGE[0],'BACKGROUND',color=250
		CALL_PROCEDURE,'write_'+pictype,rootfil+'.'+pictype,TVRD(),r,g,b
		IF FILE_EXIST(rootfil+'.'+pictype) THEN hedc_write_info_file,'lc0',ev_struct,info,rootfil+'.info'
		DPjobdone=DPjobdone+1
		LABEL01:
	;another ylog:
		DPjobnbr=DPjobnbr+1		
		IF NOT KEYWORD_SET(BREAKONDPERROR) THEN BEGIN CATCH,es & IF es NE 0 THEN BEGIN es=0 & CATCH,/CANCEL & GOTO,LABEL02 & ENDIF & ENDIF
		rootfil=newdatadir+'HEDC_DP_lc01_'+eventcode
		;lco->plot,/ylog,charsize=charsize,title='Non-calibrated HESSI counts'
			draw_hsi_lc,lco,title='Non-calibrated HESSI counts, all segments',ebands=[3,6,12,25,50,100,300],/YLOG
			TVLCT,r,g,b,/GET
		;DISPLAY BACKGROUND interval:
			tmp=REPLICATE(0.48*(!Y.CRANGE[1]-!Y.CRANGE[0])+!Y.CRANGE[0],N_ELEMENTS(back_times))
			oplot,back_times-t0,10^tmp,thick=3,color=250
			XYOUTS,/DATA,back_times[0]-t0,10^(0.5*(!Y.CRANGE[1]-!Y.CRANGE[0])+!Y.CRANGE[0]),'BACKGROUND',color=250
		CALL_PROCEDURE,'write_'+pictype,rootfil+'.'+pictype,TVRD(),r,g,b
		IF FILE_EXIST(rootfil+'.'+pictype) THEN hedc_write_info_file,'lc1',ev_struct,info,rootfil+'.info'
		DPjobdone=DPjobdone+1		
		LABEL02:

		obj_destroy,lco		
ENDIF		
;DETERMINE SPIN PERIOD=========================================================================
	spin_period=rhessi_get_spin_period(peaktim,/DEF)
	PRINT,'----------------------- SPIN PERIOD at peak time: '+strn(spin_period)+' s.'
;===============================================================================================================================================
;OBS.SUMM. & trajectory STUFF
IF OS_PAGE NE 0 THEN BEGIN
	DPjobnbr=DPjobnbr+1		
	IF NOT KEYWORD_SET(BREAKONDPERROR) THEN BEGIN CATCH,es & IF es NE 0 THEN BEGIN es=0 & CATCH,/CANCEL & GOTO,LABEL11 & ENDIF & ENDIF
	rootfilename=newdatadir+'HEDC_DP_os04_'+eventcode
	PRINT,'.........................OBS. SUMM. PAGE'
	obs_summ_page,anytim(obs_time_interval)+[-90,270],filename=rootfilename+'.'+pictype
	IF FILE_EXIST(rootfilename+'.'+pictype) THEN hedc_write_info_file,'os4',ev_struct,obs_time_interval,rootfilename+'.info'
	
	hedc_win,630,512
	my_hessi_ct,colors
	plot_hessi_pos,obs_time_interval
	rootfilename=newdatadir+'HEDC_DP_os01_'+eventcode
	TVLCT,r,g,b,/GET
	CALL_PROCEDURE,'write_'+pictype,rootfilename+'.'+pictype,TVRD(),r,g,b
	IF FILE_EXIST(rootfilename+'.'+pictype) THEN hedc_write_info_file,'os1',ev_struct,obs_time_interval,rootfilename+'.info'
	DPjobdone=DPjobdone+1
	LABEL11:
	hessi_ct,/QUICK
ENDIF
;===============================================================================================================================================
;HEDC_TIME PROFILES
IF TIMEPROF NE 0 THEN BEGIN
	DPjobnbr=DPjobnbr+1		
	IF NOT KEYWORD_SET(BREAKONDPERROR) THEN BEGIN CATCH,es & IF es NE 0 THEN BEGIN es=0 & CATCH,/CANCEL & HELP, /Last_Message, Output=theErrorMessage & FOR j=0,N_Elements(theErrorMessage)-1 DO PRINT, theErrorMessage[j] & GOTO,LABELTIMEPROF & ENDIF & ENDIF
	rootfilename=newdatadir+'HEDC_DP_os05_'+eventcode
	PRINT,'.........................HEDC TIME PROFILES'
	hedc_time_profiles,anytim(obs_time_interval,/yohkoh),filename=rootfilename+'.'+pictype,/NOCRASH,/NO_RHESSI_SPG
	IF FILE_EXIST(rootfilename+'.'+pictype) THEN hedc_write_info_file,'os5',ev_struct,obs_time_interval,rootfilename+'.info'
	
	DPjobdone=DPjobdone+1
	LABELTIMEPROF:
	hessi_ct,/QUICK
ENDIF
;===============================================================================================================================================
; HESSI SPECTROGRAM
IF HSPG NE 0 THEN BEGIN
	DPjobnbr=DPjobnbr+1		
	IF NOT KEYWORD_SET(BREAKONDPERROR) THEN BEGIN CATCH,es & IF es NE 0 THEN BEGIN es=0 & CATCH,/CANCEL & HELP,/Last_message,output=tmptmp & PRINT,tmptmp & GOTO,LABEL12 & ENDIF & ENDIF
	hedc_win,768,512
	PRINT,'.........................HESSI SPECTROGRAM'
	hedc_hsi_spg,anytim(obs_time_interval),/high
	rootfilename=newdatadir+'HEDC_DP_hsg0_'+eventcode
	TVLCT,r,g,b,/GET
	CALL_PROCEDURE,'write_'+pictype,rootfilename+'.'+pictype,TVRD(),r,g,b
	IF FILE_EXIST(rootfilename+'.'+pictype) THEN hedc_write_info_file,'hsg',ev_struct,obs_time_interval,rootfilename+'.info'
	DPjobdone=DPjobdone+1
	LABEL12:
ENDIF
;===============================================================================================================================================
; HESSI and PHOENIX SPECTROGRAMS
IF HP_SPG NE 0 THEN BEGIN
	IF NOT KEYWORD_SET(BREAKONDPERROR) THEN BEGIN CATCH,es & IF es NE 0 THEN BEGIN es=0 & CATCH,/CANCEL & HELP,/Last_message,output=tmptmp & PRINT,tmptmp & GOTO,LABEL20 & ENDIF & ENDIF
	tmp=rapp_get_spectrogram(obs_time_interval)
	IF datatype(tmp) NE 'STR' THEN BEGIN
		DPjobnbr=DPjobnbr+1		
		hedc_win,768,512
		PRINT,'.........................PHOENIX AND HESSI SPECTROGRAM'
		LOADCT,5
		clear_utplot
		rapp_cmb_spg, obs_time_interval,/UT
		rootfilename=newdatadir+'HEDC_DP_spg1_'+eventcode
		TVLCT,r,g,b,/GET
		CALL_PROCEDURE,'write_'+pictype,rootfilename+'.'+pictype,TVRD(),r,g,b
		IF FILE_EXIST(rootfilename+'.'+pictype) THEN hedc_write_info_file,'hps',ev_struct,obs_time_interval,rootfilename+'.info'
		DPjobdone=DPjobdone+1
	ENDIF
	LABEL20:
ENDIF
;===============================================================================================================================================
; PHOENIX spectrogram
IF PHOENIX NE 0 THEN BEGIN
	DPjobnbr=DPjobnbr+1
	IF NOT KEYWORD_SET(BREAKONDPERROR) THEN BEGIN CATCH,es & IF es NE 0 THEN BEGIN es=0 & CATCH,/CANCEL & HELP,/Last_message,output=tmptmp & PRINT,tmptmp & GOTO,LABEL13 & ENDIF & ENDIF
	hedc_win,768,512
	loadct,5
	PRINT,'.........................PHOENIX SPECTROGRAM'
	data=rapp_get_spectrogram(obs_time_interval,xaxis=xaxis,yaxis=yaxis,/ELIM,/BACK)
	IF datatype(data) EQ 'STR' THEN GOTO,LABEL13
	rapp_paint_spectrogram,data,xaxis,yaxis,/log,/despike
	rootfilename=newdatadir+'HEDC_DP_spg0_'+eventcode
	TVLCT,r,g,b,/GET
	CALL_PROCEDURE,'write_'+pictype,rootfilename+'.'+pictype,TVRD(),r,g,b
	IF FILE_EXIST(rootfilename+'.'+pictype) THEN hedc_write_info_file,'spg',ev_struct,obs_time_interval,rootfilename+'.info'
	DPjobdone=DPjobdone+1
	LABEL13:
ENDIF
;===============================================================================================================================================
PRINT,'Now running rhessi_find_flare_position.pro.......................'
flarepos=rhessi_find_flare_position(flare_time_interval,peaktim,time_intv=peak_accum_intv,/FURTHER,/REFINE,eband=[6,25])
HEAP_GC
IF anytim(peak_accum_intv[0]) LT anytim('2000/01/01') THEN peak_accum_intv=anytim(flare_time_interval)

IF NOT KEYWORD_SET(xyoffset) THEN BEGIN		
	IF N_ELEMENTS(flarepos) EQ 2 THEN BEGIN
		xoffset=flarepos[0]
		yoffset=flarepos[1]
		PRINT,'Flare position: '+strn(xoffset)+' '+strn(yoffset)
	ENDIF ELSE BEGIN PRINT,'.........flare finding has failed...SHOULD stop now with any imagery...' & DO_IMG=0 & xoffset=0 & yoffset=0 & ENDELSE
ENDIF ELSE BEGIN
	xoffset=xyoffset[0]
	yoffset=xyoffset[1]
ENDELSE
		
ev_struct.DISTANCE_FROM_SUN_CENTER=LONG( sqrt(xoffset^2 + yoffset^2) )
ev_struct.X_OFFSET=xoffset
ev_struct.Y_OFFSET=yoffset
;===============================================================================================================================================
;FULL SUN IMAGE (for now: try it always, whatever the status of the xyoffset keyword...)
		DPjobnbr=DPjobnbr+1		
		IF NOT KEYWORD_SET(BREAKONDPERROR) THEN BEGIN CATCH,es & IF es NE 0 THEN BEGIN es=0 & CATCH,/CANCEL & PRINT,'.......Full Sun image failed....' & GOTO,LABEL03 & ENDIF & ENDIF
		IF KEYWORD_SET(FINE_FULLSUN) THEN BEGIN
			imgdim=512
			pixsiz=4
		ENDIF ELSE BEGIN
			imgdim=128
			pixsiz=16
		ENDELSE
		
		hessi_ct,/QUICK
		TVLCT,r,g,b,/GET
				
		imo=hsi_image()		
		imo->set,time_range=peak_accum_intv
		imo->set,image_dim=imgdim,pixel_size=pixsiz,det_index_mask=[0,0,0,0,0,0,1,1,1],image_alg='back',uniform=1
		imo->set,xyoffset=[0,0],energy_band=[6,25]
		IF NOT KEYWORD_SET(NO_ROLL_SOLUTION) THEN imo->set,as_roll_solution='PMT'  $;, ras_time_extension=[-500,500]	
		ELSE imo->set,as_roll_solution='FIX',as_spin_period=spin_period
		imo->set,/DP_ENABLE,UNIFORM_WEIGHTING=1
		imo->set_no_screen_output
		hedc_win
		PRINT,'.........................FULL SUN image'
		fullsunimg=imo->getdata()
		IF fullsunimg[0,0] EQ -1 THEN PRINT,'... full-Sun image failed...'
		IF CBAR EQ 1 THEN imo->plot,/limb,charsize=charsize,/CBAR  ELSE imo->plot,margin=0.07,/limb,charsize=charsize
		
		rootfilename=newdatadir+'HEDC_DP_im00_'+eventcode
		CALL_PROCEDURE,'write_'+pictype,rootfilename+'.'+pictype,TVRD(),r,g,b
		info=imo->get()
		IF FILE_EXIST(rootfilename+'.'+pictype) THEN hedc_write_info_file,'im',ev_struct,info,rootfilename+'.info'
		imo->fitswrite,fitsfile=rootfilename+'.fits',/CREATE
		DPjobdone=DPjobdone+1		
		LABEL03:
;===============================================================================================================================================						
;HESSI FLARE LIST NUMBER :
	IF NOT KEYWORD_SET(NOFLARELISTSEARCH) THEN BEGIN
		PRINT,'HESSI FLARE LIST NUMBER.......................'
		IF KEYWORD_SET(flarelistid) THEN ev_struct.FLARELISTNBR=flarelistid ELSE BEGIN
			flo = obj_new('hsi_flare_list')
			flo ->set,obs_time_interval = [ev_struct.START_DATETIME,ev_struct.END_DATETIME]
			bla = flo->getdata()
			if datatype(bla) eq 'STC' then ev_struct.FLARELISTNBR = bla[0].ID_NUMBER
			obj_destroy,flo
			delvarx,flo
		ENDELSE
	ENDIF 
;===============================================================================================================================================						
;SAA & NIGHT FLAGS
	IF NOT KEYWORD_SET(NOFLAGCHECK) THEN BEGIN
		es=0
		IF NOT KEYWORD_SET(BREAKONDPERROR) THEN BEGIN CATCH,es & IF es NE 0 THEN BEGIN es=0 & CATCH,/CANCEL & HELP,/Last_message,output=tmptmp & PRINT,tmptmp & GOTO,LABEL16 & ENDIF & ENDIF		
		oso=hsi_obs_summary()
		oso->set,obs_time_interval=obs_time_interval
		flagdata_struct=oso->getdata(class_name='obs_summ_flag')
		flagdata=flagdata_struct.FLAGS
		ss=WHERE(flagdata[0,*] NE 0)
		IF ss[0] NE -1 THEN ev_struct.SAA_FLAG=1 ELSE ev_struct.SAA_FLAG=0
		ss=WHERE(flagdata(1,ss_beg:ss_end) NE 0)
		IF ss[0] NE -1 THEN ev_struct.ECLIPSE_FLAG=1 ELSE ev_struct.ECLIPSE_FLAG=0
		LABEL16:
		OBJ_DESTROY,oso
	ENDIF
;===============================================================================================================================================						
;GOES maximum flux during flare, in microwatts per square meters (C-class)
IF NOT KEYWORD_SET(BREAKONDPERROR) THEN BEGIN CATCH,es & IF es NE 0 THEN BEGIN CATCH,/CANCEL & es=0 & GOTO,LABEL_GOESFLUX & ENDIF & ENDIF		
	;find flare class, using GOES-8 3-second data.
	;rd_goes,goestime,goesdata,trange=anytim(obs_time_interval,/yohkoh)
	goo=OBJ_NEW('goes')
	goo->read,anytim(obs_time_interval[0],/yoh),anytim(obs_time_interval[1],/yoh),err=err
	IF err EQ '' THEN BEGIN
		goesdata=goo->getdata(utbase=utbase,times=goestime)
		themax=MAX(goesdata[*,0])
		ev_struct.GOESFLUX=LONG(themax*1d8)/100.
		PRINT,'Goes flux [uW/m^2]: '+strn(ev_struct.GOESFLUX)
		ev_struct.GOESCLASS=hedc_togoes(themax)
		PRINT,'Goes class: '+ev_struct.GOESCLASS
		IF ev_struct.GOESFLUX LT 1. THEN IMSPEC=0	;don't do ImSpec if below C1.0 level...
	ENDIF ELSE PRINT,'No GOES data available...'
	goo->flush,1
	OBJ_DESTROY,goo

LABEL_GOESFLUX:
;===============================================================================================================================================						
IF datatype(imo) EQ 'OBJ' THEN BEGIN
	OBJ_DESTROY,imo
	HEAP_GC
	imo=hsi_image()
	PRINT,anytim(peak_accum_intv,/ECS)
	imo->set,time_range=peak_accum_intv
	imo->set,xyoffset=[xoffset,yoffset]
ENDIF
;===============================================================================================================================================
;  CLEAN image of ROI at peak time, 12-25 keV
IF ((MEM_ROI NE 0) AND (DO_IMG NE 0)) THEN BEGIN
	DPjobnbr=DPjobnbr+1
	es=0
	IF NOT KEYWORD_SET(BREAKONDPERROR) THEN BEGIN CATCH,es & IF es NE 0 THEN BEGIN CATCH,/CANCEL & es=0 & HELP,/Last_message,output=tmptmp & PRINT,tmptmp  & GOTO,LABEL_CLEAN_ROI & ENDIF & ENDIF		

	hedc_win	
	hessi_ct,/QUICK
	TVLCT,r,g,b,/GET
	
	imo->set,image_alg='clean',pixel_size=2.,image_dim=128,det_index_mask=[0,0,1,1,1,1,1,1,0],energy_band=[12,25]
	imo->set_no_screen_output
	PRINT,'.........................ROI CLEAN image: '+anytim(peaktim,/ECS)+'    eband: 12-25 keV.'
	IF CBAR EQ 1 THEN imo->plot,grid=10,charsize=charsize,/CBAR  ELSE imo->plot,margin=0.07,grid=10,charsize=charsize

	rootfilename=newdatadir+'HEDC_DP_im01_'+eventcode
	CALL_PROCEDURE,'write_'+pictype,rootfilename+'.'+pictype,TVRD(),r,g,b
	info=imo->get()
	IF FILE_EXIST(rootfilename+'.'+pictype) THEN hedc_write_info_file,'im',ev_struct,info,rootfilename+'.info'
	imo->fitswrite,fitsfile=rootfilename+'.fits',/CREATE
	DPjobdone=DPjobdone+1
	
	LABEL_CLEAN_ROI:
;MEM for exact same parameters...(for comparison with MEM, above)
	DPjobnbr=DPjobnbr+1
	es=0
	IF NOT KEYWORD_SET(BREAKONDPERROR) THEN BEGIN CATCH,es & IF es NE 0 THEN BEGIN CATCH,/CANCEL & es=0 & HELP,/Last_message,output=tmptmp & PRINT,tmptmp  & GOTO,LABEL_MEM_ROI & ENDIF & ENDIF		
	
	hedc_win	
	hessi_ct,/QUICK
	TVLCT,r,g,b,/GET
		
	imo->set,image_alg='mem'
	imo->set_no_screen_output
	PRINT,'.........................ROI MEM image: '+anytim(peaktim,/ECS)+'    eband: 12-25 keV.'
	IF CBAR EQ 1 THEN imo->plot,grid=10,charsize=charsize,/CBAR  ELSE imo->plot,margin=0.07,grid=10,charsize=charsize
			
	rootfilename=newdatadir+'HEDC_DP_im02_'+eventcode
	CALL_PROCEDURE,'write_'+pictype,rootfilename+'.'+pictype,TVRD(),r,g,b
	info=imo->get()
	IF FILE_EXIST(rootfilename+'.'+pictype) THEN hedc_write_info_file,'im',ev_struct,info,rootfilename+'.info'
	imo->fitswrite,fitsfile=rootfilename+'.fits',/CREATE
	DPjobdone=DPjobdone+1
	LABEL_MEM_ROI:
ENDIF
;=============================================================================================================================================================
	;=====================================================================
	write_hedc_event,ev_struct,newdatadir+'HEDC_EVENT_'+eventcode+'.einfo'
	;=====================================================================
;===============================================================================================================================================						
; SC PANEL
IF ((SC_IMG NE 0) AND (DO_IMG NE 0)) THEN BEGIN
	DPjobnbr=DPjobnbr+1
	IF NOT KEYWORD_SET(BREAKONDPERROR) THEN BEGIN CATCH,es & IF es NE 0 THEN BEGIN es=0 & CATCH,/CANCEL & HELP,/Last_message,output=tmptmp & PRINT,tmptmp  & GOTO,LABEL05 & ENDIF & ENDIF
	PRINT,'.........................SC PANEL'
 	imo->set,image_alg='back',energy_band=[12,25],time_range=peak_accum_intv,pixel_size=1
	hedc_win,900
	;hessi_ct,/QUICK
	LOADCT,5
	TVLCT,r,g,b,/GET
	
	hedc_sc_panel_plot,imo	;,/SHADE_SURF

	rootfilename=newdatadir+'HEDC_DP_pscA_'+eventcode
	CALL_PROCEDURE,'write_'+pictype,rootfilename+'.'+pictype,TVRD(),r,g,b
	IF FILE_EXIST(rootfilename+'.'+pictype) THEN hedc_write_info_file,'scA',ev_struct,peak_accum_intv,rootfilename+'.info'	
	DPjobdone=DPjobdone+1
	LABEL05:
	!P.MULTI=0
ENDIF
;===============================================================================================================================================
;TRUE COLOR IMAGE...
IF ((TRUE_COLOR NE 0) AND (DO_IMG NE 0)) THEN BEGIN
	DPjobnbr=DPjobnbr+1
	es=0
	IF NOT KEYWORD_SET(BREAKONDPERROR) THEN BEGIN CATCH,es & IF es NE 0 THEN BEGIN CATCH,/CANCEL & es=0 & HELP,/Last_message,output=tmptmp & PRINT,tmptmp  & GOTO,LABEL_TRUE_COLOR & ENDIF & ENDIF		

	hedc_win	
	hessi_ct,/QUICK
	TVLCT,r,g,b,/GET
	
	imo->set,image_alg='back',pixel_size=1.,image_dim=128,det_index_mask=[0,0,1,1,1,1,1,1,0],energy_band=[3,12]
	imo->set_no_screen_output
	PRINT,'.........................TRUE COLOR IMAGE: '+anytim(peaktim,/ECS)+'    eband: 3-12 keV.'
	Rimg=BYTSCL(CONGRID(imo->getdata(),512,512),MIN=0.)
	imo->set,energy_band=[12,25]
	PRINT,'.........................TRUE COLOR IMAGE: '+anytim(peaktim,/ECS)+'    eband: 12-25 keV.'
	Gimg=BYTSCL(CONGRID(imo->getdata(),512,512),MIN=0.)
	imo->set,energy_band=[25,300],REAR=1
	PRINT,'.........................TRUE COLOR IMAGE: '+anytim(peaktim,/ECS)+'    eband: 25-300 keV.'
	Bimg=BYTSCL(CONGRID(imo->getdata(),512,512),MIN=0.)

	S=SIZE(Rimg)
	trueimg=BYTARR(S[1],S[2],3)
	trueimg[*,*,0]=Rimg
	trueimg[*,*,1]=Gimg
	trueimg[*,*,2]=Bimg
			
	rootfilename=newdatadir+'HEDC_DP_im10_'+eventcode
	write_jpeg,rootfilename+'.jpg',trueimg,TRUE=3
	info=imo->get()
	info.ENERGY_BAND=[6,300]
	IF FILE_EXIST(rootfilename+'.jpg') THEN hedc_write_info_file,'tc1',ev_struct,info,rootfilename+'.info'
	DPjobdone=DPjobdone+1
	
	LABEL_TRUE_COLOR:
	imo->set,REAR=0
ENDIF
;===============================================================================================================================================
IF datatype(imo) EQ 'OBJ' THEN OBJ_DESTROY,imo
HEAP_GC
;===============================================================================================================================================
;IMGPANEL (NxM panel): simply do 1 minute image during whole flare duration, in different energy bands.
IF ((IMGPANEL NE 0) AND (DO_IMG NE 0)) THEN BEGIN
	es=0
	IF NOT KEYWORD_SET(BREAKONDPERROR) THEN BEGIN CATCH,es & IF es NE 0 THEN BEGIN CATCH,/CANCEL & es=0 & HELP,/Last_message,output=tmptmp & PRINT,tmptmp  & GOTO,LABEL_IMGPANEL & ENDIF & ENDIF		
	DPjobnbr=DPjobnbr+1
	hedc_tepgen, flare_time_interval,[xoffset,yoffset],newdatadir=newdatadir,eventcode=eventcode,ev_struct=ev_struct,eventtype=eventtype,imagetesseract=hedcimagecube
	DPjobdone=DPjobdone+1
	LABEL_IMGPANEL:
ENDIF
;===============================================================================================================================================
;1xM panel
IF ((MINIMGPANEL NE 0) AND (DO_IMG NE 0)) THEN BEGIN
	es=0
	IF NOT KEYWORD_SET(BREAKONDPERROR) THEN BEGIN CATCH,es & IF es NE 0 THEN BEGIN CATCH,/CANCEL & es=0 & HELP,/Last_message,output=tmp & PRINT,tmp  & GOTO,LABEL_MINIMUM_IMGPANEL & ENDIF & ENDIF		
	DPjobnbr=DPjobnbr+1
	hedc_tepgen, peak_accum_intv,[xoffset,yoffset],time_intvs=peak_accum_intv,newdatadir=newdatadir,eventcode=eventcode,ev_struct=ev_struct,eventtype=eventtype,imagetesseract=hedcimagecube
	DPjobdone=DPjobdone+1
	LABEL_MINIMUM_IMGPANEL:
ENDIF
;===============================================================================================================================================
;OBJ_DESTROY,imo
;delvarx,imo
;HEAP_GC
;===============================================================================================================================================						
;SOURCE MULTIPLICITY	
	IF KEYWORD_SET(SOURCEMULTIPLICITY) THEN BEGIN
		DPjobnbr=DPjobnbr+1
		es=0
		IF NOT KEYWORD_SET(BREAKONDPERROR) THEN BEGIN CATCH,es & IF es NE 0 THEN BEGIN CATCH,/CANCEL & es=0 & HELP,/Last_message,output=tmptmp & PRINT,tmptmp  & GOTO,LABEL_SOURCEMULTIPLICITY & ENDIF & ENDIF		
		PRINT,'.........................SOURCE MULTIPLICITY'
		nb=hedc_nbr_sources(hedcimagecube)
		IF nb LE 0 THEN nb=-9999
		ev_struct.MULTIPLICITY=nb
		DPjobdone=DPjobdone+1		
		;rewrite einfo file with source multiplicity info.
		write_hedc_event,ev_struct,newdatadir+'HEDC_EVENT_'+eventcode+'.einfo'			
		LABEL_SOURCEMULTIPLICITY:			
	ENDIF
;===============================================================================================================================================
;IMSPEC
IF ((IMSPEC NE 0) AND (DO_IMG NE 0)) THEN BEGIN
	DPjobnbr=DPjobnbr+1		
	IF NOT KEYWORD_SET(BREAKONDPERROR) THEN BEGIN CATCH,es & IF es NE 0 THEN BEGIN es=0 & CATCH,/CANCEL & HELP,/Last_message,output=tmptmp & PRINT,tmptmp & GOTO,LABELIMSPEC & ENDIF & ENDIF
	rootfilename=newdatadir+'HEDC_DP_imsp_'+eventcode
	PRINT,'.........................IMAGING SPECTROSCOPY: generating images...'+eventcode
	hedc_migen, flare_time_interval,[xoffset,yoffset], rootfilename, deltat=60., eventcode=eventcode,ev_struct=ev_struct,/IMSPECebands	;max_nbr_intvs=20, /REDUCE, /SKIP
	PRINT,'.........................IMAGING SPECTROSCOPY: doing imspec proper...'+eventcode
	hedc_imspec, -1, [2,8,12],fitsfile=rootfilename+'.fits'	;,SKIP=2
PRINT,'La suite...'
	TVLCT,r,g,b,/GET
	CALL_PROCEDURE,'write_'+pictype,rootfilename+'.'+pictype,TVRD(),r,g,b	
	DPjobdone=DPjobdone+1
	LABELIMSPEC:
	IF NOT FILE_EXIST(rootfilename+'.'+pictype) THEN FILE_DELETE,rootfilename+'.info',/QUIET
ENDIF
;===============================================================================================================================================
;;MOVIE: TRACE
;IF ((MOVIE NE 0) AND (DO_IMG NE 0)) THEN BEGIN
;	DPjobnbr=DPjobnbr+1		
;	IF NOT KEYWORD_SET(BREAKONDPERROR) THEN BEGIN CATCH,es & IF es NE 0 THEN BEGIN es=0 & CATCH,/CANCEL & HELP,/Last_message,output=tmptmp & PRINT,tmptmp & GOTO,LABELMOVIE & ENDIF & ENDIF
;
;	outmpegdir='/global/hercules/users/hedc/public_html/movies/'+psh_time2dir(flare_time_interval[0])
;	IF NOT FILE_TEST(outmpegdir,/DIR) THEN FILE_MKDIR,outmpegdir
;	cube=psh_movie({type: 'TRACE195', time_intv: anytim(flare_time_interval,/ECS)}, {file: newdatadir+'HEDC_DP_pten_'+eventcode+'.fits' , eband_ss:[1,3]},dir=newdatadir,mpeg=outmpegdir+eventcode+'.mpg')
;	;could use ImSpec stuff instead... just need to replace 'pten' by 'imsp' and change eband_ss...
;
;	DPjobdone=DPjobdone+1
;	movie_link='<A HREF="http://www.hedc.ethz.ch/www/movies/'+psh_time2dir(flare_time_interval[0])+eventcode+'.mpg">TRACE-RHESSI movie</A>'
;	IF N_ELEMENTS(cube) GT 1 THEN BEGIN
;		IF ev_struct.COMMENTS EQ '-9999' THEN ev_struct.COMMENTS=movie_link ELSE ev_struct.COMMENTS=ev_struct.COMMENTS+' '+movie_link
;	ENDIF
;	delvarx,cube
;	LABELMOVIE:
;ENDIF
;===============================================================================================================================================
;MOVIE: EIT
IF ((MOVIE NE 0) AND (DO_IMG NE 0)) THEN BEGIN
	DPjobnbr=DPjobnbr+1		
	IF NOT KEYWORD_SET(BREAKONDPERROR) THEN BEGIN CATCH,es & IF es NE 0 THEN BEGIN es=0 & CATCH,/CANCEL & HELP,/Last_message,output=tmptmp & PRINT,tmptmp & GOTO,LABELMOVIE2 & ENDIF & ENDIF

	outmpegdir='/global/hercules/users/hedc/public_html/movies/'+psh_time2dir(flare_time_interval[0])
	IF NOT FILE_TEST(outmpegdir,/DIR) THEN FILE_MKDIR,outmpegdir
	cube=psh_movie({type: 'EIT195', time_intv: anytim(flare_time_interval,/ECS)}, {file: newdatadir+'HEDC_DP_pten_'+eventcode+'.fits' , eband_ss:[1,3]},dir=newdatadir,mpeg=outmpegdir+eventcode+'_EIT.mpg')
	;could use ImSpec stuff instead... just need to replace 'pten' by 'imsp' and change eband_ss...

	DPjobdone=DPjobdone+1
	movie_link='<A HREF="http://www.hedc.ethz.ch/www/movies/'+psh_time2dir(flare_time_interval[0])+eventcode+'_EIT.mpg">EIT-RHESSI movie</A>'
	IF N_ELEMENTS(cube) GT 1 THEN BEGIN
		IF ev_struct.COMMENTS EQ '-9999' THEN ev_struct.COMMENTS=movie_link ELSE ev_struct.COMMENTS=ev_struct.COMMENTS+' '+movie_link
	ENDIF
	delvarx,cube
	LABELMOVIE2:
ENDIF
;===============================================================================================================================================
;===============================================================================================================================================
; Finished defining event, can save the .einfo file:
	;=====================================================================
	write_hedc_event,ev_struct,newdatadir+'HEDC_EVENT_'+eventcode+'.einfo'
		;nbrsources done afterwards. If OK, overwrites this file...
	;=====================================================================
;===============================================================================================================================================
IF KEYWORD_SET(ZBUFFER) THEN BEGIN
        DEVICE,/CLOSE
        SET_PLOT,old_device
ENDIF
;===============================================================================================================================================
IF KEYWORD_SET(REMOVE_FROM_HEDC) THEN BEGIN
	IF NOT KEYWORD_SET(BREAKONDPERROR) THEN BEGIN CATCH,es & IF es NE 0 THEN BEGIN es=0 & CATCH,/CANCEL & HELP,/Last_message,output=tmptmp & PRINT,tmptmp & GOTO,LABEL_REPLACE & ENDIF & ENDIF
	PRINT,'...........Spawning hedc_hsi_delete_HLEcode '+eventcode+' ...............'
	;CD, GETENV('HEC_ROOT')+'/util', CURRENT=old_dir
	;SPAWN,'java hedc_hsi_delete_HLEcode '+eventcode
	SPAWN,'rsh hercules "setenv CLASSPATH '+GETENV('CLASSPATH')+' ; cd HEDC/util ; hedc_hsi_delete_HLEcode '+eventcode+'"'
	LABEL_REPLACE:
	;CD,old_dir
ENDIF
;===============================================================================================================================================
IF DELETE_BIG_FITSFILES THEN BEGIN
	;FILE_DELETE,/QUIET,newdatadir+'HEDC_DP_pten_'+eventcode+'.fits'
	;SPAWN,'echo blabla > '+newdatadir+'HEDC_DP_pten_'+eventcode+'.fits'
	IF FILE_EXIST(newdatadir+'HEDC_DP_pten_'+eventcode+'.fits') THEN SPAWN,'echo blabla > '+newdatadir+'HEDC_DP_pten_'+eventcode+'.fits'
	;FILE_DELETE,/QUIET,newdatadir+'HEDC_DP_imsp_'+eventcode+'.fits'
	;SPAWN,'echo blabla > '+newdatadir+'HEDC_DP_imsp_'+eventcode+'.fits'
	IF FILE_EXIST(newdatadir+'HEDC_DP_imsp_'+eventcode+'.fits') THEN SPAWN,'echo blabla > '+newdatadir+'HEDC_DP_imsp_'+eventcode+'.fits'
ENDIF
;===============================================================================================================================================
	totdur=systime(/SEC)-startsystime	
	PRINT,'.............................. hedc_solar_event.pro completed!!!!!!!!!'
	PRINT,'........ DPs successfully completed: '+STRN(DPjobdone)+' out of '+STRN(DPjobnbr)+' ('+STRN(100*FLOAT(DPjobdone)/DPjobnbr)+'%)'
	PRINT,'.................... in '+STRN(totdur)+' seconds..............................................'
END	; at last !!!
;===============================================================================================================================================
;===============================================================================================================================================
;===============================================================================================================================================
;===============================================================================================================================================
;===============================================================================================================================================
;===============================================================================================================================================


