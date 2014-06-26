; plots lightcurve for every subcollimator.


PRO plot_sc_lc,time_rng,ltc_time_res=ltc_time_res,REAR=REAR,eband=eband
	IF NOT KEYWORD_SET(ltc_time_res) THEN ltc_time_res=0.1
	IF NOT KEYWORD_SET(eband) THEN eband=[6,50]
	IF KEYWORD_SET(REAR) THEN REAR=1 ELSE REAR=0
	IF !.NAME eq 'Z' THEN charsize=1.5 ELSE charsize=1.8
		
	lco=hsi_lightcurve()
	lco->set,time_range=time_rng,ltc_time_res=ltc_time_res,ltc_energy_band=eband

	!P.MULTI=[0,3,3]
	FOR i=0,8 DO BEGIN
		seg_index=BYTARR(18)
		seg_index(i+9*REAR)=1
		lco->set,seg_index_mask=seg_index
		lco->plot,charsize=charsize,mar=0.1,title='',xmar=[5,2],ymar=[2,1],xtitle=''
	ENDFOR		
	!P.MULTI=0
	OBJ_DESTROY,lco
END


