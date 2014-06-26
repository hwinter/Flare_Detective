;EXAMPLE:
;
;	flarelistbrowser,['2003/06/01','2003/06/02']	
;


PRO flarelistbrowser,time_intv

	flo=hsi_flare_list()
	flo->set,obs_time_interval=time_intv
	fl=flo->getdata()
	info=flo->get()
	OBJ_DESTROY,flo
	
	nflares=N_ELEMENTS(fl)
	i=0L
	ENDIT=0
	
	WHILE ENDIT EQ 0 DO BEGIN
		PRINT,'Start/Peak/End times: '+anytim(fl[i].START_TIME,/ECS)+' / '+anytim(fl[i].PEAK_TIME,/ECS)+' / '+anytim(fl[i].END_TIME,/ECS)	
		PRINT,'Back time: [ '+anytim(fl[i].BCK_TIME[0],/ECS)+' , '+anytim(fl[i].BCK_TIME[1],/ECS)+' ]'
		PRINT,'Image time: [ '+anytim(fl[i].IMAGE_TIME[0],/ECS)+' , '+anytim(fl[i].IMAGE_TIME[1],/ECS)+' ]'
		PRINT,'Energy range found: ['+strn(fl[i].ENERGY_RANGE_FOUND[0])+','+strn(fl[i].ENERGY_RANGE_FOUND[1])+']'
		PRINT,'Energy high: ['+strn(fl[i].ENERGY_HI[0])+','+strn(fl[i].ENERGY_HI[1])+']'
		PRINT,'Peak countrate:	'+strn(fl[i].PEAK_COUNTRATE)
		PRINT,'BCK countrate:	'+strn(fl[i].BCK_COUNTRATE)
		PRINT,'Total counts:	'+strn(fl[i].TOTAL_COUNTS)
		PRINT,'Position: ['+strn(fl[i].POSITION[0])+','+strn(fl[i].POSITION[1])+']'
		PRINT,'Non-zero flags: '
		bla=WHERE(fl[i].FLAGS NE 0)
		IF bla[0] NE -1 THEN PRINT,info.flag_ids[bla]
				

		tmp=GET_KBRD(1)
		IF tmp EQ STRING(32B) THEN i=i+1
		IF tmp EQ 'q' THEN ENDIT=1
		IF tmp EQ 's' THEN STOP
		IF tmp EQ 'b' THEN i=i-1
		IF i LT 0 THEN i=nflares
		IF tmp EQ 'o' THEN obs_summ_page,/GOES,[fl[i].START_TIME-300.,fl[i].END_TIME+300.]
		IF tmp EQ 'p' THEN BEGIN
			psh_win,512
			rhessi_particle_rates,[fl[i].START_TIME-300.,fl[i].END_TIME+300.]
		ENDIF
		PRINT,'----------------------------------------------------------------------------------------'
	ENDWHILE
END
