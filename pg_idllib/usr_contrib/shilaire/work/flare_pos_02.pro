


;TEST:
flo=hsi_flare_list()
flo->set,obs_time=['2002/09/01','2002/12/01']
fl=flo->getdata()
OBJ_DESTROY,flo
HEAP_GC

psh_win,3*256,256
hessi_ct
imgs='none'
FOR i=0L,N_ELEMENTS(fl)-1 DO BEGIN
	IF fl[i].PEAK_COUNTRATE LT 8. THEN GOTO,NEXTPLEASE
	IF fl[i].TOTAL_COUNTS LT 500 THEN GOTO,NEXTPLEASE
	
	flare_intv=anytim([fl[i].START_TIME,fl[ss[i]].END_TIME])
	flare_duration=fl[i].END_TIME-fl[i].START_TIME
;remove some more flares-------------------------
	IF flare_duration LT 8. THEN GOTO,NEXTPLEASE
	oso=hsi_obs_summary()
	oso->set,obs_time=anytim(fl[i].PEAK_TIME)+[0.,8.]
	flagdata_struct=oso->getdata(class='hsi_obs_summ_flag')	
	OBJ_DESTROY,oso
	IF flagdata_struct[0].FLAGS[24] NE 0 THEN GOTO,NEXTPLEASE
;------------------------------------------------	
	!P.MULTI=[0,3,1]
	pos=rhessi_find_flare_position(flare_intv,fl[i].PEAK_TIME,/LOUD,warning=warning,/FURTHER,time_intv=time_intv)

	; if things are apparently toast....
	IF N_ELEMENTS(pos) EQ 1 THEN BEGIN
		PLOT,[-1000.,1000.],[-1000.,1000.],xtit='',ytit='',tit='',xmar=[1,1],ymar=[1,1],xtickname=REPLICATE(' ',10),ytickname=REPLICATE(' ',10),/NODATA
		text='rhessi_find_flare.pro did not work for '+anytim(time_intv[0],/ECS)+' to '+anytim(time_intv[1],/ECS,/time)
		XYOUTS,/DATA,-950,100,text
	ENDIF ELSE BEGIN
		PLOTS,/DATA,[pos[0],pos[0]],[-1000,1000],linestyle=4
		PLOTS,/DATA,[-1000,1000],[pos[1],pos[1]],linestyle=4
		OPLOT,[pos[0]],[pos[1]],psym=-7		
	ENDELSE

	IF warning GT 0 THEN BEGIN
		text='Warning: '+strn(warning)
		XYOUTS,/DATA,-950,-950,text
	ENDIF

	;now, oplot the results from hedc_find_flare_pos.pro
	tmp=-1
	tmp=hedc_find_flare_pos(time_intv,/NOBREAK)	
	IF N_ELEMENTS(tmp) EQ 2 THEN BEGIN
		PLOTS,/data,[tmp[0],tmp[0]],[-1000,1000],linestyle=2
		PLOTS,/data,[-1000,1000],[tmp[1],tmp[1]],linestyle=2
	ENDIF ELSE BEGIN
		XYOUTS,/DATA,-950,-900,' Problem with hedc_find_flare_pos.pro' 
	ENDELSE	
	
	IF datatype(imgs) EQ 'STR' THEN imgs=TVRD() ELSE imgs=[[[imgs]],[[TVRD()]]]
	
	NEXTPLEASE:	
	HEAP_GC
ENDFOR

END
