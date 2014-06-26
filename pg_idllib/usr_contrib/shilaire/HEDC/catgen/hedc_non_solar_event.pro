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
	s20_hle_reserve2	: a.RESERVE2,						$
	s20_hle_reserve3	: a.RESERVE3,						$
	s20_hle_reserve4	: a.RESERVE4,						$
	i10_hle_reserve1	: a.FLARELISTNBR,					$
	i10_hle_reserve2	: a.RESERVE6,						$
	f10_hle_reserve1	: a.RESERVE7,						$
	f10_hle_reserve2	: a.RESERVE8,						$
	txt_hle_comments	: a.COMMENTS	}
		
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

a={HEDC_EVENT_STRUCT_2, Structure_version: 1,				$
			EVENT_CREATOR: 'HEDC',				$
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
			DURATION: 	-9999.D,				$
			
			PEAK_DATETIME_12_25:'-9999',		$
			PEAK_TIMEOFDAY_12_25:-9999.D,		$
			PEAK_COUNTRATE_12_25:-9999.D,		$
			TOTAL_COUNTS_12_25:-9999L,			$			

			PEAK_RATIO	:-9999.,				$
			MULTIPLICITY	:-9999,				$
			ACTIVE_REGION	:-9999,				$
			
			PEAK_DATETIME_3_12: '-9999',		$
			PEAK_TIMEOFDAY_3_12:-9999.D,		$
			PEAK_COUNTRATE_3_12:-9999.D,		$
			TOTAL_COUNTS_3_12:-9999L,			$
			
			PEAK_DATETIME_25_100	:'-9999',	$
			PEAK_TIMEOFDAY_25_100	:-9999.D,	$
			PEAK_COUNTRATE_25_100	:-9999.D,	$
			TOTAL_COUNTS_25_100	:-9999L,	$	
			
			SIMULATED	:-9999,					$
			SAA_FLAG	:-9999,					$
			ECLIPSE_FLAG	:-9999,				$
			
			BCKGND_RATE_12_25:-9999.D,			$
			
			RESERVE1	:'9',					$	
			RESERVE2	:'-9999',				$			
			RESERVE3	:'-9999',				$
			RESERVE4	:'-9999',				$
			
			FLARELISTNBR	:-9999,					$
			RESERVE6	:-9999,					$			
			
			RESERVE7	:-9999.D,				$
			RESERVE8	:-9999.D,				$
			
			RELATED_FILES : '',					$
			
			CREATION_DATE	:'-9999',			$
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
PRO hedc_non_solar_event,obs_time_interval,			$
	;ENV keywords:
	newdatadir=newdatadir,					$
	ZBUFFER=ZBUFFER,					$
	pictype=pictype,					$
	charsize=charsize,					$	
	BREAKONDPERROR=BREAKONDPERROR,				$
	NOFLAGCHECK=NOFLAGCHECK,				$	; IF set, will NOT check for SAA and NIGHT flags.
	NOCHECKFILES=NOCHECKFILES,				$	; if set, will not check whether the fits files for the whole interval are present, according to hsi_filedb.fits ...
	REMOVE_FROM_HEDC=REMOVE_FROM_HEDC,			$	; if set, will erase all HLEs on HEDC with similar eventcode
	
	;info keywords:
	eventtype=eventtype,					$
	eventidnbr=eventidnbr,					$	
	creator=creator	,					$

	;the following keywords, if not set, will imply processing:
	backgndtime=backgndtime,				$	;FOR COUNTS and SPEX (not yet implemented), CAN be outside obs_time_interval
	NOFLARELISTSEARCH=NOFLARELISTSEARCH,			$
	peaktim=peaktim,					$

	;'to do' keywords
	SPECTRA=SPECTRA,					$
	OS_PAGE=OS_PAGE,					$
	HSPG=HSPG,						$
	PHOENIX=PHOENIX,					$
	HP_SPG=HP_SPG,						$
	
	STD=STD
;================================================================	

	startsystime=SYSTIME(/SEC)
	
	;Some parameters...
	DPjobNbr=0
	DPjobDone=0
	imgnbr=-1
	es=0	;Error_Status
	
	IF NOT KEYWORD_SET(OS_PAGE) THEN OS_PAGE=0
	IF NOT KEYWORD_SET(SPECTRA) THEN SPECTRA=0
	IF NOT KEYWORD_SET(HSPG) THEN HSPG=0
	IF NOT KEYWORD_SET(PHOENIX) THEN PHOENIX=0
	IF NOT KEYWORD_SET(HP_SPG) THEN HP_SPG=0	
	IF KEYWORD_SET(STD) THEN BEGIN
		OS_PAGE=1 & ASPECT=0  & SPECTRA=1 & SP_INDEX=1 & HP_SPG=1 & SC_IMG=1 & ROI_CUM=1 & MEM_ROI=1 & HSPG=1  & TRUE_COLOR=1        & nbrsources=-9999
	ENDIF	
					
	CBAR=1
	
	;ENV:
	IF NOT KEYWORD_SET(newdatadir) THEN newdatadir='~/NEWHEDCDATA/'	;'/global/hercules/users/shilaire/NEWHEDCDATA/'	
	t0=anytim(obs_time_interval[0])
	IF KEYWORD_SET(ZBUFFER) THEN BEGIN
		old_device=!D.NAME
		SET_PLOT,'Z',/COPY
	ENDIF
	hedc_win
	!P.MULTI=0
	hessi_ct
	TVLCT,r,g,b,/GET
	IF NOT KEYWORD_SET(pictype) THEN pictype='png'
	IF NOT KEYWORD_SET(charsize) THEN BEGIN
		IF NOT KEYWORD_SET(ZBUFFER) THEN charsize=1.2 ELSE charsize=1.0
	ENDIF

	;info:
	IF NOT KEYWORD_SET(eventtype) THEN eventtype='G'
	IF NOT KEYWORD_SET(eventidnbr) THEN eventidnbr=-9999L	; not used, now (2002/04/26)
	IF NOT KEYWORD_SET(creator) THEN creator='HEDC'

; check whether the HESSI fits files are present or not.
	IF NOT KEYWORD_SET(NOCHECKFILES) THEN BEGIN
		tmp=all_hessi_files_present(obs_time_interval)
		IF tmp LT 1 THEN MESSAGE,'................... Some or all of the HESSI fits files are not there -- aborting............'			
	ENDIF

;//create ev_struct
	hedc_make_event_struct,obs_time_interval,eventtype,eventidnbr,ev_struct,CREATOR=creator,einfodir=newdatadir
	; at this point, we have all that is needed in ev_struct for future hedc_write_info_file.pro, except MIN & MAX energy found... (who cares: only for os01 DPs...)
	;	AND MOST IMPORTANTLY, EVENT_CODE !!!

	;processing:
	IF NOT KEYWORD_SET(backgndtime) THEN backgndtime=anytim(obs_time_interval[0])+[0.,30.]	


;DETERMINE SPIN PERIOD
	spin_period=4.
	IF NOT KEYWORD_SET(BREAKONDPERROR) THEN BEGIN CATCH,es & IF es NE 0 THEN BEGIN es=0 & CATCH,/CANCEL & PRINT,'........PMTRAS_ANALYSIS.pro failed giving the spin period, defaulting to 4.0 seconds.' & GOTO,LABEL_SPIN_PERIOD & ENDIF & ENDIF
		pmtras_analysis,hsi_filedb_filename(peaktim),avperiod=spin_period,PMTRAS_DIAGNOSTIC=0	;,/no_starid	;accuracy can be as bad as 2ms
	LABEL_SPIN_PERIOD:
	PRINT,'----------------------- SPIN PERIOD: '+strn(spin_period)+' s.'


;LIGHTCURVES !!!!
		;must do a lightcurve...and find XXXtim...
		lco=hsi_lightcurve()
		ebands=[3,6,12,25,50,100,300]
		TIMEBIN=spin_period/2.		
		lco->set,ltc_time_res=TIMEBIN,ltc_energy_band=ebands,SEG_INDEX_MASK=[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1]	;,/SP_SEMI_CAL
		
		lco->set,time_range=anytim(backgndtime)
		back_lc=lco->getdata()
	IF N_ELEMENTS(back_lc) EQ 1 THEN RETURN
		PRINT,'.........................RETRIEVING BACKGROUND LIGHTCURVE'
		back_times=lco->getdata(/xaxis)
		PRINT,' Mean of background at 12-25 keV: '+strn(MEAN(back_lc(*,2)))+' counts (timebinning: '+strn(TIMEBIN)+' seconds.)'
		PRINT,' Sigma of background at 12-25 keV: '+strn(STDEV(back_lc(*,2)))

	;average out to get the mean backgnd levels:
		FOR i=0,N_ELEMENTS(ebands)-2 DO BEGIN
			IF NOT EXIST(backgnd_lvl) THEN backgnd_lvl=MEAN(back_lc(*,i)) ELSE backgnd_lvl=[backgnd_lvl,MEAN(back_lc(*,i))]
		ENDFOR
		
		lco->set,time_range=anytim(obs_time_interval)
		PRINT,'.........................RETRIEVING RAW LIGHTCURVE'
		raw_lc=lco->getdata()
	IF N_ELEMENTS(raw_lc) EQ 1 THEN RETURN
		lc_all=raw_lc

;BACKGROUND SUBTRACTION
;	PRINT,'....... SUBTRACTING BACKGROUND LEVELS FROM LIGHTCURVES...'
;		FOR i=0,N_ELEMENTS(ebands)-2 DO lc_all(*,i)=raw_lc(*,i)-backgnd_lvl(i)
		
		lc=lc_all[*,2]
		taxis=lco->getdata(/xaxis)

		maxcounts=max(lc_all[*,3],ss)
		PRINT,'Peak number of counts in our timebin: '+strn(maxcounts)
	IF NOT KEYWORD_SET(peaktim) THEN BEGIN		
		;peaktim = where it is highest in 25-50 range, if not already defined....
		peaktim=taxis(ss[0])
	ENDIF
	
		print,'PEAK TIME is: '+anytim(peaktim,/ECS)
		ev_struct.PEAK_DATETIME_12_25=anytim(peaktim,/ECS)
		ev_struct.PEAK_TIMEOFDAY_12_25=anytim(peaktim,/time_only)


;//define eventcode : need peaktim
	tmp=anytim(peaktim,/ex)
	eventcode='HX'+eventtype+int2str(tmp(6)-2000,1)+int2str(tmp(5),2)+int2str(tmp(4),2)+int2str(tmp(0),2)+int2str(tmp(1),2)
	ev_struct.EVENT_CODE=eventcode

	;peak rates
		ev_struct.PEAK_COUNTRATE_12_25=lc(ss(0))/TIMEBIN
		ev_struct.PEAK_RATIO=lc_all(ss(0),3)/lc_all(ss(0),2)	; 25-50/12-25

		ev_struct.START_DATETIME=anytim(anytim(peaktim)-1.,/ECS)
		ev_struct.START_TIMEOFDAY=anytim(anytim(peaktim)-1.,/time_only)
		ev_struct.END_DATETIME=anytim(anytim(peaktim)+1.,/ECS)
		ev_struct.END_TIMEOFDAY=anytim(anytim(peaktim)+1.,/time_only)

		info=lco->get()
		hedc_win,768,512
		myct3
		TVLCT,r,g,b,/GET
	;PLOT & SAVE linear lightcurve:
		DPjobnbr=DPjobnbr+1		
		IF NOT KEYWORD_SET(BREAKONDPERROR) THEN BEGIN CATCH,es & IF es NE 0 THEN BEGIN es=0 & CATCH,/CANCEL & GOTO,LABEL01 & ENDIF & ENDIF
		rootfil=newdatadir+'HEDC_DP_lc00_'+eventcode
		draw_hsi_lc,lco,title='Non-calibrated HESSI counts, all segments',ebands=[3,25,50,100,300,1000,20000]
		TVLCT,r,g,b,/GET
		;lco->plot,charsize=charsize,title='Non-calibrated HESSI counts'
		;DISPLAY BACKGROUND interval:
			tmp=REPLICATE(0.18*(!Y.CRANGE(1)-!Y.CRANGE(0))+!Y.CRANGE(0),N_ELEMENTS(back_times))
			oplot,back_times-t0,tmp,thick=3,color=250
			XYOUTS,/DATA,back_times(0)-t0,0.2*(!Y.CRANGE(1)-!Y.CRANGE(0))+!Y.CRANGE(0),'BACKGROUND',color=250
		CALL_PROCEDURE,'write_'+pictype,rootfil+'.'+pictype,TVRD(),r,g,b
		IF FILE_EXIST(rootfil+'.'+pictype) THEN hedc_write_info_file,'lc',ev_struct,info,rootfil+'.info'
		DPjobdone=DPjobdone+1
		LABEL01:

		obj_destroy,lco		
		
;FULL SUN IMAGE (for now: do it always, whatever the status of the xyoffset keyword...)
imgnbr=imgnbr+1
		DPjobnbr=DPjobnbr+1		
		IF NOT KEYWORD_SET(BREAKONDPERROR) THEN BEGIN CATCH,es & IF es NE 0 THEN BEGIN es=0 & CATCH,/CANCEL & PRINT,'.......Full Sun image failed....' & GOTO,LABEL03 & ENDIF & ENDIF
			imgdim=128
			pixsiz=32
		
		hessi_ct
		TVLCT,r,g,b,/GET
				
		imo=hsi_image()		
		;imo->set,obs_time_interval=anytim(obs_time_interval)
		imo->set,time_range=anytim(peaktim)+spin_period*[-0.5,0.5]
		imo->set,image_dim=imgdim,pixel_size=pixsiz,det_index_mask=[0,0,0,0,0,0,1,1,1],image_alg='back'
		imo->set,xyoffset=[0,0],energy_band=[25,300],rear=0
		imo->set_no_screen_output
		hedc_win
		PRINT,'.........................FULL SUN image'
		IF CBAR EQ 1 THEN imo->plot,/limb,charsize=charsize,/CBAR  ELSE imo->plot,margin=0.07,/limb,charsize=charsize
		
		rootfilename=newdatadir+'HEDC_DP_im00_'+eventcode
		CALL_PROCEDURE,'write_'+pictype,rootfilename+'.'+pictype,TVRD(),r,g,b
		info=imo->get()
		IF FILE_EXIST(rootfilename+'.'+pictype) THEN hedc_write_info_file,'im',ev_struct,info,rootfilename+'.info'
		imo->fitswrite,fitsfile=rootfilename+'.fits',/CREATE
		DPjobdone=DPjobdone+1		
		LABEL03:
						
;HESSI FLARE LIST NUMBER :
	IF NOT KEYWORD_SET(NOFLARELISTSEARCH) THEN BEGIN
		PRINT,'HESSI FLARE LIST NUMBER.......................'
		flo = obj_new('hsi_flare_list')
		flo ->set,obs_time_interval = [ev_struct.START_DATETIME,ev_struct.END_DATETIME]
		bla = flo->getdata()
		if datatype(bla) eq 'STC' then ev_struct.FLARELISTNBR = bla(0).ID_NUMBER
		obj_destroy,flo
		delvarx,flo
	ENDIF


;SAA & NIGHT FLAGS
	IF NOT KEYWORD_SET(NOFLAGCHECK) THEN BEGIN
		es=0
		IF NOT KEYWORD_SET(BREAKONDPERROR) THEN BEGIN CATCH,es & IF es NE 0 THEN BEGIN es=0 & CATCH,/CANCEL & GOTO,LABEL16 & ENDIF & ENDIF		
		oso=hsi_obs_summary()
		oso->set,obs_time_interval=obs_time_interval
		flagdata_struct=oso->getdata(class_name='obs_summ_flag')
		flagdata=flagdata_struct.FLAGS
		ss=WHERE(flagdata(0,*) NE 0)
		IF ss(0) NE -1 THEN ev_struct.SAA_FLAG=1 ELSE ev_struct.SAA_FLAG=0
		ss=WHERE(flagdata(1,ss_beg:ss_end) NE 0)
		IF ss(0) NE -1 THEN ev_struct.ECLIPSE_FLAG=1 ELSE ev_struct.ECLIPSE_FLAG=0
		LABEL16:
		OBJ_DESTROY,oso
	ENDIF




; Finished defining event, can save the .einfo file:
	;=====================================================================
	write_hedc_event,ev_struct,newdatadir+'HEDC_EVENT_'+eventcode+'.einfo'
	;=====================================================================
;===============================================================================================================================================
;OBS.SUMM. STUFF
IF OS_PAGE NE 0 THEN BEGIN
	DPjobnbr=DPjobnbr+1		
	IF NOT KEYWORD_SET(BREAKONDPERROR) THEN BEGIN CATCH,es & IF es NE 0 THEN BEGIN es=0 & CATCH,/CANCEL & GOTO,LABEL11 & ENDIF & ENDIF
	rootfilename=newdatadir+'HEDC_DP_os04_'+eventcode
	PRINT,'.........................OBS. SUMM. PAGE'
	obs_summ_page,obs_time_interval,filename=rootfilename+'.'+pictype
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
	hessi_ct
ENDIF
;===============================================================================================================================================
; HESSI SPECTROGRAM
IF HSPG NE 0 THEN BEGIN
	DPjobnbr=DPjobnbr+1		
	IF NOT KEYWORD_SET(BREAKONDPERROR) THEN BEGIN CATCH,es & IF es NE 0 THEN BEGIN es=0 & CATCH,/CANCEL & GOTO,LABEL12 & ENDIF & ENDIF
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
	DPjobnbr=DPjobnbr+1		
	IF NOT KEYWORD_SET(BREAKONDPERROR) THEN BEGIN CATCH,es & IF es NE 0 THEN BEGIN es=0 & CATCH,/CANCEL & GOTO,LABEL20 & ENDIF & ENDIF
	hedc_win,768,512
	PRINT,'.........................PHOENIX AND HESSI SPECTROGRAM'
	LOADCT,5
	rapp_cmb_spg, obs_time_interval
	rootfilename=newdatadir+'HEDC_DP_spg1_'+eventcode
	TVLCT,r,g,b,/GET
	CALL_PROCEDURE,'write_'+pictype,rootfilename+'.'+pictype,TVRD(),r,g,b
	IF FILE_EXIST(rootfilename+'.'+pictype) THEN hedc_write_info_file,'hps',ev_struct,obs_time_interval,rootfilename+'.info'
	DPjobdone=DPjobdone+1
	LABEL20:
ENDIF
;===============================================================================================================================================
OBJ_DESTROY,imo
delvarx,imo
HEAP_GC
;===============================================================================================================================================
;SPECTRA
IF SPECTRA NE 0 THEN BEGIN 
	hedc_win,768,512
	myct3,ct=1
	TVLCT,r,g,b,/GET
	spo=hsi_spectrum()
	seg_index_mask=[1,0,1,1,1,1,0,1,1,1,0,1,1,1,1,0,1,1]
	spo->set,obs_time_interval=obs_time_interval,seg_index_mask=seg_index_mask,sp_energy_bin=5,/sp_semi_cal
	title='HESSI flux vs. energy, semi-calibrated, WITH background'
	
;peaktim:
	DPjobnbr=DPjobnbr+1
	IF NOT KEYWORD_SET(BREAKONDPERROR) THEN BEGIN CATCH,es & IF es NE 0 THEN BEGIN es=0 & CATCH,/CANCEL & GOTO,LABEL07 & ENDIF & ENDIF	
	spo->set,time_range=anytim(peaktim)-t0+spin_period*[-0.5,0.5]
	PRINT,'.........................SPECTRUM : peaktime'
	spo->plot,charsize=charsize,title=title
	rootfilename=newdatadir+'HEDC_DP_sp01_'+eventcode
	CALL_PROCEDURE,'write_'+pictype,rootfilename+'.'+pictype,TVRD(),r,g,b
	info=spo->get()
	IF FILE_EXIST(rootfilename+'.'+pictype) THEN hedc_write_info_file,'sp',ev_struct,info,rootfilename+'.info'
	peak_sp=spo->getdata()
	DPjobdone=DPjobdone+1
	LABEL07:	
OBJ_DESTROY,spo
ENDIF
;===============================================================================================================================================
;===============================================================================================================================================
IF KEYWORD_SET(ZBUFFER) THEN BEGIN
        DEVICE,/CLOSE
        SET_PLOT,old_device
ENDIF
;===============================================================================================================================================
IF KEYWORD_SET(REMOVE_FROM_HEDC) THEN BEGIN
	IF NOT KEYWORD_SET(BREAKONDPERROR) THEN BEGIN CATCH,es & IF es NE 0 THEN BEGIN es=0 & CATCH,/CANCEL & GOTO,LABEL_REPLACE & ENDIF & ENDIF
	CD, GETENV('HEC_ROOT')+'/util', CURRENT=old_dir
	PRINT,'...........Spawning hedc_hsi_delete_HLEcode '+eventcode+' ...............'
	SPAWN,'hedc_hsi_delete_HLEcode '+eventcode
	LABEL_REPLACE:
	CD,old_dir
ENDIF
;===============================================================================================================================================
	totdur=systime(/SEC)-startsystime	
	PRINT,'.............................. hedc_non_solar_event.pro completed!!!!!!!!!'
	PRINT,'........ DPs successfully completed: '+STRN(DPjobdone)+' out of '+STRN(DPjobnbr)+' ('+STRN(100*FLOAT(DPjobdone)/DPjobnbr)+'%)'
	PRINT,'.................... in '+STRN(totdur)+' seconds..............................................'
END	; at last !!!
;===============================================================================================================================================
;===============================================================================================================================================
;===============================================================================================================================================
;===============================================================================================================================================
;===============================================================================================================================================
;===============================================================================================================================================



