

flo=hsi_flare_list()
flo->set,obs_time=['2002/10/01','2002/11/01']
fl=flo->getdata()
OBJ_DESTROY,flo
HEAP_GC

ss=WHERE(fl.PEAK_COUNTRATE GT 2000.)
ss1=WHERE(fl.PEAK_COUNTRATE GT 50.)
ss2=WHERE(fl.TOTAL_COUNTS GT 10000)
ss=-1
FOR i=0,N_ELEMENTS(ss1)-1 DO BEGIN
	tmp=WHERE(ss2 EQ ss1[i])
	IF tmp[0] NE -1 THEN IF ss[0] EQ -1 THEN ss=ss1[i] ELSE ss=[ss,ss1[i]]
ENDFOR


psh_win,3*256,256
hessi_ct
imgs='none'
FOR i=0L,N_ELEMENTS(ss)-1 DO BEGIN
	flare_intv=anytim([fl[ss[i]].START_TIME,fl[ss[i]].END_TIME])
	flare_duration=fl[ss[i]].END_TIME-fl[ss[i]].START_TIME
IF flare_duration LE 8. THEN BREAK
IF fl[ss[i]].FLAGS[24] NE 0 THEN BREAK	;no particle_rate flag wanted...
	wished_time=anytim(fl[ss[i]].PEAK_TIME)
	
time_intvs=hedc_get_img_intv(flare_intv,minaccumtime=13.,nbrcounts=10000,maxaccumtime=60.,maxintv=3)
IF N_ELEMENTS(time_intvs[0,*]) GT 1 THEN time_intv=time_intvs[*,1] ELSE time_intv=time_intvs[*,0]
;	IF flare_duration GE 75. THEN time_intv=rhessi_return_nice_intv(flare_intv, wished_time, min_wished_spin_periods=14, max_spin_periods=15) $
;	ELSE time_intv=rhessi_return_nice_intv(flare_intv, wished_time, min_wished_spin_periods=1)
	
	first_time_intv=time_intv
	pos=rhessi_find_flare_position(time_intv,/LOUD,warning=warning)

;	;if an error (mostly 'cause of *&#!@% roll solution...) occurs: try changing the time...
;	IF N_ELEMENTS(pos) EQ 1 THEN BEGIN
;		wished_time=(fl[ss[i]].START_TIME + fl[ss[i]].PEAK_TIME)/2.
;				
;		IF flare_duration GE 60. THEN time_intv=rhessi_return_nice_intv(flare_intv, wished_time, min_wished_spin_periods=12, max_spin_periods=13) $
;		ELSE time_intv=rhessi_return_nice_intv(flare_intv, wished_time, min_wished_spin_periods=1)
;		pos=rhessi_find_flare_position(time_intv,/LOUD,warning=warning)		
;	ENDIF	
;	;if a warning level is above 0, redo with bigger time ranges...
;	IF warning GT 0 THEN BEGIN 
;		time_intv=rhessi_return_nice_intv(flare_intv+[-90.,90.], wished_time, min_wished_spin_periods=24, max_spin_periods=48)
;		pos=rhessi_find_flare_position(time_intv,/LOUD,warning=warning)		
;	ENDIF

	; if things are apparently toast....
	IF N_ELEMENTS(pos) EQ 1 THEN BEGIN
		PLOT,[-1000.,1000.],[-1000.,1000.],xtit='',ytit='',tit='',xmar=[1,1],ymar=[1,1],xtickname=REPLICATE(' ',10),ytickname=REPLICATE(' ',10),/NODATA
		text='rhessi_find_flare.pro did not work for '+anytim(time_intv[0],/ECS)+' to '+anytim(time_intv[1],/ECS,/time)
		XYOUTS,/DATA,-950,100,text
	ENDIF
	IF warning GT 0 THEN BEGIN
		text='Warning: '+strn(warning)
		XYOUTS,/DATA,-950,-950,text
	ENDIF
	;now, oplot the results from 
	tmp=hedc_find_flare_pos(first_time_intv,/NOBREAK)
	IF N_ELEMENTS(tmp) EQ 2 THEN BEGIN
		PLOTS,/data,[tmp[0],tmp[0]],[-1000,1000],linestyle=2
		PLOTS,/data,[-1000,1000],[tmp[1],tmp[1]],linestyle=2			
	ENDIF ELSE BEGIN
		XYOUTS,/DATA,-950,-900,' Problem with hedc_find_flare_pos.pro' 
	ENDELSE	
	
	IF datatype(imgs) EQ 'STR' THEN imgs=TVRD() ELSE imgs=[[[imgs]],[[TVRD()]]]
HEAP_GC
ENDFOR

END


