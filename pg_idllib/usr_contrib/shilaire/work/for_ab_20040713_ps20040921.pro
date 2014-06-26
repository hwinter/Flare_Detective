;.run for_ab_20040713_ps20040921


;******************************************************************************
PRO my_backsub, image, xaxis, AbsoluteAnyStartTime, BACKGROUNDTIME, backavg=backavg, automatic=automatic
 IF NOT exist(automatic) THEN automatic=0.
 
 print, "Background subtraction"
 ;image = constbacksub_V21(image, 0, n_elements(image(*,0))-1,'X', /AUTO )
 ;image = constbacksub_V21(image, 0,299,'X')	; first 30 secs of constant backgnd, assuming 0.1 sec per time bin

IF automatic EQ 0. THEN BEGIN
	ss_endbckgnd=WHERE(xaxis GT (AbsoluteAnyStartTime+BACKGROUNDTIME))
	ss_endbckgnd=ss_endbckgnd(0)
	image = constbacksub_V21(image, 0,ss_endbckgnd ,'X', background=background)
		; backavg is the average of the background that was subtracted from 'image'. 
		; For background subtraction done on a log image, it is a measure of the basic
		; quantity  one must add to 'image' before linearization, in order to have
		; real physical units (i.e. SFUs).
		; I can think of a couple really better ways to obtain the min/max values (in SFUs),
		; but they are both time (my own)-consuming and computer-intensive. Maybe later ?
ENDIF ELSE BEGIN
	image = constbacksub_V21(image, 0, n_elements(image(*,0))-1,'X', automatic=automatic, background=background )
ENDELSE
backavg = avg(background,0)
END
;******************************************************************************
PRO qv_elimwrong, image, xaxis, yaxis 
 print, "Eliminating wrong channels"
 image_old = image
 xaxis_old = xaxis
 yaxis_old = yaxis
 ElimWrongChannels, image, xaxis, yaxis
 if n_elements(image(0,*)) le 1 then begin 
    print, "Restoring original image"
    image = image_old
    xaxis = xaxis_old
    yaxis = yaxis_old
 endif
END

;******************************************************************************
PRO write_add_info,STOKES=STOKES,DATE=DATE,datalimits=datalimits

CharSize=1.0

XYOUTS,/dev,580,493,'ETH Zurich',CHARSIZE=CharSize
XYOUTS,/dev,580,478,'Switzerland',CHARSIZE=CharSize
XYOUTS,/dev,580,463,'Phoenix-2 spectrometer',CHARSIZE=CharSize

XYOUTS,/dev,740,2,'UT'
XYOUTS,/dev,10,195,'Frequency [MHz]',ORIENTATION=90

IF exist(DATE) THEN XYOUTS,/dev,60,490,DATE,CHARSIZE=CharSize*1.5
IF exist(STOKES) THEN BEGIN
	XYOUTS,/dev,75,460,'STOKES '+STOKES,CHARSIZE=CharSize*1.5
	IF STOKES EQ 'I' THEN BEGIN
		IF not exist(datalimits) THEN BEGIN
			XYOUTS,/dev,220,458,'MIN.',CHARSIZE=CharSize*0.85
			XYOUTS,/dev,520,458,'MAX.',CHARSIZE=CharSize*0.85
		ENDIF ELSE BEGIN
			XYOUTS,/dev,330,458,'SFUs (log scale)',CHARSIZE=CharSize*0.85
			temp=datalimits		;conversion already done	;10^(datalimits/45.) -10.	; convert to SFUs
			XYOUTS,/dev,220,458,STRN(temp(0),format='(f7.1)'),CHARSIZE=CharSize*0.85
			XYOUTS,/dev,520,458,STRN(temp(1),format='(f9.1)'),CHARSIZE=CharSize*0.85
		ENDELSE
	ENDIF
	IF STOKES EQ 'V' THEN BEGIN
		IF not exist(datalimits) THEN BEGIN
			XYOUTS,/dev,220,458,'LEFT',CHARSIZE=CharSize*0.85
			XYOUTS,/dev,520,458,'RIGHT',CHARSIZE=CharSize*0.85
		ENDIF ELSE BEGIN
			XYOUTS,/dev,290,458,'% POLARIZATION (NEGATIVE = LEFT)',CHARSIZE=CharSize*0.85
			XYOUTS,/dev,220,458,STRN(datalimits(0),format='(f7.1)'),CHARSIZE=CharSize*0.85
			XYOUTS,/dev,520,458,STRN(datalimits(1),format='(f7.1)'),CHARSIZE=CharSize*0.85
		ENDELSE


	ENDIF	
ENDIF

END
;******************************************************************************
;******************************************************************************
FUNCTION rag_extract_from_list,file,beforetime=beforetime, aftertime=aftertime
	;some initialization
	list=-1
	ligne='abc'
	if not exist(beforetime) then beforetime=30.	; time added before burst interval, in seconds
	if not exist(aftertime) then aftertime=30.		; time added after burst interval, in seconds
	beforetime=FLOAT(beforetime)
	aftertime=FLOAT(aftertime)
			
	IF not file_exist(file) then print,'!!!!!!!!! NEW BURSTS FILE LIST WAS NOT FOUND : '+file+' !!!!!!!!!!!!!!' ELSE begin
		OPENR,lun1,file,/GET_LUN
		readf,lun1,ligne
		IF ligne EQ 'There are new bursts to image:' then begin		
			WHILE eof(lun1) EQ 0 do begin
				readf,lun1,ligne
				bla=RSI_STRSPLIT(ligne,/EXTRACT)
				IF n_elements(bla) GT 1 then begin	;happens I don't have a burst for the whole day...
			    	temp=STRMID(bla(0),0,2) & temp=FIX(temp)
					IF temp GE 98 THEN year=STRN(1900+temp) ELSE year=STRN(2000+temp)	; OK, this is valid only until 2097...
					temp=STRMID(bla(0),2,2) & temp=FIX(temp)
					month=STRN(temp)
					temp=STRMID(bla(0),4,2) & temp=FIX(temp)
					day=STRN(temp)
					starttime=3600.*DOUBLE(STRMID(bla(1),0,2))+60.*DOUBLE(STRMID(bla(1),2))
					endtime=3600.*DOUBLE(STRMID(bla(2),0,2))+60.*DOUBLE(STRMID(bla(2),2))
					
					newitem = year+'/'+month+'/'+day+' '+ms2hms([starttime, endtime]*1000.)
					newitem = ANYTIM(newitem)
					newitem = newitem+[-beforetime,aftertime]
					newitem = ANYTIM(newitem,/ECS)
					if datatype(list) EQ 'INT' then list=newitem else list=[list,newitem]
				ENDIF
			ENDWHILE
		ENDIF
		CLOSE,lun1,/FORCE
	ENDELSE
	return,list	; in ANYTIM format...
END



;***********************************************************************************************************************************
;***********************************************************************************************************************************
;***********************************  MAIN  ****************************************************************************************
;***********************************************************************************************************************************
;***********************************************************************************************************************************
;-----------------------------------------------------------------------------------------------------------------------------------
;first, some important constants:

TODO=1			; set to 0 to do both Stokes I and V
				; set to 1 to do ONLY Stokes I
				; set to 2 to do ONLY Stokes V
				; usually set to 0

LOGBACKSUB=0	; set to 0 for backgnd subtraction on linear image (most realistic one)
				; set to 1 for backgnd subtraction on log image
				;	(this of course only concerns STOKES I images)
				; usually set to 0
					
INVERT=1		; set this to 0 to constbacksub, THEN elimwrongchannels
				; set this to 1 to elimwrongchannels, THEN constbacksub
				; usually set to 1
					
BEFORETIME =	60.	; seconds before burst time, from where background is starting to be accumulated	
					; usually 60.
BACKGROUNDTIME= 30.	; seconds to be considered as background, starting at bursttime-BEFORETIME , cannot be greater than BEFORETIME	
					; usually 30.
ADDIMAGETIME =  30.	; seconds before & after burst to image and display, cannot be greater than BEFORETIME	
					; usually 30.

CENTERPOL = 1		; set to 0 to display polarization data as is.
					; set to 1 to center polarization image around zero, with range = +/- max(abs(image))	[with a bit of cheating!]
					; set to 2 to center polarization image around zero, with range = +/- 100%	[with a bit of cheating!]
					; usually set to 1

AUTO=0.			; set to 0. to disable
				; set to any non-zero number between 0. and 1.0 to use automatic background subtraction, and which percentage of image to take
				; relevant only for Stokes I images
				; usually set to 0. (or 0.02, if used)
				; set usually for old bursts, where limited data is available, i.e. background cannot easily be taken outside 
				;	burst time interval, and then BEFORETIME is set to 0. 


MAXTIMEINTV=10.*3600.	; bursts longer than this will not be imaged.
						; usually set to 6.*3600..


OPTIMIZATION = 1; usually set to 1
				; will put min of Stokes I data to -9 SFUs, and every value above 80% of max value to 80% of max value
				; use it only when LOGBACKSUB is set to zero !!!


BREAKONERROR = 0; usually set to 0
				; if set to 1, will break wheneever a problem occurs
				; if set to 0, will ignore the current burst which causes a problem,
				; and go on with the next one (useful for (re-)doing large quantities of bursts),
				; and should only be used in that case (no emails are sent if problems occur,
				; as no breaks where generated)

INDIVNOTIFY	= 1	; set to 0 to disable
				; usually set to 1
				; if set to 1, will send me an email for EACH individual defective bursts
				; setting INDIVNOTIFY only has sense if BREAKONERROR was set to 0,
				;	since otherwise I would also get the error warning by email.
				;		(EXCEPT in the case of missing files....)
				;  The advantage of using BREAKONERROR = 0 and INDIVNOTIFY	= 1 compared
				;  to simply using BREAKONERROR = 1 is that all do-able bursts are made,
				;  even if there were bad bursts (that would break the system) in between.


CHECKFIRSTLINES=2	;set to 0 to disable
					;normally set to 2
					;set to a number N so that the N first frequencies are checked: if the jump between them and the
					;preceding frequencies is too big, remove them, so that frequency scale for display remains OK.


;(see also 'rag_root' in the 'return_rag_files' routine)

!QUIET=1
;-----------------------------------------------------------------------------------------------------------------------------------
; now, let's rock'n'roll !
;***********************************************************************************************************************************

BEFORETIME=FLOAT(BEFORETIME)
BACKGROUNDTIME=FLOAT(BACKGROUNDTIME)
ADDIMAGETIME=FLOAT(ADDIMAGETIME)

; some checks:
BACKGROUNDTIME = BACKGROUNDTIME < BEFORETIME
ADDIMAGETIME = ADDIMAGETIME < BEFORETIME
IF BREAKONERROR EQ 1 THEN INDIVNOTIFY=0


nbursts=1
	;time_interval='2003/10/28 '+['10:10','15:15']
	time_interval='2003/10/28 '+['09:00','15:30']
	print,'............... Doing burst : ',time_interval
	
	IF ((TODO NE 2) AND ( (anytim(time_interval[1])-anytim(time_interval[0])) LE MAXTIMEINTV) ) THEN BEGIN
		;do l1 and i files (Linear polarization or STOKES I) ---------------------------------------------------------------------------------------
		image=rapp_get_spectrogram(time_interval,xaxis=xaxis,yaxis=yaxis)
		loadct,5
		
		IF DATATYPE(image) EQ 'STR' THEN BEGIN
			PRINT,'......................Problem with intensity (Stokes I or l1 or l2) rag fits files for this burst!'
			IF INDIVNOTIFY EQ 1 THEN BEGIN
				text='Problem with intensity, i.e. Stokes I or l1 or l2, rag fits files for burst : '+anytim(time_interval(0),/ECS)
				;cmd='echo '+text+' |mailx -s "Ragburst problem" shilaire'
				;spawn,cmd
				MESSAGE,text	
			ENDIF
		ENDIF $
		ELSE begin
			PRINT,'.............................DOING STOKES I or LINEAR 1.'
	
;at this point, image is always an image in LINEAR SFU SCALE !!!
		;remove some bad pixels:  PSH 2002/06/25
			image=remove_bad_pixels(image)

			;remove first N lines if frequencies are not OK.
			IF CHECKFIRSTLINES NE 0 THEN BEGIN
				acceptable_freq_interval = 5.*(yaxis(CHECKFIRSTLINES+1)-yaxis(CHECKFIRSTLINES))
				FOR k=0,CHECKFIRSTLINES-1 DO BEGIN
					IF ((yaxis(0)-yaxis(1)) GT acceptable_freq_interval) THEN BEGIN
						print,'Removing frequency channel : '+STRN(yaxis(0))
						oldny=N_ELEMENTS(yaxis)
						yaxis=yaxis(1:oldny-1)
						image=image(*,1:oldny-1)
					ENDIF
				ENDFOR
			ENDIF

			print,'Raw linear image (SFUs), from BurstStart-BEFORETIME to BurstEnd+ADDIMAGETIME:'
			print,'MIN: '+STRING(min(image))
			print,'MAX: '+STRING(max(image))
								
			IF LOGBACKSUB EQ 1 THEN image = 45.*ALOG10(TEMPORARY(image)+10.) 
		
			ERASE

			IF INVERT EQ 0 THEN BEGIN
				my_backsub, image, xaxis, anytim(time_interval(0),/TIME_ONLY), BACKGROUNDTIME, backavg=backavg, automatic=AUTO
				qv_elimwrong, image, xaxis, yaxis
			ENDIF ELSE BEGIN
				qv_elimwrong, image, xaxis, yaxis
				my_backsub, image, xaxis, anytim(time_interval(0),/TIME_ONLY), BACKGROUNDTIME, backavg=backavg, automatic=AUTO
			ENDELSE
					
			;take the parts starting and ending at correct times from burststart-ADDIMAGETIME to burstend+ADDIMAGETIME
			ss_start=WHERE(xaxis GT (anytim(time_interval(0)+BEFORETIME-ADDIMAGETIME,/time_only)))
			ss_start=ss_start(0)
			image=image(ss_start:n_elements(xaxis)-1,*)
			xaxis=xaxis(ss_start:n_elements(xaxis)-1)
	
			datamin = min(image, max=datamax)	; in linear scale if LOGBACKSUB=0, log scale if LOGBACKSUB=1
			print,'After background subtraction, bad channels removal and taking only relevant part of image (near burst +/- ADDIMAGETIME):'			
			IF LOGBACKSUB EQ 0 THEN PRINT,'(SFUs):'
			print,'MIN: '+STRING(datamin)
			print,'MAX: '+STRING(datamax)		
			print,'(The average background was calculated to be : '+STRN(backavg)+')'
	
			IF LOGBACKSUB EQ 0 THEN BEGIN
					IF OPTIMIZATION EQ 1 THEN BEGIN
						; min is set to -9 SFUs, and top to 80% of max.
						topval=0.8*max(image)
						FOR j=0L,N_ELEMENTS(image(*,0))-1 DO BEGIN
							FOR k=0L,N_ELEMENTS(image(0,*))-1 DO BEGIN
								IF image(j,k) LT -9.0 THEN image(j,k)=-9.0
								IF image(j,k) GT topval THEN image(j,k)=topval						
							ENDFOR
						ENDFOR
						datamin = min(image, max=datamax)
						print,'.......................SOME OPTIMIZATION: '
						print,'MIN: '+STRING(datamin)
						print,'MAX: '+STRING(datamax)
					ENDIF
					
					image=alog(TEMPORARY(image)-datamin+1.)	;for display purposes, I'd rather have a log scale...
					
			ENDIF ELSE BEGIN
				datamin = 10^((datamin+backavg)/45.) - 10.
				datamax = 10^((datamax+backavg)/45.) - 10.
				print,' Those values translate roughly to (in SFUs):'
				print,'MIN: '+STRING(datamin)
				print,'MAX: '+STRING(datamax)
			ENDELSE
;---------------------------------------------------------------------------------------------------------------------------------------
			SET_PLOT,'ps'
			!P.MULTI=[0,1,2]
		;Phoenix-2 spg	
			;rapp_spectro_plot,image,anytim(time_interval[0],/date)+xaxis,yaxis,xstyle=1,tit='Phoenix-2 - STOKES I - Data min/max: '+strn(datamin,format='(f10.1)')+'/'+strn(datamax,format='(f10.1)')+' SFU',ytit='Frequency [MHz]',xtit=' ',ymar=[1,2],xmar=[8,1]
			spectro_plot,image,anytim(time_interval[0],/date)+xaxis,yaxis,xstyle=1,tit='Phoenix-2 - STOKES I - Data min/max: '+strn(datamin,format='(f10.1)')+'/'+strn(datamax,format='(f10.1)')+' SFU',ytit='Frequency [MHz]',xtit=' ',ymar=[1,2],xmar=[8,1],XTICKNAME=REPLICATE(' ',10)
		;GOES lightcurves
			!P.MULTI=[2,1,4]
			pg_plotgoes,time_interval,/ylog,int=5,yticklen=1,yminor=1,color=120,yrange=[1e-7,1e-2],xstyle=1,xtitle='',thick=2,/outinfoytitle,title='',charsize=2,xmar=[8,1],ymar=[2,0],ytickname=['B1.0','C1.0','M1.0','X1.0','X10','X100'],XTICKNAME=REPLICATE(' ',10)
			pg_plotgoes,time_interval,int=5,color=200,channel=2,/over 
		;RHESSI lightcurves
			ro=OBJ_NEW('hsi_obs_summ_rate')
			ro->set,obs_time_interval=time_interval
			tmp=ro->getdata()
			obstimes=ro->getdata(/xaxis)
			rates=ro->corrected_countrate()
			OBJ_DESTROY,ro
			r1=REFORM(rates[1,*])
			r2=REFORM(rates[2,*])
			r3=TOTAL(rates[3:4,*],1)
;CORRECTING THE RATES...
	;1st peak
	ss=WHERE(obstimes GE anytim('2003/10/28 11:00') AND obstimes LE anytim('2003/10/28 11:30'))
	; need to take uncorrected countrates...
	oso=hsi_obs_summary()
	oso->set,obs_time=time_interval
	urates=oso->getdata()
	OBJ_DESTROY,oso
		r1[ss]=urates[ss].COUNTRATE[1]*15.
		r2[ss]=urates[ss].COUNTRATE[2]*2.5
		r3[ss]=TOTAL(urates[ss].COUNTRATE[3:4],1)

	;2nd peak
	ss=WHERE(obstimes GE anytim('2003/10/28 12:45') AND obstimes LE anytim('2003/10/28 13:10'))
		r1[ss]=r1[ss]*0.3
		r2[ss]=r2[ss]*0.3
		r3[ss]=r3[ss]*0.3
						
			utplot,obstimes-obstimes[0],r1,obstimes[0],color=160,yr=[1d1,1d5],/YLOG,tit='RHESSI corrected countrates',xstyle=1,ytit='[cts/s/det]',charsize=2,xmar=[8,1],ymar=[3,0]
			outplot,obstimes-obstimes[0],r2,color=200
			outplot,obstimes-obstimes[0],r3,color=255
			label_plot, 0.73, -1,'6-12 keV',/LINE,color=160	
			label_plot, 0.73, -2,'12-25 keV',/LINE,color=200	
			label_plot, 0.73, -3,'25-100 keV',/LINE,color=255
;---------------------------------------------------------------------------------------------------------------------------------------
		ENDELSE
	ENDIF
END
