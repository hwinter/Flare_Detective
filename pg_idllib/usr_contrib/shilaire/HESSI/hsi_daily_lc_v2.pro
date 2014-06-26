; PSH 2002/03/31
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
;	Results are in COUNT RATES IN ALL COLLIMATORS [cts/s]
;
;
;	hsi_daily_lc_v2,'2002/02/20',/Zbuff,/GIF,/FITS,outdir='HESSI/test/'
;
;	IF keyword /GIF is used, it is assumed that you're running on IDL 5.3,
;	and that a GIF image must be added to the PNG image (which then has to 
;	be inverted).
;
;	If keyword /FITS is used, a fits file with lightcurves is made.
;
;======================================================================================================



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
;=================================================================================================================
PRO hsi_daily_lc_v2, date, outdir=outdir,Zbuffer=Zbuffer, GIF=GIF

	starttime=SYSTIME(/SEC)
	
	;....................................
	;....................................
	IMGXSIZ=900
	IMGYSIZ=1200
	TIMEBIN=4.	;[seconds]
	yrange=[0.,1.]
	ymid=0.5
	;....................................
	;....................................
	offset1=0.
	scale1=1/1e5
	offset2=0.
	scale2=1/15000.
	offset3=0.
	scale3=1/5000.
	;....................................
	;....................................
	
	
	; date in anytim format
	date=anytim(date,/date_only)
	
	IF NOT KEYWORD_SET(outdir) THEN outdir='/global/helene/users/www/staff/shilaire/hessi/daily_lc2/'	;'/global/hercules/data1/hessi/daily/'
	IF KEYWORD_SET(Zbuffer) THEN BEGIN
		SET_PLOT, 'Z', /COPY                            ; Kuddos for the Z-Buffer !!!!
		DEVICE, SET_RESOLUTION=[IMGXSIZ,IMGYSIZ]
		ERASE
	ENDIF ELSE BEGIN
		WINDOW,0,xs=IMGXSIZ,ys=IMGYSIZ
	ENDELSE

	myct3,ct=1
	TVLCT,r,g,b,/GET
	!P.MULTI=[0,1,24]
	
	FOR i=0,23 DO BEGIN      		
		lc=hsi_lc_hourly_from_fits(date,i,TIMEBIN,taxis=taxis)
		; Error checking on lc and taxis...
		lcOK=0
		IF datatype(lc) ne 'STR' THEN IF N_ELEMENTS(taxis) gt 1 THEN lcOK=1		
		
		IF lcOK eq 1 THEN BEGIN
			clear_utplot	;you never the strange things utplot manages to do...
			times=taxis-taxis(0)
			utplot,times,lc(*,0),taxis(0),xmar=[0,0],ymar=[0,0],yrange=yrange,TICK_UNIT=300.,			$
				MIN_VALUE=1., MAX_VALUE=1e9,Xstyle=1,xtitle='',charsiz=2.0,/nodata,	$
				xticks=4,xminor=1,yminor=1,xtickname=[' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' '],	$
				xticklen=0.1,yticklen=0.003
			
			npts=N_ELEMENTS(times)

			tmp=total(lc(*,0:2),2)
			outplot,times,(tmp-offset1)*scale1,color=249
			tmp=total(lc(*,3:4),2)
			outplot,times,(tmp-offset2)*scale2,color=251
			tmp=total(lc(*,5:8),2)
			outplot,times,(tmp-offset3)*scale3,color=252

			PLOTS,[times(npts/4),times(npts/4)],[yrange(0),yrange(1)],/DATA,LINESTYLE=0
			PLOTS,[times(npts/2),times(npts/2)],[yrange(0),yrange(1)],/DATA,LINESTYLE=0
			PLOTS,[times(3*npts/4),times(3*npts/4)],[yrange(0),yrange(1)],/DATA,LINESTYLE=0
		
		ENDIF ELSE BEGIN
			plot,TIMEBIN*FINDGEN(3600./TIMEBIN),FINDGEN(3600./TIMEBIN)*TIMEBIN/3600.*(yrange(1)-yrange(0))+yrange(0),xmar=[0,0],ymar=[0,0],Xstyle=1,xtitle='',/nodata,xticklen=0.0001,yticklen=0.0001,$
				xtickname=[' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' '],yrange=yrange
			;XYOUTS,/DATA,420,380,color=253,'PROBLEM READING THE DATA'
			;XYOUTS,/DATA,460,380,color=253,'DODGY DATA'
			XYOUTS,/DATA,1625,0.4,color=253,'DODGY DATA'
		ENDELSE
		;IF i ne 0 THEN XYOUTS,/DATA,anytim(date,/date)+3600D*i+35.,5*ymid,int2str(i,2)+':00' ELSE XYOUTS,/DATA,anytim(date,/date)+3600D*i+35.,5*ymid,'PSH/ETHZ '+anytim(date,/date,/ECS)
		IF i ne 0 THEN XYOUTS,/DEVICE,9,IMGYSIZ-i*(IMGYSIZ/24.)-(IMGYSIZ/(24.*3.)),int2str(i,2)+':00' ELSE XYOUTS,/DEVICE,9,IMGYSIZ-(IMGYSIZ/(24.*3.)),anytim(date,/date,/ECS)
		hsi_daily_lc_add_flags,date,i,yrange,ymid
	ENDFOR

	outfil=outdir+'HESSI_lc2_'+time2file(anytim(date,/date_only),/date_only)
	outfil=outfil(0)
	IF NOT KEYWORD_SET(GIF) THEN write_png,outfil+'.png',TVRD(),r,g,b ELSE BEGIN
		write_png,outfil+'.png',TVRD(/ORDER),r,g,b
		write_gif,outfil+'.gif',TVRD(),r,g,b
	ENDELSE
	
	!P.MULTI=0
	IF KEYWORD_SET(Zbuffer) THEN BEGIN
		DEVICE,/CLOSE
		SET_PLOT,'X'		
	ENDIF ELSE WDELETE,0
	
	heap_gc
	endtime=SYSTIME(/SEC)	
	PRINT,'........................  hsi_daily_lc_v2.pro took '+strn(endtime-starttime)+' seconds to complete.'	
END
;============================================================================================================
;============================================================================================================

