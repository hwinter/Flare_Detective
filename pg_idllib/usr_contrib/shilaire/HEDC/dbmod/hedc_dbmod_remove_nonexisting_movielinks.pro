; this routine removes any non-existing movie links in HEDC HLEs...
;
; hedc_dbmod_remove_nonexisting_movielinks,['2003/10/19','2003/11/06'] 
;

PRO hedc_dbmod_remove_nonexisting_movielinks, in

	javabasecmdline='rsh hercules java -cp /global/hercules/users/shilaire/HEDC/util:/global/hercules/users/hedc/dm/classes/dm.jar:/global/hercules/users/hedc/dm/classes/sc_lib.jar '

	IF N_ELEMENTS(in) EQ 2 THEN BEGIN
		cmdline='query2 S12_HLE_CODE DAT_HLE_STARTDATE ge "'+anytim(in[0],/ECS,/trunc,/date)+'" AND DAT_HLE_ENDDATE lt "'+anytim(in[1],/ECS,/trunc,/date)+'"'
		SPAWN,javabasecmdline+cmdline,HLEcodelist,stderr, exit_status=exit_status
		IF exit_status NE 0 THEN RETURN
	ENDIF ELSE HLEcodelist=in[0]	
	IF HLEcodelist[0] EQ '' THEN RETURN ELSE PRINT,HLEcodelist
	
	FOR i=0L,N_ELEMENTS(HLEcodelist)-1 DO BEGIN
		;does this HLE have an movie link ?
		cmdline='query1 S12_HLE_CODE eq '+HLEcodelist[i]+' TXT_HLE_COMMENTS'
		SPAWN,javabasecmdline+cmdline,stdout,stderr, exit_status=exit_status
		IF exit_status NE 0 THEN BREAK
		IF stdout[0] EQ '' THEN BREAK ELSE BEGIN
			PRINT,HLEcodelist[i]+' has the following TXT_HLE_COMMENTS field: '
			PRINT,stdout
			IF NOT FILE_EXIST('/global/hercules/users/hedc/public_html/movies/200'+STRMID(HLEcodelist[i],3,1)+'/'+STRMID(HLEcodelist[i],4,2)+'/'+STRMID(HLEcodelist[i],6,2)+'/'+HLEcodelist[i]+'.mpg') THEN BEGIN
				PRINT,HLEcodelist[i]+".mpg does not exist... erasing HLE's COMMENTS field..."
				cmdline='query1 S12_HLE_CODE eq '+HLEcodelist[i]+' LKY_HLE_ID'
				SPAWN,javabasecmdline+cmdline,stdout,stderr, exit_status=exit_status
				IF exit_status NE 0 THEN BREAK
				PRINT,'HLE id:'
				PRINT,stdout
				cmdline='modify_tuple TXT_HLE_COMMENTS '+strn(stdout[N_ELEMENTS(stdout)-1])+' \"\"'
				SPAWN,javabasecmdline+cmdline,stdout,stderr, exit_status=exit_status
				IF exit_status NE 0 THEN BREAK
			ENDIF ELSE PRINT,' MPEG file exists... not doing anything...'
		ENDELSE		
	ENDFOR
END





