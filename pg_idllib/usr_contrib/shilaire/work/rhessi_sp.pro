
;EX:
;	rhessi_sp, '2002/05/17 '+['07:20:30','07:40:30'], times='2002/05/17 '+['07:28','07:30','07:33','07:38'], back_time='2002/05/17 07:24',spo=spo,/SPG
;rhessi_sp, '2002/07/26 '+['15:22','15:40'], times='2002/07/26 '+['15:27','15:28','15:29','15:31','15:32','15:35','15:36','15:37'], back_time='2002/07/26 15:24:30',spo=spo,/SPG, dt=-1,yr=[1e-2,1e6],xstyle=1,xr=[3,100]
;
;
;	;BACKGROUND is subtracted if keyword back_time is used, in the following manner:
;	if signal is more than 150% above background, normal subtraction. Else, value put to zero.
;	The whole business is OK as long as we're below 150 keV, according to RAS.
;	If keyword dt is set to a negative number, then an accumulation time of -dt*spin_period is assumed wanted
;




PRO rhessi_sp, time_intv, times=times, dt=dt, back_time=back_time, SPG=SPG, spo=spo, _extra=_extra
	
	IF NOT KEYWORD_SET(spo) THEN BEGIN
		spo=hsi_spectrum()
		spo->set,time_range=time_intv
		spo->set,sp_data_unit='Flux'
		spo->set,seg_index_mask=[1,0,1,1,1,1,0,0,1,0,0,0,0,0,0,0,0,0],sp_energy_bin=1,sp_semi_cal=1
	ENDIF
		
		IF NOT KEYWORD_SET(dt) THEN dt=60.
		IF dt LT 0. THEN dt=-dt*rhessi_get_spin_period( (anytim(time_intv[0])+anytim(time_intv[1]))/2. )
		spo->set,sp_time_interval=dt		
		sp=spo->getdata()
		ebin_arr=spo->getdata(/xaxis)
		time_arr=spo->getdata(/yaxis)
		sp=spo->getdata()
	
	;choose which times to plot...-->times_ss
	IF NOT KEYWORD_SET(times) THEN times_ss=INDGEN(N_ELEMENTS(time_arr)) ELSE BEGIN
		times_ss=-1
		FOR i=0,N_ELEMENTS(times)-1 DO BEGIN
			ss=WHERE(anytim(time_arr) GE anytim(times[i]))
			IF ss[0] NE -1 THEN BEGIN
				IF times_ss[0] EQ -1 THEN times_ss=ss[0] ELSE times_ss=[times_ss,ss[0]]
			ENDIF
		ENDFOR
	ENDELSE

	;find and do background-subtraction, if any -->back_ss, sp
	IF NOT KEYWORD_SET(back_time) THEN back_ss=-1 ELSE BEGIN
		ss=WHERE(anytim(time_arr) GE anytim(back_time))
		back_ss=ss[0]
		back_sp=sp[*,back_ss]
		FOR i=0,N_ELEMENTS(ebin_arr)-1 DO BEGIN
			FOR j=0,N_ELEMENTS(time_arr)-1 DO BEGIN
				IF sp[i,j] GE 1.5*back_sp[i] THEN sp[i,j]=sp[i,j]-back_sp[i] ELSE sp[i,j]=0.
			ENDFOR		
		ENDFOR
	ENDELSE		

	IF times_ss[0] EQ -1 THEN RETURN
	;GRAPHIC OUTPUT
		psh_win,768
		LOADCT,5
		IF KEYWORD_SET(SPG) THEN BEGIN		
			!P.MULTI=[0,1,2]
			spectro_plot,TRANSPOSE(sp), time_arr, ebin_arr,/YLOG,/ZLOG,ytit='[keV]'
			FOR i=0,N_ELEMENTS(times_ss)-1 DO BEGIN
				color=!D.TABLE_SIZE-10-i*(!D.TABLE_SIZE-10)/N_ELEMENTS(times_ss)			
				PLOTS,anytim(time_arr[times_ss[i]])*[1.,1.]-anytim(time_arr[0]),[2,100],/DATA,color=color
				PLOTS,anytim(time_arr[times_ss[i]]+dt*[-0.5,0.5])-anytim(time_arr[0]),[90,90],/DATA,color=color
				IF back_ss NE -1 THEN BEGIN
					PLOTS,anytim(time_arr[back_ss])*[1.,1.]-anytim(time_arr[0]),[2,100],/DATA,linestyle=1
					PLOTS,anytim(time_arr[back_ss]+dt*[-0.5,0.5])-anytim(time_arr[0]),[90,90],/DATA,linestyle=1
				ENDIF
			ENDFOR
		ENDIF ELSE !P.MULTI=[0]
		
		semical=spo->get(/sp_semi_cal)
		IF semical EQ 1 THEN ytit='photons' ELSE ytit='counts'
		ytit=ytit+' s!U-1!N cm!U-2!N keV!U-1!N'
				
		IF back_ss NE -1 THEN tit='Background-subtracted semi-calibrated spectrum' ELSE tit='Semi-calibrated spectrum, WITH background' 
		PLOT,ebin_arr,sp[*,times_ss[0]],/XLOG,/YLOG,/NODATA,tit=tit,xtit='[keV]',ytit=ytit,_extra=_extra			
		lowerleftcorner=CONVERT_COORD(10^[!X.CRANGE[0],!Y.CRANGE[0]],/DATA,/TO_DEVICE)
		FOR i=0,N_ELEMENTS(times_ss)-1 DO BEGIN
			color=!D.TABLE_SIZE-10-i*(!D.TABLE_SIZE-10)/N_ELEMENTS(times_ss)
			OPLOT,ebin_arr,sp[*,times_ss[i]],color=color
			XYOUTS,lowerleftcorner[0]+10,lowerleftcorner[1]+(i+2)*10,anytim(time_arr[times_ss[i]],/ECS),/DEV,color=color
		ENDFOR
		IF back_ss NE -1 THEN BEGIN
			OPLOT,ebin_arr,back_sp,linestyle=1
			XYOUTS,lowerleftcorner[0]+10,lowerleftcorner[1]+10,anytim(time_arr[back_ss],/ECS)+' (BACKGROUND)',/DEV
		ENDIF		
	;END GRAPHIC OUTPUT

END
