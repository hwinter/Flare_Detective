;list2images : takes a .list with dates, converts them, and makes spectrograms (I & V)
;called by the UNIX batch file 'ragbursts2images'
;
;***************  P. Saint-Hilaire 2004/06/15 created, from list2images_new.pro   ********************************
;			shilaire@astro.phys.ethz.ch
;---------------------------------------------------------------------------------------
;
;MODIFICATIONS:
;	PSH, 2001/11/30	:	added 'CHECKFIRSTLINES'
;
;	PSH, 2001/10/29	:	added 'OPTIMIZATION'
;
;	PSH, 2001/11/01 :	added 'BREAKONERROR' and log of problem bursts
;
;	PSH, 2001/11/05 :	added 'INDIVNOTIFY' option
;
;	PSH, 2002/06/25 :	remove_bad_pixels.pro for both I and V images
;
;	PSH, 2002/09/05 :	MAJOR CHANGES! I hope I didn't goof up...
;
;	PSH, 2003/11/12 :	Suppressed background-subtraction for polarization images... (because not done in proper fashion...)
;
;	PSH, 2004/06/15 :	Renamed to raglist2images.pro from list2images_new.pro: basically adding RHESSI lightcurves...
;
;	PSH, 2004/08/11 :	v2: added RHESSI flags
;	PSH, 2004/08/12 :	v3: removed RHESSI flags, just concentrated on obs. time (i.e. no GAP/SAA/NIGHT ...)
;	PSH, 2004/09/17 :	v4: added Callisto stuff...
;	PSH, 2004/11/24 :	v5: better Callisto images: Better dynamical scaling of color table in case of bad data.
;	PSH, 2005/06/28 :	v6: replaced rapp_spectro_plot with spectro_plot.pro...
;
;---------------------------------------------------------------------------------------

;******************************************************************************
PRO raglist2images_backsub, image, xaxis, AbsoluteAnyStartTime, BACKGROUNDTIME, backavg=backavg, automatic=automatic
 IF NOT exist(automatic) THEN automatic=0.
 
 print, "Background subtraction"
 ;image = constbacksub_V21(image, 0, n_elements(image[*,0])-1,'X', /AUTO )
 ;image = constbacksub_V21(image, 0,299,'X')	; first 30 secs of constant backgnd, assuming 0.1 sec per time bin

IF automatic EQ 0. THEN BEGIN
	ss_endbckgnd=WHERE(xaxis GT (AbsoluteAnyStartTime+BACKGROUNDTIME))
	ss_endbckgnd=ss_endbckgnd[0]
	IF ss_endbckgnd LE 0 THEN BEGIN
		PRINT,'............Missing some data before burst...: use automatic...'
		image = constbacksub_V21(image, 0, n_elements(image[*,0])-1,'X', automatic=0.01, background=background )
	ENDIF ELSE BEGIN
		image = constbacksub_V21(image, 0,ss_endbckgnd ,'X', background=background)
			; backavg is the average of the background that was subtracted from 'image'. 
			; For background subtraction done on a log image, it is a measure of the basic
			; quantity  one must add to 'image' before linearization, in order to have
			; real physical units (i.e. SFUs).
			; I can think of a couple really better ways to obtain the min/max values (in SFUs),
			; but they are both time (my own)-consuming and computer-intensive. Maybe later ?
		ENDELSE
ENDIF ELSE BEGIN
	image = constbacksub_V21(image, 0, n_elements(image[*,0])-1,'X', automatic=automatic, background=background )
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
CD,GETENV('LOG_DIR')	;working there should prevent conflicts with ragfitstmp.fit from other programs...

SET_PLOT, 'Z', /COPY				; Kuddos for the Z-Buffer !!!!
DEVICE, SET_RESOLUTION=[768,768]
ERASE

;the following line is done so that ticks appear in the images (not needed with PS device) - a bug I never figured out in show_image...
plot,[0,1],[2,3]

BEFORETIME=FLOAT(BEFORETIME)
BACKGROUNDTIME=FLOAT(BACKGROUNDTIME)
ADDIMAGETIME=FLOAT(ADDIMAGETIME)

; some checks:
BACKGROUNDTIME = BACKGROUNDTIME < BEFORETIME
ADDIMAGETIME = ADDIMAGETIME < BEFORETIME
IF BREAKONERROR EQ 1 THEN INDIVNOTIFY=0


print,'.......................Extracting bursts time intervals from the list.'
intervallist = rag_extract_from_list(getenv('LOG_DIR')+'/newragbursts.list',beforetime=BEFORETIME,aftertime=ADDIMAGETIME)	;in ANYTIM format...
IF datatype(intervallist) EQ 'INT' then begin
	print,'!!!!!!!!!!!!!! NO NEW BURSTS !!!!!!!!!!!!!!!!!!'
	print,'IDL-OK'
	EXIT,/NO_CONFIRM,STATUS=1
ENDIF
nbursts=N_ELEMENTS(intervallist)/2

print,'.......................Number of new bursts: '+STRING(nbursts)

FOR i=0,nbursts-1 do begin
	Error_Status=0
	IF BREAKONERROR NE 1 THEN CATCH, Error_Status
	IF Error_Status NE 0 THEN BEGIN
		CATCH,/CANCEL
		Error_Status=0
		print,'!!!! ERROR WITH THE '+STRING(intervallist(2*i))+' BURST !!!! ABORTING, AND GOING ON WITH NEXT ONE ... !!!!'
		OPENW,lun1,getlog('LOG_DIR')+'problem_bursts.list',/GET_LUN,/APPEND
		text=STRING(intervallist(2*i))
		printf,lun1,text
		FREE_LUN,lun1
		IF INDIVNOTIFY EQ 1 THEN BEGIN
			cmd='echo '+text+' |mailx -s "Ragburst problem" shilaire'
			spawn,cmd
		ENDIF
		HELP, CALLS=caller_stack
		PRINT, 'Error index: ', Error_status
		PRINT, 'Error message:', !ERR_STRING
		PRINT,'Error caller stack:',caller_stack
		!error_state.code=Error_Status	
		
		Help, /Last_Message, Output=theErrorMessage
		      FOR j=0,N_Elements(theErrorMessage)-1 DO PRINT, theErrorMessage[j]
		GOTO, NEXTBURSTPLEASE
	ENDIF
	;NEXTBURSTPLEASE:
	
	time_interval=[intervallist[2*i],intervallist[2*i+1]]
	print,'............... Doing burst : ',time_interval

	IF ((TODO NE 2) AND ( (anytim(time_interval[1])-anytim(time_interval[0])) LE MAXTIMEINTV) ) THEN BEGIN
		;do l1 and i files (Linear polarization or STOKES I) ---------------------------------------------------------------------------------------
		image=rapp_get_spectrogram(time_interval,xaxis=xaxis,yaxis=yaxis)
		loadct,5
		linecolors
		tvlct,r,g,b,/GET
		
		IF DATATYPE(image) EQ 'STR' THEN BEGIN
			PRINT,'......................Problem with intensity (Stokes I or l1 or l2) rag fits files for this burst!'
			IF INDIVNOTIFY EQ 1 THEN BEGIN
				text='Problem with intensity, i.e. Stokes I or l1 or l2, rag fits files for burst : '+anytim(time_interval[0],/ECS)
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
				acceptable_freq_interval = 5.*(yaxis[CHECKFIRSTLINES+1]-yaxis[CHECKFIRSTLINES])
				FOR k=0,CHECKFIRSTLINES-1 DO BEGIN
					IF ((yaxis[0]-yaxis[1]) GT acceptable_freq_interval) THEN BEGIN
						print,'Removing frequency channel : '+STRN(yaxis[0])
						oldny=N_ELEMENTS(yaxis)
						yaxis=yaxis[1:oldny-1]
						image=image[*,1:oldny-1]
					ENDIF
				ENDFOR
			ENDIF

			print,'Raw linear image (SFUs), from BurstStart-BEFORETIME to BurstEnd+ADDIMAGETIME:'
			print,'MIN: '+STRING(min(image))
			print,'MAX: '+STRING(max(image))
								
			IF LOGBACKSUB EQ 1 THEN image = 45.*ALOG10(TEMPORARY(image)+10.) 
		
			ERASE

			IF INVERT EQ 0 THEN BEGIN
				raglist2images_backsub, image, xaxis, anytim(time_interval[0],/TIME_ONLY), BACKGROUNDTIME, backavg=backavg, automatic=AUTO
				qv_elimwrong, image, xaxis, yaxis
			ENDIF ELSE BEGIN
				qv_elimwrong, image, xaxis, yaxis
				raglist2images_backsub, image, xaxis, anytim(time_interval[0],/TIME_ONLY), BACKGROUNDTIME, backavg=backavg, automatic=AUTO
			ENDELSE
					
			;take the parts starting and ending at correct times from burststart-ADDIMAGETIME to burstend+ADDIMAGETIME
			ss_start=WHERE(xaxis GT (anytim(time_interval(0)+BEFORETIME-ADDIMAGETIME,/time_only)))
			ss_start=ss_start[0]
			image=image[ss_start:n_elements(xaxis)-1,*]
			xaxis=xaxis[ss_start:n_elements(xaxis)-1]
	
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
						FOR j=0L,N_ELEMENTS(image[*,0])-1 DO BEGIN
							FOR k=0L,N_ELEMENTS(image(0,*))-1 DO BEGIN
								IF image[j,k] LT -9.0 THEN image[j,k]=-9.0
								IF image[j,k] GT topval THEN image[j,k]=topval						
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

;=======================================================================================================================================
;PLOTTING THE WHOLE BUSINESS:
;=======================================================================================================================================
			B5data=rapp_get_spectrogram(time_interval,xaxis=B5x,yaxis=B5y,/NODECOMPRESS,/ANYTIM,archivedir='/ftp/pub/rag/callisto/observations/',valid_file_identifiers='*BLEN5M*'+['l2','_59']+'.fit*', /BACK, /DESPIKE,/ELIM)
			IF datatype(B5data) NE 'STR' THEN BEGIN
				B5ok=1
				B5spg={spectrogram:b5data,x:B5x,y:B5y}
			ENDIF ELSE b5ok=0
			ZSTSspg=rapp_get_callisto(time_interval,datalabel,/BACK,/ELIM,/DESPIKE,source='ZSTS', /SMOOTH)
			IF datatype(ZSTSspg) EQ 'STR' THEN ZSTSok=0 ELSE ZSTSok=1
			
			;DEVICE, SET_RESOLUTION=[900,600+300*(B5ok+ZSTSok)]
			DEVICE, SET_RESOLUTION=[750,450+225*(B5ok+ZSTSok)]
			!P.MULTI=[0,1,2+B5ok+ZSTSok]
			charsize=2.

		;Callisto BLEIN5m (if any)
			IF B5ok THEN BEGIN
				thespg=rapp_add_empty_channels(B5spg)
				thespg.SPECTROGRAM = (-5) > thespg.SPECTROGRAM
				spectro_plot,cbar=0,thespg,xstyle=1,tit='CALLISTO -- BLEIEN 5m -- L2',ytit='Frequency [MHz]',xtit=' ',ymar=[0,2],xmar=[10,2],bottom=14,charsize=charsize,ystyle=1,timerange=time_interval,xtickname=REPLICATE(' ',10)
			ENDIF
		;Callisto Sonnenturm (if any)
			IF ZSTSok THEN BEGIN
				thespg=rapp_add_empty_channels(ZSTSspg)
				thespg.SPECTROGRAM = (-5) > thespg.SPECTROGRAM
				spectro_plot,cbar=0,thespg,xstyle=1,tit='CALLISTO -- ZSTS',ytit='Frequency [MHz]',xtit=' ',ymar=[0,2],xmar=[10,2],bottom=14,timerange=time_interval,xtickname=REPLICATE(' ',10),ystyle=1,charsize=charsize
			ENDIF
		;Phoenix-2 spg	
			spectro_plot,cbar=0,image,anytim(time_interval[0],/date)+xaxis,yaxis,xstyle=1,tit='Phoenix-2 - STOKES I - Data min/max: '+strn(datamin,format='(f10.1)')+'/'+strn(datamax,format='(f10.1)')+' SFU',ytit='Frequency [MHz]',xtit=' ',ymar=[0,2],xmar=[10,2],bottom=14,timerange=time_interval,xtickname=REPLICATE(' ',10),charsize=1+(B5ok OR ZSTSok)
		;GOES lightcurves
			!P.MULTI=[2,1,4+2*(B5ok+ZSTSok)]
			pg_plotgoes,time_interval,/ylog,int=5,yticklen=1,yminor=1,color=120,yrange=[1e-8,1e-3],xstyle=1,xtitle='',thick=2,/outinfoytitle,title='',charsize=charsize,xmar=[10,2],ymar=[2,1],timerange=time_interval,xtickname=REPLICATE(' ',10)
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
			ss=WHERE(r3) GT 5 & IF ss[0] EQ -1 THEN r3sub=0 ELSE r3sub=MIN(r3[ss])-1. & r3=r3-r3sub

			utplot,obstimes-obstimes[0],r1,obstimes[0],color=120,yr=[1,MAX([r1,r2,r3]) > 10],/YLOG,xstyle=1,ytit='[cts/s/det]',charsize=charsize,xmar=[10,2],ymar=[2,0],xtit='',tit='RHESSI corrected countrates'
			outplot,obstimes-obstimes[0],r2,color=200
			outplot,obstimes-obstimes[0],r3,color=7
			label_plot, 0.15, -1,'6-12 keV',color=120	
			label_plot, 0.40, -1,'12-25 keV',color=200	
			label_plot, 0.65, -1,'25-100 keV ('+strn(-r3sub,format='(f10.1)')+')',color=7
			
			;v3: overplot slashes for bad times (GAP/NIGHT/SAA)---------------------------------------
			oso=OBJ_NEW('hsi_obs_summary')
			oso->set,obs_time_interval=time_interval

			flagdata_struct=oso->getdata(class_name='obs_summ_flag')
			flagdata=flagdata_struct.FLAGS
			flaginfo=oso->get(class_name='obs_summ_flag')
			flagtimes=oso->getdata(class_name='obs_summ_flag',/time)

			flag_ss=[1,17,0]
			FOR j=0,N_ELEMENTS(flag_ss)-1 DO BEGIN
				CASE flag_ss[j] OF 
					1:BEGIN color=7 & ori=45 & END
					17:BEGIN color=4 & ori=0 & END
					ELSE: BEGIN color=2 & ori=90 & END
				ENDCASE				
				ss_intvs=psh_get_block_intv(flagdata[flag_ss[j],*],val=1)
				IF ss_intvs[0] NE -1 THEN BEGIN
					label_plot,0.03,j+1.3,flaginfo.FLAG_IDS[flag_ss[j]],color=color,POLYFILL={ORIENTATION:ori},/LINE
					FOR k=0,N_ELEMENTS(ss_intvs[0,*])-1 DO POLYFILL,[flagtimes[ss_intvs[0,k]],flagtimes[ss_intvs[1,k]],flagtimes[ss_intvs[1,k]],flagtimes[ss_intvs[0,k]]]-flagtimes[0],10^[!Y.CRANGE[0],!Y.CRANGE[0],!Y.CRANGE[1],!Y.CRANGE[1]],/LINE_FILL,ORIENTATION=ori,color=color,SPACING=1.
				ENDIF				
			ENDFOR
			;v3: END------------------------------------------------------------------------------

			img=TVRD(ORDER=0)

			extime=anytim(time_interval[0],/EX)
			outdir=getlog('IMAGE_DIR')+int2str(extime[6],4)+'/'+int2str(extime[5],2)+'/'+int2str(extime[4],2)+'/'
			IF NOT is_dir(outdir) THEN BEGIN
				FILE_MKDIR,outdir
				FILE_CHMOD,outdir,/A_READ
			ENDIF
			outfil=outdir+'/Phoenix-2_'+time2file(anytim(time_interval[0])+BEFORETIME,/seconds)+'_I.png'
			WRITE_PNG,outfil,img,r,g,b			
			HEAP_GC
		ENDELSE
	ENDIF ELSE print,'......I burst is longer than MAXTIMEINTV : not doing it...'
	IF ((TODO NE 1) AND ( (anytim(time_interval[1])-anytim(time_interval[0])) LE MAXTIMEINTV) ) THEN BEGIN
		;do p files	(STOKES V)-----------------------------------------------------------------------------------------
		image=rapp_get_spectrogram(time_interval,xaxis=xaxis,yaxis=yaxis,/POL)
		
		;loadct,6	;PRISM color table
		;tvlct,r,g,b,/GET
		;	r(255)=255
		;	g(255)=255
		;	b(255)=255
		;	tvlct,r,g,b
		polct
		tvlct,r,g,b,/GET
	
		IF DATATYPE(image) EQ 'STR' THEN BEGIN
			PRINT,'......................Problem with POLARISATION rag fits files for this burst!'
			IF INDIVNOTIFY EQ 1 THEN BEGIN
				text='Problem with polarisation rag fits files for burst : '+anytim(time_interval[0],/ECS)
				;cmd='echo '+text+' |mailx -s "Ragburst problem" shilaire'
				;spawn,cmd
				MESSAGE,text	
			ENDIF
		ENDIF $
		ELSE begin
			PRINT,'.............................DOING STOKES V.'

			;remove first N lines if frequencies are not OK.
			IF CHECKFIRSTLINES NE 0 THEN BEGIN
				acceptable_freq_interval = 5.*(yaxis(CHECKFIRSTLINES+1)-yaxis(CHECKFIRSTLINES))
				FOR k=0,CHECKFIRSTLINES-1 DO BEGIN
					IF ((yaxis[0]-yaxis[1]) GT acceptable_freq_interval) THEN BEGIN
						print,'Removing frequency channel : '+STRN(yaxis[0])
						oldny=N_ELEMENTS(yaxis)
						yaxis=yaxis[1:oldny-1]
						image=image[*,1:oldny-1]
					ENDIF
				ENDFOR
			ENDIF

			print,'Raw image, from BurstStart-BEFORETIME to BurstEnd+ADDIMAGETIME:'
			print,'MIN: '+STRING(min(image))
			print,'MAX: '+STRING(max(image))
	
			ERASE		

			; for POLARIZATION, I should NEVER use the /AUTOMATIC option of ConstBackSub_v21
				; my opinion is that for POLARIZATION, the /automatic keyword should NEVER be used. I put it here
				;	for convinience because ohterwise I have a bug...
			IF INVERT EQ 0 THEN BEGIN
				;raglist2images_backsub, image, xaxis, anytim(time_interval[0],/TIME_ONLY), BACKGROUNDTIME, automatic=AUTO
				qv_elimwrong, image, xaxis, yaxis
			ENDIF ELSE BEGIN
				qv_elimwrong, image, xaxis, yaxis
				;raglist2images_backsub, image, xaxis, anytim(time_interval[0],/TIME_ONLY), BACKGROUNDTIME, automatic=AUTO
			ENDELSE
			
			;take the parts starting and ending at correct times from burststart-ADDIMAGETIME to burstend+ADDIMAGETIME
			ss_start=WHERE(xaxis GT (anytim(time_interval(0)+BEFORETIME-ADDIMAGETIME,/time_only)))
			ss_start=ss_start[0]
			image=image[ss_start:n_elements(xaxis)-1,*]
			xaxis=xaxis[ss_start:n_elements(xaxis)-1]
			
			datamin = min(image, ss, max=datamax)	; this is in %polarization (negative = left)
			print,'Now, after backgnd subtraction & bad channels removal, polarization data has the following range: '
			print,'MIN: '+STRING(min(image))
			print,'MAX: '+STRING(max(image))
			
			IF CENTERPOL EQ 1 THEN BEGIN
				boundary = max([abs(datamin),abs(datamax)])
				datamin = -boundary
				datamax = boundary
				image(n_elements(xaxis)-1,0) = -boundary		; OK, this is a very benign cheat....
				image(n_elements(xaxis)-1,n_elements(yaxis)-1) = boundary
			ENDIF ELSE BEGIN
				IF CENTERPOL EQ 2 THEN BEGIN
					datamin = -100.
					datamax = 100.
					image(n_elements(xaxis)-1,0)=-100.		; Hey! This is also a very benign cheat....
					image(n_elements(xaxis)-1,n_elements(yaxis)-1)=100.
				ENDIF
			ENDELSE
			
			;remove some bad pixels:  PSH 2002/06/25
			image=remove_bad_pixels(image,thre=10.)
				
			ERASE
			DEVICE, SET_RESOLUTION=[768,512]
			!P.MULTI=0
			;z_show_image,image,xaxis-xaxis[0],yaxis,/hms,imageoffset=0,$
			;	XPOS=70,YPOS=35,xsize=768,ysize=512
			;write_add_info,STOKES='V',DATE=ANYTIM(time_interval(0),/ECS,/DATE_ONLY),datalimits=[datamin,datamax]
			spectro_plot,cbar=0,image,anytim(time_interval[0],/date)+xaxis,yaxis,xstyle=1,tit='Phoenix-2 - STOKES V - Data min/max: '+strn(datamin,format='(f10.1)')+'/'+strn(datamax,format='(f10.1)')+' % (NEGATIVE=LEFT)',ytit='Frequency [MHz]',xtit=' ',ymar=[2,3]
			img=tvrd(ORDER=0)

			extime=anytim(time_interval[0],/EX)
			outdir=getlog('IMAGE_DIR')+int2str(extime[6],4)+'/'+int2str(extime[5],2)+'/'+int2str(extime[4],2)+'/'
			IF NOT is_dir(outdir) THEN BEGIN
				FILE_MKDIR,outdir
				FILE_CHMOD,outdir,/A_READ
			ENDIF
			outfil=outdir+'/Phoenix-2_'+time2file(anytim(time_interval[0])+BEFORETIME,/seconds)+'_V.png'
			WRITE_PNG,outfil,img,r,g,b			

			HEAP_GC
		ENDELSE			
	ENDIF ELSE print,'......V burst is longer than MAXTIMEINTV : not doing it...'
	NEXTBURSTPLEASE:
ENDFOR

DEVICE, /CLOSE 

print,'.............. FINISHED WITHOUT BREAK ERRORS................'
print,'IDL-OK'
END
