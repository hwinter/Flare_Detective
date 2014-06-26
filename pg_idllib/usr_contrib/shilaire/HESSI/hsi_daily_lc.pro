; PSH 2002/03/12
;
;
; Makes daily lightcurves of HESSI, outputs them in a daily .png file:
;		HESSI_lc_yyyymmdd.png
;
;
;	One line of the page is one hour long. (-> 24 lines altogether!)
;
;	/Zbuffer: to use Z-buffering (for cron jobs...)
;	
;
;	Results are in COUNT RATES FOR ALL COLLIMATORS [cts/s]
;
;EXAMPLE:
;	hsi_daily_lc,'2002/02/20',/Zbuff,/GIF,/FITS		,outdir='HESSI/test/',/READ
;	hsi_daily_lc,'2002/02/20',/READFITS
;
;	IF keyword /GIF is used, it is assumed that you're running on IDL 5.3,
;	and that a GIF image must be added to the PNG image (which then has to 
;	be inverted).
;
;	If keyword /FITS is used, a daily fits file with the lightcurves is made (9 usual energy bands).
;	If keyword /READFITS is used, the lightcurves are made from the fits file	(and TIMEBIN is assumed same as for fits files)
;	If keyword /OBSSUMM is used, this where the data is read from, and the results are in cts/s/det instead of cts/s.
;
;	MODIFIED 2002/05/09 : separated the red 3-25 curve into the red 3-12 and orange 12-25
;	MODIFIED 2003/01/08 : for NIGHT/SAA flags: checks Obs. Summ. data if needed.
;	MODIFIED 2003/01/20 : added keyword /ObsSumm: routine will now use the Obs. Summary rates instead of lco to plot lightcurves (faster!)
;
;==========================================================================================================================


;=================================================================================================================
FUNCTION hsi_lc_hourly_from_fits, date, hour, TIMEBIN, $	; date in anytim format, hour is a double from 0 to 23.
		taxis=taxis
		
	CATCH, Error_Status
	IF Error_Status NE 0 THEN BEGIN
		;PRINT,'ERROR when doing  '+anytim(date,/ECS)+' from '+int2str(i,2)+':00 to '+int2str(i,2)+':59:59'
		HELP, CALLS=caller_stack
                PRINT, 'Error index: ', Error_status
                PRINT, 'Error message:', !ERR_STRING
                PRINT,'Error caller stack:',caller_stack
               !error_state.code=Error_Status
                PRINT,'...................... BAD HOURLY DATA, GOING ON .....................'		
		Error_Status=0		
		taxis='bad'
		RETURN,'bad'
	ENDIF

	fil='/global/helene/users/www/staff/shilaire/hessi/daily_lc/HESSI_lc_'+time2file(anytim(date,/date_only),/date_only)+'.fits'
	IF FILE_EXIST(fil) THEN BEGIN
		s=mrdfits(fil,1)
		;extract for the correct hour...
		ss=WHERE(s.times GE (anytim(date)+hour*3600D))
		ss_beg=ss(0)
		ss=WHERE(s.times LT (anytim(date)+(hour+1)*3600D))
		ss_end=ss(N_ELEMENTS(ss)-1)
		
		taxis=s.times(ss_beg:ss_end)
		lc=s.lc(ss_beg:ss_end,*)
		
		RETURN,lc		
	ENDIF ELSE MESSAGE,'No appropriate fits file found, aborting...'
END
;=================================================================================================================
;======================================================================================================
PRO hsi_daily_lc_plot_flags,tstart,tend,color=color,yrange
	IF NOT KEYWORD_SET(color) THEN color=255
	FOR t=tstart,tend,60 DO BEGIN
		PLOTS,/DATA,LINESTYLE=2,[t,t],yrange,color=color
	ENDFOR
END
;======================================================================================================
PRO hsi_daily_lc_add_flags,date,hour,yrange,ymid,OBSSUMM=OBSSUMM

taxis=anytim(date,/date)+hour*3600D + DINDGEN(3600)
ntimes=N_ELEMENTS(taxis)

;NIGHT FLAG:
IF NOT KEYWORD_SET(OBSSUMM) THEN res=hsi_obs_status([taxis(0),taxis(ntimes-1)],/NIGHT,interval=intv) ELSE res=-1
CASE res OF
	-1: BEGIN
		;try Obs. Summary...
		oso=hsi_obs_summary()
		oso->set,obs_time=[taxis[0],taxis(ntimes-1)]
		flagdata_struct=oso->getdata(class_name='obs_summ_flag')
		flagtimes=oso->getdata(class_name='obs_summ_flag',/time)
		OBJ_DESTROY,oso
		IF datatype(flagdata_struct) NE 'STC' THEN RETURN $	;XYOUTS,/DATA,taxis(ntimes/12),5*ymid,'no NIGHT/SAA check'
		ELSE BEGIN
		        flagdata=flagdata_struct.FLAGS[1]
			edges=WHERE(flagdata-SHIFT(flagdata,1) NE 0)
			IF edges[0] EQ -1 THEN RETURN
			i=0L
			n_edges=N_ELEMENTS(edges)
			WHILE i LT n_edges DO BEGIN
				IF flagdata[edges[i]] EQ 1 THEN BEGIN
					;we have the start of a night interval...
					startflagtime=flagtimes[edges[i]]				
					IF (i+1) LT n_edges THEN BEGIN
						;not till the end of the interval...
						i=i+1
						endflagtimes=flagtimes[edges[i]]
					ENDIF ELSE BEGIN
						;till the end of the interval...
						endflagtimes=taxis(ntimes-1)
					ENDELSE
					hsi_daily_lc_plot_flags,startflagtime-taxis[0],endflagtimes-taxis[0],color=200,yrange				
				ENDIF			
				i=i+1
			ENDWHILE
		ENDELSE		
	END
	0: RETURN	
	1: BEGIN
		n_intv=N_ELEMENTS(intv[0,*])
		FOR i=0,n_intv-1 DO BEGIN
			tmp=has_overlap([taxis[0],taxis[ntimes-1]],intv[*,i],inter=overintv)
			hsi_daily_lc_plot_flags,overintv[0]-taxis[0],overintv[1]-taxis[0],color=200,yrange
		ENDFOR
	END
ENDCASE

;SAA FLAG
res=hsi_obs_status([taxis(0),taxis(ntimes-1)],/SAA,interval=intv)
CASE res OF
	-1: BEGIN
		;try Obs. Summary...
		oso=hsi_obs_summary()
		oso->set,obs_time=[taxis(0),taxis(ntimes-1)]
		flagdata_struct=oso->getdata(class_name='obs_summ_flag')
		flagtimes=oso->getdata(class_name='obs_summ_flag',/time)
		OBJ_DESTROY,oso
		IF datatype(flagdata_struct) NE 'STC' THEN RETURN $	;XYOUTS,/DATA,taxis(ntimes/12),5*ymid,'no NIGHT/SAA check'
		ELSE BEGIN
	        	flagdata=flagdata_struct.FLAGS[0]
			edges=WHERE(flagdata-SHIFT(flagdata,1) NE 0)
			i=0L
			IF edges[0] EQ -1 THEN RETURN
			n_edges=N_ELEMENTS(edges)
			WHILE i LT n_edges DO BEGIN
				IF flagdata[edges[i]] EQ 1 THEN BEGIN
					;we have the start of a night interval...
					startflagtime=flagtimes[edges[i]]				
					IF (i+1) LT n_edges THEN BEGIN
						;not till the end of the interval...
						i=i+1
						endflagtimes=flagtimes[edges[i]]
					ENDIF ELSE BEGIN
						;till the end of the interval...
						endflagtimes=taxis(ntimes-1)
					ENDELSE
					hsi_daily_lc_plot_flags,startflagtime-taxis[0],endflagtimes-taxis[0],color=254,yrange				
				ENDIF			
				i=i+1
			ENDWHILE
		ENDELSE		
	END
	0: RETURN	
	1: BEGIN
		n_intv=N_ELEMENTS(intv(0,*))
		FOR i=0,n_intv-1 DO BEGIN
			tmp=has_overlap([taxis[0],taxis[ntimes-1]],intv[*,i],inter=overintv)
			hsi_daily_lc_plot_flags,overintv(0)-taxis(0),overintv(1)-taxis(0),color=254,yrange
		ENDFOR
	END
ENDCASE
END
;=================================================================================================================
FUNCTION hsi_daily_lc_hourly_lc, date, hour, TIMEBIN, OBSSUMM=OBSSUMM, $	; date in anytim format, hour is a double from 0 to 23.
		taxis=taxis
		
	CATCH, Error_Status
	IF Error_Status NE 0 THEN BEGIN
		CATCH,/CANCEL
		;PRINT,'ERROR when doing  '+anytim(date,/ECS)+' from '+int2str(i,2)+':00 to '+int2str(i,2)+':59:59'
		HELP, CALLS=caller_stack
                PRINT, 'Error index: ', Error_status
                PRINT, 'Error message:', !ERR_STRING
                PRINT,'Error caller stack:',caller_stack
		HELP, /Last_Message, Output=theErrorMessage
		FOR j=0,N_Elements(theErrorMessage)-1 DO PRINT, theErrorMessage[j]
               !error_state.code=Error_Status
                PRINT,'...................... GOING ON TO THE NEXT ONE .....................'
		Error_Status=0		
		taxis='bad'
		RETURN,'bad'
	ENDIF

	time_intv=anytim(date,/date)+DOUBLE(hour)*3600D
	time_intv=time_intv + [0,3599]
	IF NOT KEYWORD_SET(OBSSUMM) THEN BEGIN
		lco=hsi_lightcurve()
		lco->set,time_range=time_intv	
		lco->set,ltc_time_res=TIMEBIN,ltc_energy_band=[3,6,12,25,50,100,300,1000,2500,17000]	;formerly [3,25,100,17000]
		lco->set,seg_index_mask=BYTARR(18)+1B
		lc=lco->getdata()	
		IF lc[0,0] EQ -1 THEN RETURN,'bad'			;Added 2002/04/08, because of Kim
		lc=lc/TIMEBIN
		taxis=lco->getdata(/xaxis)
		obj_destroy,lco
	ENDIF ELSE BEGIN
		oso=hsi_obs_summary()
		oso->set,obs_time=time_intv
		rate_struct=oso->getdata(class_name='hsi_obs_summ_rate')
		IF datatype(rate_struct) EQ 'INT' THEN RETURN,'bad'
		TIMEBIN=oso->get(class_name='hsi_obs_summ_rate',/time_intv)
		taxis=oso->getdata(class_name='hsi_obs_summ_rate',/time)
		OBJ_DESTROY,oso
		rates=rate_struct.COUNTRATE
		IF datatype(rates) EQ 'BYT' THEN rates=hsi_obs_summ_decompress(rates)
		lc=TRANSPOSE(rates)
	ENDELSE
	
	RETURN,lc
END
;=================================================================================================================
;=================================================================================================================
PRO hsi_daily_lc, date, outdir=outdir,Zbuffer=Zbuffer, GIF=GIF, FITS=FITS, READFITS=READFITS, OBSSUMM=OBSSUMM
	starttime=SYSTIME(/SEC)
	
	;....................................
	IMGXSIZ=900
	IMGYSIZ=1200
	TIMEBIN=4.	;[seconds]
	IF KEYWORD_SET(OBSSUMM) THEN yrange=[1.,10000.] ELSE yrange=[1e2,1e5]
	ymid=10^((alog10(yrange[0])+alog10(yrange[1]))/2)
	;....................................
	
	; date in anytim format
	date=anytim(date,/date_only)
	
	IF NOT KEYWORD_SET(outdir) THEN outdir='/global/saturn/data1/www/staff/shilaire/hessi/daily_lc/'	;'/global/hercules/data1/hessi/daily/'
	IF KEYWORD_SET(Zbuffer) THEN BEGIN
		SET_PLOT, 'Z', /COPY                            ; Kuddos for the Z-Buffer !!!!
		DEVICE, SET_RESOLUTION=[IMGXSIZ,IMGYSIZ]
		ERASE
	ENDIF ELSE BEGIN
		WINDOW,0,xs=IMGXSIZ,ys=IMGYSIZ
	ENDELSE
	IF KEYWORD_SET(OBSSUMM) THEN READFITS=0

	myct3,ct=1
	TVLCT,r,g,b,/GET
	!P.MULTI=[0,1,24]
	
	alldaytaxis='bla'
	alldaylc='bla'

	FOR i=0,23 DO BEGIN      		
		Error_Status=0
		CATCH, Error_Status
		IF Error_Status NE 0 THEN BEGIN
			CATCH,/CANCEL
			HELP, CALLS=caller_stack
	                PRINT, 'Error index: ', Error_status
	                PRINT, 'Error message:', !ERR_STRING
	                PRINT,'Error caller stack:',caller_stack
			HELP, /Last_Message, Output=theErrorMessage
			FOR j=0,N_Elements(theErrorMessage)-1 DO PRINT, theErrorMessage[j]
	                PRINT,'...................... GOING ON TO THE NEXT ONE .....................'
			GOTO,NEXTPLEASE
		ENDIF

		IF KEYWORD_SET(READFITS) THEN lc=hsi_lc_hourly_from_fits(date,i,TIMEBIN,taxis=taxis) ELSE lc=hsi_daily_lc_hourly_lc(date,i,TIMEBIN,taxis=taxis,OBSSUMM=OBSSUMM)
		; Error checking on lc and taxis...
		lcOK=0
		IF datatype(lc) ne 'STR' THEN IF N_ELEMENTS(taxis) gt 1 THEN lcOK=1		
		
		IF lcOK eq 1 THEN BEGIN
			clear_utplot	;you never the strange things utplot manages to do...
			times=taxis-taxis[0]
			utplot,times,lc[*,0],taxis[0],/YLOG,xmar=[0,0],ymar=[0,0],yrange=yrange,TICK_UNIT=300.,			$
				MIN_VALUE=1., MAX_VALUE=1e9,Xstyle=1,xtitle='',charsiz=2.0,/nodata,	$
				xticks=4,xminor=1,yminor=1,xtickname=[' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' '],	$
				xticklen=0.1,yticklen=0.003
			
			npts=N_ELEMENTS(times)
			PLOTS,[times[0],times[npts-1]],[ymid,ymid],linestyle=1
			
			tmp=total(lc[*,0:1],2)
			outplot,times,tmp,color=249
			tmp=lc[*,2]
			outplot,times,tmp,color=250
			tmp=total(lc[*,3:4],2)
			outplot,times,tmp,color=251
			tmp=total(lc[*,5:*],2)
			outplot,times,tmp,color=252

			PLOTS,[times(npts/4),times(npts/4)],[yrange[0],yrange[1]],/DATA,LINESTYLE=0
			PLOTS,[times(npts/2),times(npts/2)],[yrange[0],yrange[1]],/DATA,LINESTYLE=0
			PLOTS,[times(3*npts/4),times(3*npts/4)],[yrange[0],yrange[1]],/DATA,LINESTYLE=0
		
			IF KEYWORD_SET(FITS) THEN BEGIN
				IF datatype(alldaytaxis) EQ 'STR' THEN alldaytaxis=taxis ELSE alldaytaxis=[alldaytaxis,taxis]
				IF datatype(alldaylc) EQ 'STR' THEN alldaylc=lc ELSE alldaylc=[alldaylc,lc]
			ENDIF
							
		ENDIF ELSE BEGIN
			plot,TIMEBIN*FINDGEN(3600./TIMEBIN),FINDGEN(yrange[1]-yrange[0])+yrange[0],/YLOG,xmar=[0,0],ymar=[0,0],Xstyle=1,xtitle='',/nodata,xticklen=0.0001,yticklen=0.0001,$
				xtickname=[' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' '],yrange=yrange
			;XYOUTS,/DATA,420,380,color=253,'PROBLEM READING THE DATA'
			;XYOUTS,/DATA,460,380,color=253,'DODGY DATA'
			XYOUTS,/DATA,1625,1500,color=253,'DODGY DATA'
		ENDELSE
		;IF i ne 0 THEN XYOUTS,/DATA,anytim(date,/date)+3600D*i+35.,5*ymid,int2str(i,2)+':00' ELSE XYOUTS,/DATA,anytim(date,/date)+3600D*i+35.,5*ymid,'PSH/ETHZ '+anytim(date,/date,/ECS)
		IF i ne 0 THEN XYOUTS,/DEVICE,9,IMGYSIZ-i*(IMGYSIZ/24.)-(IMGYSIZ/(24.*3.)),int2str(i,2)+':00' ELSE XYOUTS,/DEVICE,9,IMGYSIZ-(IMGYSIZ/(24.*3.)),anytim(date,/date,/ECS)
		hsi_daily_lc_add_flags,date,i,yrange,ymid,OBSSUMM=OBSSUMM

		NEXTPLEASE:
	ENDFOR
			;XYOUTS,/DEVICE,850,5,'ETHZ'
			;PLOTS,[IMGXSIZ/4,IMGXSIZ/4],(IMGYSIZ-i*IMGYSIZ/24.)+[0,-IMGYSIZ/24.],/DEVICE,LINESTYLE=0
			;PLOTS,[IMGXSIZ/2 +1,IMGXSIZ/2 +1],(IMGYSIZ-i*IMGYSIZ/24.)+[0,-IMGYSIZ/24.],/DEVICE,LINESTYLE=0
			;PLOTS,[3*IMGXSIZ/4 +1,3*IMGXSIZ/4 +1],(IMGYSIZ-i*IMGYSIZ/24.)+[0,-IMGYSIZ/24.],/DEVICE,LINESTYLE=0

	tmp1=anytim(date[0],/date_only,/EX)
	outfil=outdir+int2str(tmp1[6],4)+'/HESSI_lc_'+time2file(anytim(date,/date_only),/date_only)
	IF NOT KEYWORD_SET(GIF) THEN write_png,outfil+'.png',TVRD(),r,g,b ELSE BEGIN
		write_png,outfil+'.png',TVRD(/ORDER),r,g,b
		write_gif,outfil+'.gif',TVRD(),r,g,b
	ENDELSE
	
	IF KEYWORD_SET(FITS) THEN BEGIN
		hsi_lc={ times: alldaytaxis, $
				 lc	:	alldaylc	}
		mwrfits,hsi_lc,outfil+'.fits',/create
	ENDIF
	
	IF KEYWORD_SET(Zbuffer) THEN DEVICE,/CLOSE
	
	heap_gc
	endtime=SYSTIME(/SEC)	
	PRINT,'........................  hsi_daily.pro took '+strn(endtime-starttime)+' seconds to complete.'	
END
;============================================================================================================
;============================================================================================================

