;this script will look for all HLEs in the HEDC database, and put the corresponding
;flarelist ID in the I10_HLE_RESERVE1 field.



PRO hedc_dbmod_flarelist, time_intv
	time_intv=anytim(time_intv,/date_only)
	ndays=CEIL((time_intv[1]-time_intv[0])/86400d) > 1
	flo = OBJ_NEW('hsi_flare_list')
	
	FOR i=0L,ndays-1 DO BEGIN
		cur_intv=time_intv[0]+i*86400+[0,86400]
		HLElist=''
		
		;get all events for that day: S12_HLE_CODE, DAT_HLE_STARTDATE, DAT_HLE_ENDDATE
		cmdline='query2 S12_HLE_CODE DAT_HLE_STARTDATE ge "'+anytim(cur_intv[0],/ECS,/trunc)+'" AND DAT_HLE_ENDDATE lt "'+anytim(cur_intv[1],/ECS,/trunc)+'"'
		SPAWN,'java -cp /global/hercules/users/shilaire/HEDC/util:/global/hercules/users/hedc/dm/classes/dm.jar:/global/hercules/users/hedc/dm/classes/sc_lib.jar '+cmdline,HLElist,stderr, exit_status=exit_status
		IF exit_status NE 0 THEN GOTO,NEXTPLEASE
		IF HLElist[0] EQ '' THEN GOTO,NEXTPLEASE
		FOR j=0L,N_ELEMENTS(HLElist)-1 DO BEGIN
			cmdline='query1 S12_HLE_CODE eq '+HLElist[j]+' DAT_HLE_STARTDATE'			
			SPAWN,'java -cp /global/hercules/users/shilaire/HEDC/util:/global/hercules/users/hedc/dm/classes/dm.jar:/global/hercules/users/hedc/dm/classes/sc_lib.jar '+cmdline,startdate,stderr, exit_status=exit_status
			cmdline='query1 S12_HLE_CODE eq '+HLElist[j]+' DAT_HLE_ENDDATE'			
			SPAWN,'java -cp /global/hercules/users/shilaire/HEDC/util:/global/hercules/users/hedc/dm/classes/dm.jar:/global/hercules/users/hedc/dm/classes/sc_lib.jar '+cmdline,enddate,stderr, exit_status=exit_status
			cmdline='query1 S12_HLE_CODE eq '+HLElist[j]+' LKY_HLE_ID'			
			SPAWN,'java -cp /global/hercules/users/shilaire/HEDC/util:/global/hercules/users/hedc/dm/classes/dm.jar:/global/hercules/users/hedc/dm/classes/sc_lib.jar '+cmdline,HLEid,stderr, exit_status=exit_status
			
			flo ->set,obs_time_interval = [startdate[0],enddate[0]]
			bla = flo->getdata()
			IF datatype(bla) EQ 'STC' THEN FLARELISTNBR = bla[0].ID_NUMBER ELSE FLARELISTNBR=-1

			IF FLARELISTNBR GE 0 THEN BEGIN				
				cmdline='modify_tuple I10_HLE_RESERVE1 '+HLEid+' '+strn(FLARELISTNBR)
				SPAWN,'java -cp /global/hercules/users/shilaire/HEDC/util:/global/hercules/users/hedc/dm/classes/dm.jar:/global/hercules/users/hedc/dm/classes/sc_lib.jar '+cmdline,stdout,stderr, exit_status=exit_status			
				IF exit_status NE 0 THEN PRINT,stderr
			ENDIF
		ENDFOR
		NEXTPLEASE:
	ENDFOR
	OBJ_DESTROY,flo
END
