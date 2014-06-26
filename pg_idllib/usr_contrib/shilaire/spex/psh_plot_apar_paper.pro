

PRO psh_plot_apar_paper, PS=PS, GOES=GOES, V=V, file=file, CREATEFILE=CREATEFILE, L=L, kinkOKtime=kinkOKtime
	;assumes I'm using the `f_vth_bpow' model...

IF NOT KEYWORD_SET(V) THEN V=1e27
IF KEYWORD_SET(PS) THEN BEGIN
	old_device=!D.NAME
	SET_PLOT,'PS'
	charsize=1.5
	device,/PORTRAIT
	device,XSIZE=18,YSIZE=24,YOFFSET=3

ENDIF ELSE charsize=2.0

IF ((KEYWORD_SET(file)) AND (NOT KEYWORD_SET(CREATEFILE))) THEN BEGIN 
;getting the data from file...
	data=mrdfits(file,1)
	chi2=data.chi2
	fitpar=data.fitpar
	fitsig=data.fitsig
	ut=data.ut
	uts=data.uts
	iselect=data.iselect
	IF tag_exist(data,'power_corr') THEN power_corr=data.power_corr
ENDIF ELSE BEGIN
;getting the data after spex fitting...	or from file...
	chi2=spex_current('chi')
	fitpar=spex_current('apar_arr')
		fitpar[2,*]=(fitpar[4,*]/50.)^(fitpar[5,*]-fitpar[3,*])*fitpar[2,*]
	fitsig=spex_current('apar_sigma')
		fitsig[2,*]=(fitpar[4,*]/50.)^(fitpar[5,*]-fitpar[3,*])*fitsig[2,*]		
	ut=spex_current('ut')
	uts=spex_current('uts')
	IF anytim(uts) LT anytim('2002/02/05') THEN uts=file2time(spex_current('_1file'),/ECS)
	iselect=spex_current('iselect')
ENDELSE

	n_intvs=N_ELEMENTS(chi2)
	times=REFORM(anytim(uts,/date) + 0.5*(ut[0,iselect[0,*]]+ut[1,iselect[1,*]]))
	obs_time_intv=anytim(uts,/date)+anytim([ut[0,iselect[0,0]],ut[1,iselect[1,n_intvs-1]]])

;now plotting it...
!P.MULTI=[0,1,8]
clear_utplot
psym=-4
;-------------------------------------------------------------
;LC
		oso=hsi_obs_summary()
		oso->set,obs_time_interval=obs_time_intv
		rates_struct=oso->getdata()
		rates=rates_struct.COUNTRATE 
		os_times=oso->getdata(/time)
		OBJ_DESTROY,oso
				
		rates1=TOTAL(rates[0:1,*],1)	;3-12
		rates2=REFORM(rates[2,*])	;12-25
		rates3=TOTAL(rates[3:5,*],1)	;25-300
		
		theminmax=minmax([rates1,rates2,rates3])
		IF KEYWORD_SET(PS) THEN utplot,os_times,rates1,yr=theminmax,/YLOG,ytit='Countrates !C[cts/s/det]',tit=anytim(obs_time_intv[0],/date,/ECS)+'  !7D!3t='+strn(times[N_ELEMENTS(times)-1]-times[0],format='(f10.1)')+' s',xtit='',xmar=[8,1],ymar=[0,0],charsize=charsize,XTICKNAME=REPLICATE(' ',10) ELSE utplot,os_times,rates1,yr=theminmax,/YLOG,color=2,ytit='Countrates !C[cts/s/det]',tit=anytim(obs_time_intv[0],/date,/ECS)+'  !7D!3t='+strn(times[N_ELEMENTS(times)-1]-times[0],format='(f10.1)'),xtit='',xmar=[8,1],ymar=[2,0],charsize=charsize
		IF KEYWORD_SET(PS) THEN plot_label,[0.025,-1],'3-12 keV',/DEV,charsize=charsize/2. ELSE plot_label,[0.05,-1],'3-12 keV',color=2,/DEV,/NOLINE
		
		IF KEYWORD_SET(PS) THEN outplot,os_times,rates2,linestyle=1 ELSE outplot,os_times,rates2,color=3
		IF KEYWORD_SET(PS) THEN plot_label,[0.025,-2],'12-25 keV',linestyle=1,/DEV,charsize=charsize/2. ELSE plot_label,[0.05,-2],'12-25 keV',color=3,/DEV,/NOLINE

		IF KEYWORD_SET(PS) THEN outplot,os_times,rates3,linestyle=2 ELSE outplot,os_times,rates3,color=5
		IF KEYWORD_SET(PS) THEN plot_label,[0.025,-3],'25-300 keV',linestyle=2,/DEV,charsize=charsize/2. ELSE plot_label,[0.05,-3],'25-300 keV',color=5,/DEV,/NOLINE
;-------------------------------------------------------------
IF KEYWORD_SET(GOES) THEN BEGIN
	;keyword is actually GOES background time... ex: '2003/06/10 '+['02:41:30','02:42:30']
	rd_goes,goes_times,goes_data,trange=anytim( obs_time_intv ,/yoh)
        rd_goes,bgoes_times,bgoes_data,trange=anytim(GOES,/yoh)
        
        lo=goes_data[*,0]-MEAN(bgoes_data[*,0])
        hi=goes_data[*,1]-MEAN(bgoes_data[*,1])
        
        goes_tem,lo,hi,goes_t,goes_em
ENDIF
;-------------------------------------------------------------
	FOR i=0,5 DO BEGIN
		CASE i OF
			0:ytit='EM !C[10!U49!N cm!U-3!N]'
			1:ytit='T [keV]'
			2:ytit='F!D50!N !C[ph s!U-1!N cm!U-2!N keV!U-1!N]'
			5:ytit='!7c!3!D1!N'
			4:ytit='!7e!3!DCO!N [keV]'	;ytit='Low-E cutoff !C[keV]		
			ELSE:ytit=''		
		ENDCASE
		IF ytit NE '' THEN utplot,times,fitpar[i,*],ytit=ytit,tit='',xtit='',xmar=[8,1],ymar=[0,0],charsize=charsize,xtickNAME=REPLICATE(' ',10),psym=psym
		IF i EQ 0 AND KEYWORD_SET(GOES) THEN BEGIN
			outplot,goes_times,goes_em,linestyle=2
			plot_label,/DEV,[0.025,-1],'RHESSI',charsize=charsize/2
			plot_label,/DEV,[0.025,-2],'GOES',linestyle=2,charsize=charsize/2		
		ENDIF
		IF i EQ 1 AND KEYWORD_SET(GOES) THEN BEGIN
			outplot,goes_times,goes_t/11.594,linestyle=2
			plot_label,/DEV,[0.025,2],'RHESSI',charsize=charsize/2
			plot_label,/DEV,[0.025,1],'GOES',linestyle=2,charsize=charsize/2		
		ENDIF
		IF ((i EQ 4) AND (KEYWORD_SET(kinkOKtime))) THEN BEGIN
			PLOTS,/DATA,anytim(kinkOKtime),[3,3],linestyle=5,thick=3
		ENDIF
	ENDFOR
;chi^2:
;		utplot,times,chi2,ytit='!7V!U2!N!3',xtit='',xmar=[8,1],ymar=[2,0],charsize=charsize,psym=psym	;,XTICKNAME=REPLICATE(' ',10)
;-------------------------------------------------------------
	;kinetic power
		power=nonthermal_power(fitpar[5,*],fitpar[2,*],fitpar[4,*])
		power=REFORM(power)
		;utplot,times,power,ytit='Non-thermal !Cpower [erg/s]',charsize=charsize,xmar=[8,1],ymar=[0,0],/YLOG,yr=[1e27,1e31],xtit='',XTICKNAME=REPLICATE(' ',10),psym=psym
		;plot_label,/DEV,[0.03,-1],'Cutoff, uncorrected',psym=psym

		powerTO=nonthermal_power(fitpar[5,*],fitpar[2,*],fitpar[4,*],/TURNOVER)
		powerTO=REFORM(powerTO)
		;outplot,times,powerTO,linestyle=1,psym=psym
		;plot_label,/DEV,[0.03,-2],'Turnover, uncorrected',linestyle=1,psym=psym

		; if it already exists, means it was saved on file: NO NEED to recompute this lengthy thing!!!
		IF NOT EXIST(power_corr) THEN power_corr=nonthermal_power_correction(fitpar[5,*]+1,fitpar[4,*],[10,35],/STD,/TOGETHER)
	
		utplot,times,power*power_corr[0,*],ytit='Non-thermal !Cpower [erg/s]',charsize=charsize,xmar=[8,1],ymar=[0,0],/YLOG,xtit='',XTICKNAME=REPLICATE(' ',10)	;,yr=[1e27,1e31]
		;outplot,times,power*power_corr[0,*],linestyle=0
		plot_label,/DEV,[0.03,2],'Cutoff model',linestyle=0
		outplot,times,powerTO*power_corr[1,*],linestyle=1
		plot_label,/DEV,[0.03,1],'Turnover model',linestyle=1
		
	;cumulative non-thermal kinetic energy
		Ekin=power
		EkinTO=Ekin
		Ekin_corr=Ekin
		EkinTO_corr=Ekin
		
		Ekin[0]=power[0]*(ut[1,iselect[1,0]]-ut[0,iselect[0,0]])
		EkinTO[0]=powerTO[0]*(ut[1,iselect[1,0]]-ut[0,iselect[0,0]])

		Ekin_corr[0]=Ekin[0]*power_corr[0,0]
		EkinTO_corr[0]=EkinTO[0]*power_corr[1,0]
		
		FOR i=1L,N_ELEMENTS(power)-1 DO BEGIN
			Ekin[i]=Ekin[i-1] + power[i]*(ut[1,iselect[1,i]]-ut[0,iselect[0,i]])
			EkinTO[i]=EkinTO[i-1] + powerTO[i]*(ut[1,iselect[1,i]]-ut[0,iselect[0,i]])
			Ekin_corr[i]=Ekin_corr[i-1] + power[i]*(ut[1,iselect[1,i]]-ut[0,iselect[0,i]]) * power_corr[0,i]
			EkinTO_corr[i]=EkinTO_corr[i-1] + powerTO[i]*(ut[1,iselect[1,i]]-ut[0,iselect[0,i]]) * power_corr[1,i]				
		ENDFOR
		PRINT,'..............Total non-thermal energy: '
		PRINT,'........Cutoff, uncorrected: '+strn(Ekin[n_intvs-1])+' ergs.'
		PRINT,'........Turnover, uncorrected: '+strn(EkinTO[n_intvs-1])+' ergs.'
		PRINT,'........Cutoff, corrected: '+strn(Ekin_corr[n_intvs-1])+' ergs.'
		PRINT,'........Turnover, corrected: '+strn(EkinTO_corr[n_intvs-1])+' ergs.'
		
	;thermal energy (RHESSI & GOES)
		;Eth=3*1.38e-16*T*11.594e6*sqrt(EM*1e49*V)
		Eth=1.5179e16 * fitpar[1,*] * sqrt(fitpar[0,*]*DOUBLE(V))	
		Eth=REFORM(Eth)
		goes_Eth=1.5179e16 * goes_t/11.594 * sqrt(goes_em*DOUBLE(V))
		goes_Eth=REFORM(goes_Eth)
		PRINT,'..............Additional thermal energy (RHESSI/GOES): '+strn(Eth[n_intvs-1]-Eth[0])+'/'+strn(goes_Eth[N_ELEMENTS(goes_Eth)-1]-goes_Eth[0])+' ergs.'
	
	;plotting the whole business...
		yrng=minmax([Ekin,EkinTO,Eth,goes_Eth,Ekin_corr,EkinTO_corr])

		;utplot,times,Ekin,ytit='Energies !C[erg]',charsize=charsize,xmar=[8,1],ymar=[0,0],/YLOG,xtit='',yr=yrng,psym=psym	;,XTICKNAME=REPLICATE(' ',10)	;,yr=minmax([Ekin,Eth,goes_Eth])
		;plot_label,/DEV,[0.025,-1],'EkinCO,uncorr',charsize=charsize/2,psym=psym
		;outplot,times,EkinTO,linestyle=1,psym=psym
		;plot_label,/DEV,[0.025,-2],'EkinTO,uncorr',charsize=charsize/2,linestyle=1,psym=psym

		;outplot,times,Ekin_corr,linestyle=0
		utplot,times,Ekin_corr,ytit='Energies !C[erg]',charsize=charsize,xmar=[8,1],ymar=[0,0],/YLOG,xtit=''	;,yr=yrng,psym=psym	;,XTICKNAME=REPLICATE(' ',10)	;,yr=minmax([Ekin,Eth,goes_Eth])
		plot_label,/DEV,[0.55,4],'Non-thermal (cutoff model)',charsize=charsize/2,linestyle=0
		outplot,times,EkinTO_corr,linestyle=1
		plot_label,/DEV,[0.55,3],'Non-thermal (turnover model)',charsize=charsize/2,linestyle=1

		outplot,times,Eth,linestyle=2
		plot_label,/DEV,[0.55,2],'thermal (RHESSI)',linestyle=2,charsize=charsize/2
		outplot,goes_times,goes_Eth,linestyle=3
		plot_label,/DEV,[0.55,1],'thermal (GOES)',linestyle=3,charsize=charsize/2	

	
	;PRINTING OUT some other useful values...
		PRINT,'...........................................................................'
		PRINT,'Deltat= '+strn(times[N_ELEMENTS(times)-1]-times[0])+' s.'
		PRINT,'Non-thermal energies:'
		PRINT,' Ratio TO/CO (uncorrected): '+strn(EkinTO[n_intvs-1]/Ekin[n_intvs-1],format='(f10.3)')
		;plot_label,/DEV,/NOLINE,[0.6,2.3],' Ratio TO/CO (uncorr): '+strn(EkinTO[n_intvs-1]/Ekin[n_intvs-1],format='(f10.3)')
		PRINT,' Ratio TO/CO (corrected): '+strn(EkinTO_corr[n_intvs-1]/Ekin_corr[n_intvs-1],format='(f10.3)')
		;plot_label,/DEV,/NOLINE,[0.6,1.3],' Ratio TO/CO (corr): '+strn(EkinTO_corr[n_intvs-1]/Ekin_corr[n_intvs-1],format='(f10.3)')
		PRINT,' Ratio TO (corr)/Eth(RHESSI): '+strn( EkinTO_corr[n_intvs-1]/Eth[n_intvs-1] ,format='(f10.3)') 
		;plot_label,/DEV,/NOLINE,[0.2,0.3],'Ratio TO (corr)/[!7D!3Eth|Eth,f] (RHESSI):'+strn( EkinTO_corr[n_intvs-1]/(Eth[n_intvs-1]-Eth[0]),format='(f10.3)')+'|'+strn( EkinTO_corr[n_intvs-1]/Eth[n_intvs-1],format='(f10.3)')+'  GOES:'+strn( EkinTO_corr[n_intvs-1]/(goes_Eth[N_ELEMENTS(goes_Eth)-1]-goes_Eth[0]),format='(f10.3)')+'|'+strn( EkinTO_corr[n_intvs-1]/goes_Eth[N_ELEMENTS(goes_Eth)-1],format='(f10.3)')
	
!P.MULTI=0
;---------------------------------------------------------------------------------------------------------------------------------------------
;some add. info.
IF KEYWORD_SET(L) THEN BEGIN
;	PRINT,'Initial radiative cooling down time [s]: '+strn()
;	PRINT,'Initial ratio heat/rad: '+STRN(psh_rad2cond_cooling, T, n, L)
ENDIF
;---------------------------------------------------------------------------------------------------------------------------------------------

IF KEYWORD_SET(PS) THEN BEGIN
	DEVICE,/CLOSE
	SET_PLOT,old_device
ENDIF
END

