;PSH 2003/02/07
;returns a list (STRING array) of all RHESSI flares above a certain threshold (peak GOES flux) (default is M-class, i.e. 10^-5 W/m^2/Hz), inside time_intv
;
; EXAMPLE: 
;	list=list_some_rhessi_flares(['2002/02/13','2003/02/18'])
;	wrt_ascii,list,'RHESSI_flares.txt'
;
; MODIFICATION HISTORY:
;	2003/02/19 : added keyword /STATES
;	2003/02/25 : added keyword /DISTANCE (from Sun center)
;


FUNCTION list_all_rhessi_flares_above_threshold, time_intv
	
	threshold=3e-6	;C3-class	
	list=-1 	
	flo=hsi_flare_list()

	nbr_days=CEIL((anytim(time_intv[1])-anytim(time_intv[0]))/86400.)
	;should work on a per day basis, as flare list struct have changed several times...
		
	FOR i=0L,nbr_days-1 DO BEGIN
		cur_intv=anytim(time_intv[0])+i*86400.+[0.,86399.]
		flo->set,obs_time=cur_intv
		fl=flo->getdata()
		IF datatype(fl) NE 'INT' THEN BEGIN
			FOR j=0,N_ELEMENTS(fl)-1 DO BEGIN
				IF ((fl[j].PEAK_TIME GE cur_intv[0]) AND (fl[j].PEAK_TIME LE cur_intv[1])) THEN BEGIN
					newdate=anytim(fl[j].PEAK_TIME,/ECS,/trunc)
					;find flare class, using GOES-8 3-second data.
					rd_goes,goestime,goesdata,trange=anytim([fl[j].START_TIME,fl[j].END_TIME],/yohkoh)	;,/goes8
					IF datatype(goesdata) NE 'UND' THEN BEGIN
						themax=MAX(goesdata[*,0])
						IF themax GE threshold THEN BEGIN
							newclass=togoes(themax)
							newligne=newdate+' '+newclass
							
							;states:
								oso=hsi_obs_summary()
								oso->set,obs_time=[fl[j].START_TIME,fl[j].END_TIME]
								flagdata_struct= oso->getdata(class_name='obs_summ_flag')
        							flagdata=flagdata_struct.FLAGS								
								OBJ_DESTROY,oso

								tmp=get_ss_changes(flagdata[14,*])	;14 is attenuator states
								newatten=strn(flagdata[14,0])
								IF N_ELEMENTS(tmp) GT 1 THEN BEGIN
									FOR k=1,N_ELEMENTS(tmp)-1 DO BEGIN
										newatten=newatten+strn(flagdata[14,tmp[k]])
									ENDFOR
								ENDIF
								newligne=newligne+'    '+newatten
								
								tmp=get_ss_changes(flagdata[19,*])	;19 is front decimation weight
								newitem=strn(flagdata[19,0])
								IF N_ELEMENTS(tmp) GT 1 THEN BEGIN
									FOR k=1,N_ELEMENTS(tmp)-1 DO BEGIN
										newitem=newitem+strn(flagdata[19,tmp[k]])
									ENDFOR
								ENDIF
								newligne=newligne+'   '+newitem
					
							;distance:
								SPAWN,'java -cp /global/hercules/users/shilaire/HEDC/util:/global/hercules/users/hedc/dm/classes/dm.jar:/global/hercules/users/hedc/dm/classes/sc_lib.jar query2 F04_HLE_DISTANCESUN DAT_HLE_ENDDATE ge "'+anytim(fl[j].START_TIME,/ECS,/trunc)+'" AND DAT_HLE_STARTDATE le "'+anytim(fl[j].END_TIME,/ECS,/trunc)+'"',res,err_res, exit_status=exit_status
								IF exit_status EQ 0 THEN newligne=newligne+'   '+res[0] ELSE newligne=newligne+'   Problem!'

							IF datatype(list) EQ 'INT' THEN list=newligne ELSE list=[list,newligne]
						ENDIF
					ENDIF
				ENDIF
			ENDFOR
		ENDIF
	ENDFOR

	OBJ_DESTROY,flo
	RETURN,list
END
