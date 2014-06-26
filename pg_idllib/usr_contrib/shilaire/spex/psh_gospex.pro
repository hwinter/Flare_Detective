; /ALTERNATE: trying to fit using first power-law as 1.5 power-law below turnover energy...
;
;
;
; EXAMPLE:
;	psh_gospex,'Ebudget2/20020226/hsi_spectrum_20020226_102400.fits','Ebudget2/20020226/hsi_srm_20020226_102400.fits'
;



PRO psh_gospex,file1,dfile,ALTERNATE=ALTERNATE

	;apar=spex_current('apar')
	erange=[6,35]
	spex_proc,/cmode, input='f_model,f_vth_bpow'
	IF KEYWORD_SET(ALTERNATE) THEN BEGIN		
		start_apar=[1,1,3.7,1.5,15,3]	
		start_free=[1,1,1,0,1,1]
		spex_proc,/cmode, input='range_lo,1e-4,0.6,1e-10,1.,6.,1.'
		spex_proc,/cmode, input='range_hi,1000.,20.,1e10,12,1500,12'
	ENDIF ELSE BEGIN
		start_apar=[1,1,1,3,400,4]	
		start_free=[1,1,1,1,0,0]	
		spex_proc,/cmode, input='a_cutoff=[1.,1.5]'
	ENDELSE

	spex_proc,/cmode, input='data,hessi,front'
	spex_proc,/cmode, input='_1file,'+file1
	spex_proc,/cmode, input='dfile,'+dfile
;	spex_proc,/cmode, input='read_drm'
	spex_proc,/cmode, input='preview'
	spex_proc,/cmode, input='th_ytype,1'	
	spex_proc,/cmode, input='th_yrange,1e-4,1e2'	
	spex_proc,/cmode, input='graph'	
	
	tmp='apar=['+strn(start_apar[0])
	FOR i=1,5 DO tmp=tmp+','+strn(start_apar[i])
	tmp=tmp+']'
	spex_proc,/cmode, input=tmp

	tmp='free,'+strn(start_free[0])
	FOR i=1,5 DO tmp=tmp+','+strn(start_free[i])
	spex_proc,/cmode, input=tmp
	
	;spex_proc,/cmode, input='erange=[9,100]'	
	tmp='erange=['+strn(erange[0])+','+strn(erange[1])+']'
	spex_proc,/cmode, input=tmp
	
	spex_proc,/cmode, input='spyrange,0.01,1e6'
	spex_proc,/cmode, input='energy_bands,3,12,12,25,25,50,50,100'
	spex_proc,/cmode, input='eplot,1'	

	spex_proc,/cmode, input='graph'

	PRINT,'Enter [back_order], [background], select_interval, fit, photon,...'
	spex_proc
END
