;+
; PSH: Written in a hurry on 2004/09/22
; This routine was designed to be easily modifiable according to users' wishes!!!
;
; /SMOOTHING only for Callisto stuff (so far).
; /ADD_NULL_CHANNELS also only for Callisto stuff (so far).
;
; EXAMPLE:
;	LOADCT,5 & rapp_time_profiles,'2004/07/23 '+['17:05','17:40'],/BACK,/ELIM,/DESPIKE,/SMOOTH,/ADD_NULL_CH
;	SET_PLOT,'PS' & LOADCT,0 & rapp_time_profiles,'2004/07/23 '+['17:05','17:40'],/STD & DEVICE,/CLOSE
;
;-
PRO rapp_time_profiles, time_intv, BACK=BACK, DESPIKE=DESPIKE, ELIM=ELIM, SMOOTHING=SMOOTHING, ADD_NULL_CHANNELS=ADD_NULL_CHANNELS, STD=STD
	IF KEYWORD_SET(SMOOTHING) THEN BEGIN
		IF SMOOTHING EQ 1 THEN SMOOTHING=5
	ENDIF
	IF KEYWORD_SET(STD) THEN BEGIN
		BACK=1
		DESPIKE=1
		ELIM=1
		SMOOTHING=5
		ADD_NULL_CHANNELS=1
	ENDIF
;------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	;Some plotting options...
		IF !D.NAME EQ 'PS' THEN charsize=1 ELSE charsize=2
		color1=120
		color2=200	; Values designed here for loadct,5
		color3=50
;------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	;Getting Callisto BLEIN5M L2 data:
		data=rapp_get_spectrogram(time_intv,xaxis=xaxis,yaxis=yaxis,/NODECOMPRESS,/ANYTIM,archivedir='/ftp/pub/rag/callisto/observations/',valid_file_identifiers='*BLEN5M*l2.fit*', BACK=BACK, DESPIKE=DESPIKE, ELIM=ELIM)
		IF datatype(data) EQ 'STR' THEN BEGIN
			PRINT,'No Callisto Blein5m data found.'
			c1spg=-1
		ENDIF ELSE BEGIN
			IF KEYWORD_SET(SMOOTHING) THEN data=SMOOTH(data,SMOOTHING)
			c1spg={spectrogram:data,x:xaxis,y:yaxis}
			IF KEYWORD_SET(ADD_NULL_CHANNELS) THEN c1spg=rapp_add_empty_channels(c1spg)
		ENDELSE
;------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	;Getting Callisto ZSTS LC+RC data:
		data=rapp_get_spectrogram(time_intv,xaxis=xaxis1,yaxis=yaxis1,/NODECOMPRESS,/ANYTIM,archivedir='/ftp/pub/rag/callisto/observations/',valid_file_identifiers='*ZSTS*lc.fit*', BACK=BACK, DESPIKE=DESPIKE)
		IF datatype(data) EQ 'STR' THEN BEGIN
			PRINT,'No Callisto ZSTS LC data found.'
			c2lcspg=-1
		ENDIF ELSE c2lcspg={spectrogram:data,x:xaxis1,y:yaxis1}	

		data=rapp_get_spectrogram(time_intv,xaxis=xaxis2,yaxis=yaxis2,/NODECOMPRESS,/ANYTIM,archivedir='/ftp/pub/rag/callisto/observations/',valid_file_identifiers='*ZSTS*rc.fit*', BACK=BACK, DESPIKE=DESPIKE)
		IF datatype(data) EQ 'STR' THEN BEGIN
			PRINT,'No Callisto ZSTS RC data found.'
			c2rcspg=-1
		ENDIF ELSE c2rcspg={spectrogram:data,x:xaxis2,y:yaxis2}	

		IF datatype(c2lcspg) NE 'STC' THEN c2spg=c2rcspg ELSE BEGIN
			c2spg=c2lcspg
			IF datatype(c2rcspg) EQ 'STC' THEN BEGIN
				c2spg.spectrogram=c2lcspg.spectrogram+c2rcspg.spectrogram
				;some warning checks:
				IF c2lcspg.x[0] NE c2rcspg.x[0] THEN PRINT,'WARNING: Callisto ZSTS LC/RC spgs starting '+strn(abs(c2lc.x[0]-c2rc.x[0]))+' seconds apart!'
				IF N_ELEMENTS(c2lcspg.x) NE N_ELEMENTS(c2rcspg.x) THEN PRINT,'WARNING: Callisto ZSTS LC/RC spgs have different number of elements in time-axis!'
				IF c2lcspg.y[0] NE c2rcspg.y[0] THEN PRINT,'WARNING: Callisto ZSTS LC/RC spgs starting '+strn(abs(c2lc.y[0]-c2rc.y[0]))+' MHz apart!'
				IF N_ELEMENTS(c2lcspg.y) NE N_ELEMENTS(c2rcspg.y) THEN PRINT,'WARNING: Callisto ZSTS LC/RC spgs have different number of elements in frequency-axis!'
			ENDIF
		ENDELSE
		
		IF datatype(c2spg) EQ 'STC' THEN BEGIN
			IF KEYWORD_SET(ELIM) THEN BEGIN
				f=c2spg.spectrogram
				x=c2spg.x
				y=c2spg.y
				rapp_elim_wrong_channels, f,x,y
				c2spg={spectrogram:f,x:x,y:y}
			ENDIF
			IF KEYWORD_SET(SMOOTHING) THEN c2spg.spectrogram=SMOOTH(c2spg.spectrogram,SMOOTHING)
			IF KEYWORD_SET(ADD_NULL_CHANNELS) THEN c2spg=rapp_add_empty_channels(c2spg)
		ENDIF
;------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	;Getting Phoenix-2 L1,L2 or I data:
		data=rapp_get_spectrogram(time_intv,xaxis=xaxis,yaxis=yaxis,/NODECOMPRESS,/ANYTIM,archivedir='/ftp/pub/rag/phoenix-2/observations/', BACK=BACK, DESPIKE=DESPIKE, ELIM=ELIM)
		IF datatype(data) EQ 'STR' THEN BEGIN
			PRINT,'No Phoenix-2 data found.'
			pspg=-1
		ENDIF ELSE pspg={spectrogram:data,x:xaxis,y:yaxis}
		;IF KEYWORD_SET(SMOOTHING) THEN pspg.spectrogram=SMOOTH(pspg.spectrogram,SMOOTHING)
		;IF KEYWORD_SET(ADD_NULL_CHANNELS) THEN pspg=rapp_add_empty_channels(pspg)
;------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	;Plotting radio spectrograms (if available)
		n_spgs=(datatype(c1spg) EQ 'STC')+(datatype(c2spg) EQ 'STC')+(datatype(pspg) EQ 'STC')
		!P.MULTI=[0,1,n_spgs+1]
		IF datatype(c1spg) EQ 'STC' THEN spectro_plot,c1spg,xstyle=1,xtit=' ',timerange=time_intv,xtickname=REPLICATE(' ',10),xmar=[10,2],ymar=[0,2],yr=[200,40],ystyle=1,charsize=charsize,tit='CALLISTO -- BLEIEN 5m -- L2',ytit='Frequency [MHz]' ;,bottom=14
		IF datatype(c2spg) EQ 'STC' THEN spectro_plot,c2spg,xstyle=1,xtit=' ',timerange=time_intv,xtickname=REPLICATE(' ',10),xmar=[10,2],ymar=[0,2],ystyle=1,charsize=charsize,tit='CALLISTO -- ZSTS',ytit='Frequency [MHz]' ;,bottom=14
		IF datatype(pspg) EQ 'STC' THEN spectro_plot,pspg,xstyle=1,xtit=' ',timerange=time_intv,xtickname=REPLICATE(' ',10),xmar=[10,2],ymar=[0,2],ystyle=1,charsize=charsize,tit='Phoenix-2',ytit='Frequency [MHz]' ;,bottom=14		
;------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	;Getting & plotting GOES lightcurves
			!P.MULTI=[2,1,2+2*n_spgs]
			pg_plotgoes,time_intv,/ylog,int=5,yticklen=1,yminor=1,color=color1,yrange=[1e-8,1e-3],xstyle=1,xtitle='',thick=2,/outinfoytitle,title='',charsize=charsize,xmar=[10,2],ymar=[2,1],timerange=time_interval,xtickname=REPLICATE(' ',10)
			pg_plotgoes,time_intv,int=5,color=color2,channel=2,/over 
;------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	;Getting & plotting RHESSI lightcurves
			ro=OBJ_NEW('hsi_obs_summ_rate')
			ro->set,obs_time_interval=time_intv
			tmp=ro->getdata()
			obstimes=ro->getdata(/xaxis)
			rates=ro->corrected_countrate()
			OBJ_DESTROY,ro
			r1=REFORM(rates[1,*])
			r2=REFORM(rates[2,*])
			r3=TOTAL(rates[3:4,*],1)
			ss=WHERE(r3) GT 5 & r3sub=MIN(r3[ss])-1. & r3=r3-r3sub

			utplot,obstimes-obstimes[0],r1,obstimes[0],color=color1,yr=[1,MAX([r1,r2,r3]) > 10],/YLOG,xstyle=1,ytit='[cts/s/det]',charsize=charsize,xmar=[10,2],ymar=[2,0],xtit='',tit='RHESSI corrected countrates'
			outplot,obstimes-obstimes[0],r2,color=color2
			outplot,obstimes-obstimes[0],r3,color=color3
			label_plot, 0.85, -1,'6-12 keV',color=color1,charsize=charsize/2.
			label_plot, 0.85, -2,'12-25 keV',color=color2,charsize=charsize/2.
			label_plot, 0.85, -3,'25-100 keV ('+strn(-r3sub,format='(f10.1)')+')',color=color3,charsize=charsize/2.
			
			;v3: overplot slashes for bad times (GAP/NIGHT/SAA)---------------------------------------
			oso=OBJ_NEW('hsi_obs_summary')
			oso->set,obs_time_interval=time_intv

			flagdata_struct=oso->getdata(class_name='obs_summ_flag')
			flagdata=flagdata_struct.FLAGS
			flaginfo=oso->get(class_name='obs_summ_flag')
			flagtimes=oso->getdata(class_name='obs_summ_flag',/time)

			flag_ss=[1,17,0]
			FOR j=0,N_ELEMENTS(flag_ss)-1 DO BEGIN
				CASE flag_ss[j] OF 
					1:BEGIN color=color3 & ori=45 & END
					17:BEGIN color=color2 & ori=0 & END
					ELSE: BEGIN color=color1 & ori=90 & END
				ENDCASE				
				ss_intvs=psh_get_block_intv(flagdata[flag_ss[j],*],val=1)
				IF ss_intvs[0] NE -1 THEN BEGIN
					label_plot,0.03,j+1.3,flaginfo.FLAG_IDS[flag_ss[j]],color=color,POLYFILL={ORIENTATION:ori},/LINE,charsize=charsize/2.
					FOR k=0,N_ELEMENTS(ss_intvs[0,*])-1 DO POLYFILL,[flagtimes[ss_intvs[0,k]],flagtimes[ss_intvs[1,k]],flagtimes[ss_intvs[1,k]],flagtimes[ss_intvs[0,k]]]-flagtimes[0],10^[!Y.CRANGE[0],!Y.CRANGE[0],!Y.CRANGE[1],!Y.CRANGE[1]],/LINE_FILL,ORIENTATION=ori,color=color,SPACING=1.
				ENDIF				
			ENDFOR
;------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
END

