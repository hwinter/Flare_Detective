PRO hedc_3x3_sc_panel_plot,imo,peaktim,acctim,	$	
	dim=dim,showsc=showsc,eband=eband,charsize=charsize
	
	
	IF NOT KEYWORD_SET(dim) THEN dim=900
	IF NOT KEYWORD_SET(showsc) THEN showsc=[1,1,1,1,1,1,1,1,1]
	IF NOT KEYWORD_SET(eband) THEN eband=[12,25]
	IF NOT KEYWORD_SET(charsize) THEN charsize=1.5
	
	xmar=[1,1]
	ymar=[1,2]
	
	hedc_win,dim,dim
	hessi_ct
	!P.MULTI=[0,3,3]

	obs_time_interval=imo->get(/obs_time_interval)
	t0=anytim(obs_time_interval(0))

	imo->set,time_range=anytim(peaktim)-t0+acctim*[-0.5,0.5],energy_band=eband
	imo->set_no_screen_output

	FOR i=0L,8 DO BEGIN	
		IF showsc(i) NE 0 THEN BEGIN
			tmp=BYTARR(9)
			tmp(i)=1B
			imo->set,det_index_mask=tmp
			tmpmap=make_hsi_map(imo)
			title=anytim(anytim(peaktim)-0.5*acctim,/ECS,/trunc,/time_only)+' ,'+STRN(acctim,format='(f6.1)')+'s., '+STRN(eband(0))+'-'+STRN(eband(1))+'keV ,SC: '+STRN(i+1)
			plot_vel_map,tmpmap,xmar=xmar,ymar=ymar,/iso,/limb,xtitle='',ytitle='',charsize=charsiz,/nolabel,title=title
		ENDIF ELSE BEGIN
			PLOT,[0,1],[0,1],color=0
		ENDELSE
	ENDFOR
	!P.MULTI=0
END


