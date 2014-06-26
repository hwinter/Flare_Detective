; EXAMPLE:
;	plot_spexfitdata, 'Ebudget2/20020220/fastspexdata20030717_175213.fits', /LC
;

PRO plot_spexfitdata, fil, LC=LC, ENERGY=ENERGY, VOLUME=VOLUME, PS=PS

	clear_utplot
	bla=mrdfits(fil,1)
	valid_ss=WHERE(bla.fitparams[0,*] GE 0)
	
	time_intv=[bla.times[valid_ss[0]],bla.times[valid_ss[N_ELEMENTS(valid_ss)-1]]]
	IF KEYWORD_SET(PS) THEN BEGIN
		charsize=1.0
		old_device=!D.NAME
		set_plot,'PS'
	ENDIF ELSE BEGIN
		psh_win,512,900
		charsize=2.0
	ENDELSE
	!P.MULTI=[0,1,6+KEYWORD_SET(LC)+2*KEYWORD_SET(ENERGY)]
;-------------------------------------------------------------
	FOR i=0,6 DO BEGIN
		CASE i OF
			0:ytit='EM !C[10!U49!N cm!U-3!N]'
			1:ytit='T [keV]'
			2:ytit='F!D50!N !C[ph s!U-1!N cm!U-2!N keV!U-1!N]'
			3:ytit='!7c!3!D1!N'
			6:ytit='Low-E cutoff !C[keV]		
			ELSE:ytit=''		
		ENDCASE
		IF ytit NE '' THEN utplot,bla.times[valid_ss],bla.fitparams[i,valid_ss],ytit=ytit,tit='',xtit='',xmar=[8,1],ymar=[0,1],charsize=charsize,xtickNAME=REPLICATE(' ',10)	;,yr=[0.,MEAN(bla.fitparams[i,valid_ss])+STDDEV(bla.fitparams[i,valid_ss])]
	ENDFOR
		utplot,bla.times[valid_ss],bla.fitchisq[valid_ss],ytit='!7V!U2!N!3',xtit='',xmar=[8,1],ymar=[2,1],charsize=charsize
	IF KEYWORD_SET(LC) THEN BEGIN
		oso=hsi_obs_summary()
		oso->set,obs_time_interval=!X.CRANGE
		rates_struct=oso->getdata()
		rates=rates_struct.COUNTRATE 
		os_times=oso->getdata(/time)
		OBJ_DESTROY,oso
		themax=MAX(rates)
		IF KEYWORD_SET(PS) THEN utplot,os_times,rates[0,*],yr=[0,themax],ytit='Countrates !C[cts/s/det]',tit='',xtit='',xmar=[8,1],ymar=[2,0],charsize=charsize ELSE utplot,os_times,rates[0,*],yr=[0,themax],color=1,ytit='Countrates [cts/s/det]',tit='',xtit='',xmar=[8,1],ymar=[2,0],charsize=charsize
		IF KEYWORD_SET(PS) THEN plot_label,[0.025,-1],'3-6 keV',linestyle=1,/DEV,charsize=0.5 ELSE plot_label,[0.05,-1],'3-6 keV',color=1,/DEV,/NOLINE
		FOR i=1,4 DO BEGIN
			IF KEYWORD_SET(PS) THEN outplot,os_times,rates[i,*],linestyle=i+1 ELSE outplot,os_times,rates[i,*],color=i+1
			CASE i OF
				1:text='6-12 keV'
				2:text='12-25 keV'
				3:text='25-50 keV'
				4:text='50-100 keV'
			ENDCASE
			IF KEYWORD_SET(PS) THEN plot_label,[0.025,-i-1],text,linestyle=i+1,/DEV,charsize=0.5 ELSE plot_label,[0.05,-i-1],text,color=i+1,/DEV,/NOLINE
		ENDFOR
	ENDIF
	IF KEYWORD_SET(ENERGY) THEN BEGIN
	;kinetic power
		g_obs=bla.fitparams[3,valid_ss[0]]
		Aph_obs=bla.fitparams[2,valid_ss[0]]
		Ek=bla.fitparams[6,valid_ss[0]]
		power=nonthermal_power(g_obs,Aph_obs,Ek)
		FOR i=1,N_ELEMENTS(valid_ss)-1 DO BEGIN
			g_obs=bla.fitparams[3,valid_ss[i]]
			Aph_obs=bla.fitparams[2,valid_ss[i]]
			Ek=bla.fitparams[6,valid_ss[i]]
			power=[power,nonthermal_power(g_obs,Aph_obs,Ek)]
		ENDFOR
		utplot,bla.times[valid_ss],power,ytit='Power [erg/s]',charsize=charsize,xmar=[8,1],ymar=[1,0],/YLOG,yr=[1e27,1e31],xtit='',xtickNAME=REPLICATE(' ',10)

	;cumulative kinetic power
		Ekin=power
		FOR i=0L,N_ELEMENTS(power)-1 DO Ekin[i]=TOTAL(power[0:i])*(bla.times[1]-bla.times[0])
		utplot,bla.times[valid_ss],Ekin,ytit='[erg]',charsize=charsize,xmar=[8,1],ymar=[1,0],/YLOG,xtit='',xtickNAME=REPLICATE(' ',10),yr=[1e28,1e32]

	;thermal energy (RHESSI)
	;2002/02/26 chromospheric source:	
		;Eth=3*1.38e-16*REFORM(bla.fitparams[1,valid_ss])*11.594e6*sqrt(REFORM(bla.fitparams[0,valid_ss])*1e49*3e25)	; in reality, for 2002/02/20 : 2.3e26
		Eth=8.314e28*REFORM(bla.fitparams[1,valid_ss])*sqrt(REFORM(bla.fitparams[0,valid_ss]))
		IF NOT KEYWORD_SET(VOLUME) THEN BEGIN
			outplot,bla.times[valid_ss],Eth,color=1
		ENDIF
	;2002/02/20 loop source:
		IF NOT KEYWORD_SET(VOLUME) THEN Eth=Eth*sqrt(1.2e27/3e25) ELSE Eth=Eth*sqrt(VOLUME/3e25)
		IF KEYWORD_SET(PS) THEN BEGIN
			outplot,bla.times[valid_ss],Eth,linestyle=2 
			plot_label,[0.025,-1],'cumulative non-thermal energy',linestyle=0,/DEV,charsize=0.5
			plot_label,[0.025,-2],'thermal energy',linestyle=1,/DEV,charsize=0.5
		ENDIF ELSE BEGIN
			outplot,bla.times[valid_ss],Eth,color=2
			plot_label,[0.05,-1],'cumulative non-thermal energy',/DEV
			plot_label,[0.05,-2],'thermal energy',color=2,/DEV
		ENDELSE
		
	ENDIF

	IF KEYWORD_SET(PS) THEN BEGIN
		DEVICE,/CLOSE
		set_plot,old_device
	ENDIF
END





