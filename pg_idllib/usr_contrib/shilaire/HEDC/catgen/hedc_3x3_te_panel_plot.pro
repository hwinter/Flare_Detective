
PRO hedc_3x3_te_panel_plot,imo,times,acctim,eband=eband,	$	
	dim=dim,charsize=charsize

	IF N_ELEMENTS(times) NE 3 THEN RETURN
	
	IF NOT KEYWORD_SET(dim) THEN dim=900
	IF NOT KEYWORD_SET(charsize) THEN BEGIN
		IF !D.NAME EQ 'Z' THEN charsize=1.0 ELSE charsize=1.2
	ENDIF
	IF NOT KEYWORD_SET(eband) THEN eband=[[3,12],[12,25],[25,50]]
	
	xmar=[0,1]
	ymar=[0,0]
	addxdim=50
	addydim=50
		
	hedc_win,dim,dim
	hessi_ct
	!P.MULTI=[0,3,3]

	obs_time_interval=imo->get(/obs_time_interval)
	t0=anytim(obs_time_interval(0))
	
	imo->set_no_screen_output
	fm = '(g12.3)'
	FOR i=0,2 DO BEGIN	
		FOR j=0,2 DO BEGIN
			tim=anytim(times(j))
				
			imo->set,energy_band=eband(*,i),time_range=anytim(tim)-t0+acctim*[-0.5,0.5]
			tmp=imo->getdata()
			tmpmap=make_hsi_map(imo)
			lowerleft=[tmpmap.xc-tmpmap.dx*N_ELEMENTS(tmpmap.data(*,0))/2,tmpmap.yc-tmpmap.dy*N_ELEMENTS(tmpmap.data(0,*))/2]

			n_event=imo->get(/binned_n_event)
			detindex=imo->get(/det_index_mask)

			total_events = strupcase (strtrim (string(total(n_event[where(detindex(0:8)),0]), format=fm),2))
			text = 'Total counts: ' + str_replace (total_events, 'E+00', 'E+0')
			plot_vel_map,tmpmap,xmar=xmar,ymar=ymar,/iso,/limb,xtitle='',ytitle='',/noax,/nolabel,title=''
			XYOUTS,lowerleft(0),lowerleft(1),/DATA,text, charsize=charsize
		ENDFOR
	ENDFOR			
	
	img1=TVRD()
	img2=BYTARR(dim+addxdim,dim+addydim)
	img2(addxdim:dim+addxdim-1,20:dim+19)=img1
	hedc_win,dim+addxdim,dim+addydim
	TV,img2
	
	info=imo->get()
	text=' DATE: '+anytim(times(2),/ECS,/date)
	text=text+'   Accumulation Time: '+STRN(acctim,format='(f6.1)')+' s'
	text=text+'   Image alg: '+info.IMAGE_ALGORITHM
	text=text+'   Detectors: '
	FOR i=0,8 DO text=text+strn(info.DET_INDEX_MASK(i))
	text=text+' '
	IF info.FRONT_SEGMENT NE 0 THEN text=text+'F' ELSE text=text+' '
	IF info.REAR_SEGMENT NE 0 THEN text=text+'R' ELSE text=text+' '
	text=text+'   FOV: '+strn(info.pixel_size(0)*info.image_dim(0))+'"X'+strn(info.pixel_size(1)*info.image_dim(1))+'"'
	
	XYOUTS,/DEV,addxdim,dim+addydim-13,text,charsize=charsize
	
	FOR i=0,2 DO BEGIN
		XYOUTS,/DEV,1,dim+addydim-i*dim/3-dim/10-20,strn(eband(0,i))+'-'+strn(eband(1,i)),charsize=charsize
		XYOUTS,/DEV,15,dim+addydim-i*dim/3-dim/10-30,'keV',charsize=charsize
		XYOUTS,/DEV,20+i*dim/3+dim/10,3,anytim(times(i),/ECS,/time),charsize=charsize
	ENDFOR

	;timestamp, charsize=charsize/2.	;,/bottom
	!P.MULTI=0
END





;======================================================================================
; from Kim's hsi_image_plot :
;
;det = control.det_index_mask
;a2d = reform (control.a2d_index_mask, 9, 3)
;front = control.front_segment
;rear = control.rear_segment
;enb = control.energy_band
;n_event = info.binned_n_event
;detector_list = hsi_coll_segment_list(det, a2d, front, rear, colls_used=colls_used)
; (...)
;fm = '(g12.3)'
;total_events = strupcase (strtrim (string(total(n_event[where(colls_used),0]), format=fm),2))
;total_events = 'Total counts: ' + str_replace (total_events, 'E+00', 'E+0')
; (...)
;legend, text, box=0, charsize=label_size,$
;                top_legend=top, bottom_legend=bottom, right_legend=right, left_legend=left, $
;                textcolor=textcolor
;======================================================================================


