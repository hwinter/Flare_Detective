; 'input' can be a time_intv OR a lco
;EXAMPLE:
;	draw_hsi_lc, '2002/09/01 '+['10:00:00','10:01:00'],charsize=2.0,xtit='',ymar=[1,1], title='Uncalibrated counts, all segments',ebands=[3,25,50,100,300,1000,20000],/YLOG
;


PRO draw_hsi_lc, input, timeres=timeres, ebands=ebands, segments=segments, _extra=_extra
	
	linecolors
	IF NOT KEYWORD_SET(ebands) THEN ebands=[3,12,25,50,100,300]
	
	IF datatype(input) NE 'OBJ' THEN BEGIN
		lco=hsi_lightcurve()
		lco->set,time_range=input
		IF KEYWORD_SET(timeres) THEN lco->set,ltc_time_res=timeres
		IF NOT KEYWORD_SET(segments) THEN lco->set,seg_index=BYTARR(18)+1B ELSE lco->set,seg_index=segments
	ENDIF ELSE BEGIN
		lco=input
		IF KEYWORD_SET(segments) THEN lco->set,seg_index=segments
	ENDELSE
	
	lco->set,ltc_energy_band=ebands
	lc=lco->getdata()
	taxis=lco->getdata(/xaxis)
	IF datatype(input) NE 'OBJ' THEN OBJ_DESTROY,lco
	IF lc[0] EQ -1 THEN RETURN
		
	n_ebands=N_ELEMENTS(lc[0,*])
	t0=anytim(taxis[0])
	themax=MAX(lc)
	themin=MIN(lc)
	IF ((themin EQ 0) AND (tag_exist(_extra,'YLOG'))) THEN themin=1.
	ytit='Counts  ('+strn(taxis[1]-taxis[0],format='(f5.3)')+' s bins)'
	IF NOT tag_exist(_extra,'ytitle') THEN _extra=add_tag(_extra,ytit,'ytitle')
	IF NOT tag_exist(_extra,'yrange') THEN utplot,taxis-t0,lc[*,0],t0,yrange=[themin,themax],color=2,_extra=_extra ELSE utplot,taxis-t0,lc[*,0],t0,color=2,_extra=_extra
	FOR i=1,n_ebands-1 DO BEGIN
		color=i+2
		outplot,taxis-t0,lc[*,i],color=color
	ENDFOR	

	FOR i=0,n_ebands-1 DO BEGIN
		color=i+2
		thetext=strn(ebands[i])+'-'+strn(ebands[i+1])+' keV'
		
		xpos=0.03*(taxis[N_ELEMENTS(taxis)-1]-t0)
		IF tag_exist(_extra,'YLOG') THEN BEGIN
			tmp=CONVERT_COORD(0,10^(!Y.CRANGE[1]),/DATA,/TO_DEVICE)
		ENDIF ELSE BEGIN		
			tmp=CONVERT_COORD(0,!Y.CRANGE[1],/DATA,/TO_DEVICE)
		ENDELSE
		tmp=CONVERT_COORD(0,tmp[1] -12*i -15,/DEVICE,/TO_DATA)
		ypos=tmp[1]
		
		XYOUTS,/DATA,xpos,ypos,color=color,thetext
	ENDFOR	
END
