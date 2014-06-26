;EXAMPLE:
;	hedc_dbmod_nbr_sources,'2002/02/20 '+['03:00','24:00']
;	imagecube=hedc_dbmod_nbr_sources_make_imagecube(hedc_dbmod_nbr_sources_get_fitsfiles( 5479, ['java','-cp','/global/hercules/users/shilaire/HEDC/util:/global/hercules/users/hedc/dm/classes/dm.jar:/global/hercules/users/hedc/dm/classes/sc_lib.jar'] ,'/global/hercules/data2/archive/'))
;
;MUST BE RUN FROM HERCULES...
;-----------------------------------------------------------------------------------------------------------------------
FUNCTION hedc_dbmod_nbr_sources_get_fitsfiles, HLE, basejavacmdline, basepath
	
	fitsfiles=-1
		HLEid=strn(HLE)
		
		cmdline=[basejavacmdline,'query1','LKY_HLE_ID','eq',HLEid,'S12_HLE_CODE']
		SPAWN,cmdline,HLEcode,stderr, exit_status=exit_status,/NOSHELL
		IF ((exit_status NE 0) OR (HLEcode EQ '')) THEN RETURN,-1
		PRINT,'HLEcode: '+HLEcode
		SPAWN,'hostname',stdout,stderr, exit_status=exit_status
		IF exit_status NE 0 THEN RETURN,-1
		IF stdout EQ 'saturn' THEN cmdline='ls '+basepath+'fil/*/HEDC_DP_mov[ghij]*'+HLEcode+'.fits' ELSE cmdline='rsh saturn ls '+basepath+'fil/*/HEDC_DP_mov[BCDEGHIJ]*'+HLEcode+'.fits'
		SPAWN,cmdline,fitsfiles,stderr, exit_status=exit_status
		IF exit_status NE 0 THEN RETURN,-1
RETURN,fitsfiles
END
;-----------------------------------------------------------------------------------------------------------------------
FUNCTION hedc_dbmod_nbr_sources_make_imagecube, fitsfiles
	IF datatype(fitsfiles) NE 'STR' THEN RETURN,-1
	imagecube=-1	
	FOR i=0L,N_ELEMENTS(fitsfiles)-1 DO BEGIN
		bla=mrdfits(fitsfiles[i],0,/SILENT)
		IF N_ELEMENTS(bla) GT 1 THEN BEGIN
			IF N_ELEMENTS(imagecube) EQ 1 THEN imagecube=bla ELSE imagecube=[[[imagecube]],[[bla]]]
		ENDIF
	ENDFOR
	RETURN,imagecube
END
;-----------------------------------------------------------------------------------------------------------------------
PRO hedc_dbmod_nbr_sources, time_intv
	basejavacmdline_v1=['java','-cp','/global/hercules/users/shilaire/HEDC/util:/global/hercules/users/hedc/dm/classes/dm.jar:/global/hercules/users/hedc/dm/classes/sc_lib.jar']
	basejavacmdline_v2='java -cp /global/hercules/users/shilaire/HEDC/util:/global/hercules/users/hedc/dm/classes/dm.jar:/global/hercules/users/hedc/dm/classes/sc_lib.jar '
	basepath='/global/hercules/data2/archive/'

	cmdline=basejavacmdline_v2+'query3 LKY_HLE_ID DAT_HLE_STARTDATE lt "'+anytim(time_intv[1],/ECS,/trunc)+'" AND DAT_HLE_ENDDATE gt "'+anytim(time_intv[0],/ECS,/trunc)+'" AND C04_HLE_EVENTTYPE eq S'
	SPAWN,cmdline,HLElist,stderr, exit_status=exit_status
	IF ((exit_status NE 0) OR (HLElist[0] EQ '')) THEN RETURN

	PRINT,'Number of HLEs to do: '+strn(N_ELEMENTS(HLElist))
	FOR i=0L,N_ELEMENTS(HLElist)-1 DO BEGIN
		PRINT,'HLEid: '+strn(HLElist[i])+'.....'
			wrt_ascii,strn(HLElist[i]),'scratch.txt'
		nsources=hedc_nbr_sources(hedc_dbmod_nbr_sources_make_imagecube(hedc_dbmod_nbr_sources_get_fitsfiles(HLElist[i], basejavacmdline_v1,basepath)))
		PRINT,'..........   nsources: '+strn(nsources)
		IF nsources GT 0 THEN BEGIN
			cmdline=basejavacmdline_v2+'modify_tuple I02_HLE_MULTIPLICITY '+strn(HLElist[i])+' '+strn(nsources)
			SPAWN,cmdline,stdout,stderr, exit_status=exit_status
			IF exit_status NE 0 THEN PRINT,'Problem!' ELSE PRINT,'Successful, with '+strn(nsources)+' sources!'
		ENDIF
	ENDFOR
END
;-----------------------------------------------------------------------------------------------------------------------


