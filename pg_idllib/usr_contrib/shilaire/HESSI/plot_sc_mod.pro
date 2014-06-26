; plots lightcurve for every subcollimator.


PRO plot_sc_mod,peaktim,REAR=REAR,eband=eband,Np=Np,Nr=Nr
	
	IF NOT KEYWORD_SET(Np) THEN Np=200.	; Np is number of desired bins.
	IF NOT KEYWORD_SET(Nr) THEN Nr=1.	; Nr is ratio of desired timebins vs. default timebins
	
	IF NOT KEYWORD_SET(eband) THEN eband=[12,25]
	IF KEYWORD_SET(REAR) THEN REAR=1 ELSE REAR=0
	IF !D.NAME eq 'Z' THEN charsize=1.5 ELSE charsize=1.8
		
	lco=hsi_lightcurve()
	lco->set,ltc_energy_band=eband	

	!P.MULTI=[0,3,3]
	FOR i=0,8 DO BEGIN
		seg_index=BYTARR(18)
		seg_index(i+9*REAR)=1
		lco->set,seg_index_mask=seg_index

		CASE i OF 
			0: BEGIN timres=Nr*0.001 & timrng=anytim(peaktim)+Np*timres*[-0.5,0.5] & END
			1: BEGIN timres=Nr*0.001 & timrng=anytim(peaktim)+Np*timres*[-0.5,0.5] & END
			2: BEGIN timres=Nr*0.002 & timrng=anytim(peaktim)+Np*timres*[-0.5,0.5] & END
			3: BEGIN timres=Nr*0.004 & timrng=anytim(peaktim)+Np*timres*[-0.5,0.5] & END
			4: BEGIN timres=Nr*0.008 & timrng=anytim(peaktim)+Np*timres*[-0.5,0.5] & END
			5: BEGIN timres=Nr*0.008 & timrng=anytim(peaktim)+Np*timres*[-0.5,0.5] & END
			6: BEGIN timres=Nr*0.016 & timrng=anytim(peaktim)+Np*timres*[-0.5,0.5] & END
			7: BEGIN timres=Nr*0.032 & timrng=anytim(peaktim)+Np*timres*[-0.5,0.5] & END
			8: BEGIN timres=Nr*0.064 & timrng=anytim(peaktim)+Np*timres*[-0.5,0.5] & END	
		ENDCASE

		lco->set,time_range=timrng , ltc_time_res=timres
		lco->plot,charsize=charsize,mar=0.1,title='',xmar=[5,2],ymar=[2,1],xtitle=''
	ENDFOR		
	!P.MULTI=0
	OBJ_DESTROY,lco
END


