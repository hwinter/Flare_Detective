; This routine calculates the spectral index between ebands.

; 'machin' can either be a time_intv or a spectrum object
; if ebands is not specified, 25-40 keV is taken
; if backtime is not provided, no background subtraction occurs.
; time_intv should typically span 1 RHESSI rotation (event. an integer number, for increased sensitivity).
; event., si time_intv a un seul element, cherchez le spin period....



FUNCTION hessi_spectral_index, time_intv, backtime=backtime, eband=eband, sp_semi_cal=sp_semi_cal, LOUD=LOUD

	IF NOT KEYWORD_SET(eband) THEN eband=[25,40]
	
	seg_index_mask=[1,0,1,1,1,1,0,1,1,1,0,1,1,1,1,0,1,1]
	spo=hsi_spectrum()
	spo->set,time_range=time_intv
	spo->set,seg_index_mask=seg_index_mask,sp_energy_bin=1,sp_semi_cal=sp_semi_cal
	tmp=spo->getdata()
		
	ct_edges=spo->get(/ct_edges)
	ebins= ( ct_edges[0:N_ELEMENTS(ct_edges)-2] + ct_edges[1:*])/2.
	ss=WHERE(ebins GE eband[0])
	IF ss[0] EQ -1 THEN ebins_ss_beg=0 ELSE ebins_ss_beg=ss[0]
	ss=WHERE(ebins GE eband[1])
	IF ss[0] EQ -1 THEN ebins_ss_end=N_ELEMENTS(ebins)-1 ELSE ebins_ss_end=ss[0]

	sp=spo->getdata()
;;;;	sp=sp_struct.FLUX
;;;;	; should correct for livetime...
;;;;	esp=sp_struct.EFLUX
	
	IF KEYWORD_SET(backtime) THEN BEGIN
		spo->set,time_range=backtime
		back_sp_struct=spo->getdata()
		back_sp=back_sp_struct.FLUX
		; should correct for livetime...
		
		sp=sp-back_sp	;background-subtraction
		spo->set,time_range=time_intv
	ENDIF
	
	
	;NOW, we can work...
	wanted_ebins=ebins[ebins_ss_beg:ebins_ss_end]
	wanted_fluxes=sp[ebins_ss_beg:ebins_ss_end]	
;;;;	wanted_efluxes=esp[ebins_ss_beg:ebins_ss_end]

	;make LINFIT to A.E^(-gamma)
	res=LINFIT(alog10(wanted_ebins/50.),alog10(wanted_fluxes),CHISQ=chisq,SIGMA=sigma,YFIT=yfit)
;;;;	res=LINFIT(alog10(wanted_ebins/50.),alog10(wanted_fluxes),MEASURE_ERRORS=alog10(wanted_efluxes),CHISQ=chisq,SIGMA=sigma,YFIT=yfit)
	fit_fluxes=10^(yfit)
	fit_F50=10^(res[0])
	fit_gamma=-res[1]
	
	IF KEYWORD_SET(LOUD) THEN BEGIN
		PLOT,ebins,sp,/XLOG,/YLOG,psym=7
		OPLOT,wanted_ebins,fit_fluxes
		text='Photon spectral index: '+strn(fit_gamma,format='(f6.1)')+'   F_50 = '+strn(fit_F50)+' counts/s/cm!U2!N'
		XYOUTS,/NORM,0.3,0.9,text
	ENDIF

	RETURN,[fit_gamma,fit_F50]
END



