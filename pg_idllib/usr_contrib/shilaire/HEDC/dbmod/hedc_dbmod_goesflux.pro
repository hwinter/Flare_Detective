;this script will look for all HLEs in the HEDC database, and put the maximum
;GOES flux (in uW/m^2) during the flare's interval in the F10_HLE_RESERVE1 field



PRO hedc_dbmod_goesflux, time_intv
	time_intv=anytim(time_intv,/date_only)
	ndays=CEIL((time_intv[1]-time_intv[0])/86400d) > 1
	
	FOR i=0L,ndays-1 DO BEGIN
		cur_intv=time_intv[0]+i*86400+[0,86400]
		HLElist=''
		
		;get all events for that day: S12_HLE_CODE, DAT_HLE_STARTDATE, DAT_HLE_ENDDATE
		cmdline='query2 LKY_HLE_ID DAT_HLE_STARTDATE ge "'+anytim(cur_intv[0],/ECS,/trunc)+'" AND DAT_HLE_ENDDATE lt "'+anytim(cur_intv[1],/ECS,/trunc)+'"'
		SPAWN,'java -cp /global/hercules/users/shilaire/HEDC/util:/global/hercules/users/hedc/dm/classes/dm.jar:/global/hercules/users/hedc/dm/classes/sc_lib.jar '+cmdline,HLElist,stderr, exit_status=exit_status
		IF exit_status NE 0 THEN GOTO,NEXTPLEASE
		IF HLElist[0] EQ '' THEN GOTO,NEXTPLEASE
		FOR j=0L,N_ELEMENTS(HLElist)-1 DO BEGIN
			cmdline='query1 LKY_HLE_ID eq '+HLElist[j]+' DAT_HLE_STARTDATE'			
			SPAWN,'java -cp /global/hercules/users/shilaire/HEDC/util:/global/hercules/users/hedc/dm/classes/dm.jar:/global/hercules/users/hedc/dm/classes/sc_lib.jar '+cmdline,startdate,stderr, exit_status=exit_status
			cmdline='query1 LKY_HLE_ID eq '+HLElist[j]+' DAT_HLE_ENDDATE'			
			SPAWN,'java -cp /global/hercules/users/shilaire/HEDC/util:/global/hercules/users/hedc/dm/classes/dm.jar:/global/hercules/users/hedc/dm/classes/sc_lib.jar '+cmdline,enddate,stderr, exit_status=exit_status
			HLEid=HLElist[j]
			rd_goes,goestime,goesdata,trange=anytim([startdate[0],enddate[0]],/yohkoh)
			IF datatype(goesdata) NE 'UND' THEN BEGIN
				goesflux=MAX(goesdata[*,0])
				goesclass=hedc_togoes(goesflux)
				PRINT,HLElist[j]+' '+goesclass+' '+strn(goesflux)+' Mid-time: '+anytim( (anytim(startdate[0])+anytim(enddate[0]))/2.,/ECS)
				
				cmdline='modify_tuple S20_HLE_RESERVE2 '+HLEid+' '+goesclass
				SPAWN,'java -cp /global/hercules/users/shilaire/HEDC/util:/global/hercules/users/hedc/dm/classes/dm.jar:/global/hercules/users/hedc/dm/classes/sc_lib.jar '+cmdline,stdout,stderr, exit_status=exit_status
				IF exit_status NE 0 THEN PRINT,stderr
				cmdline='modify_tuple F10_HLE_RESERVE1 '+HLEid+' '+strn(FIX(goesflux*1e8)/100.)
				SPAWN,'java -cp /global/hercules/users/shilaire/HEDC/util:/global/hercules/users/hedc/dm/classes/dm.jar:/global/hercules/users/hedc/dm/classes/sc_lib.jar '+cmdline,stdout,stderr, exit_status=exit_status			
				IF exit_status NE 0 THEN PRINT,stderr
			ENDIF ELSE PRINT,'No GOES data for '+anytim( (anytim(startdate)+anytim(enddate))/2.,/ECS)
		ENDFOR
		NEXTPLEASE:
	ENDFOR
END
