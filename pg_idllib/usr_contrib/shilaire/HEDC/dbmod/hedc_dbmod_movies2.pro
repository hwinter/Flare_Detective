;+
; 'in' can is either a single HLEcode, or an anytim time_intv.
; ELLIGIBLE can be a scalar, 2-element array, or 3-element array.
; 		[0]: MIN GOES FLUX [uW/m^2]
;		[1]: MAX GOES FLUX [uW/m^2]
;		[2]: MIN DURATION (DEFAULT:150 secs)
;
;
; EXAMPLE:
;	hedc_dbmod_movies2, 'HXS202201106',/EIT,ELLIG=[1,1000,100],/REPLACE ,/NOCRASH
;
;	hedc_dbmod_movies2, 'HXS310281205'
;	hedc_dbmod_movies2, 'HXS311021837'
;	hedc_dbmod_movies2, 'HXS310240053',/NOCRASH
;	hedc_dbmod_movies2, ['2003/10/19','2003/11/06']
;	hedc_dbmod_movies2, ['2003/10/21','2003/10/22'],/EIT,/ELLIG
;	hedc_dbmod_movies2, ['2003/10/19','2003/11/06'],/EIT,ELLIG=[3,10]
;	hedc_dbmod_movies2, ['2003/10/19','2003/11/06'],ELLIG=[3,1000,100],/NOCRASH
;
;	hedc_dbmod_movies2, 'HXS401071022',/EIT
;	hedc_dbmod_movies2, 'HXS404061319',/EIT,/IMSP
;	hedc_dbmod_movies2, 'HXS404061319',/EIT,/IMSP,/REPLACE
;
;-
PRO hedc_dbmod_movies2, in, dir=dir, EIT=EIT, ELLIGIBLE=ELLIGIBLE, REPLACE=REPLACE, NOCRASH=NOCRASH, IMSP=IMSP

	set_plot,'Z'
	IF NOT KEYWORD_SET(dir) THEN dir=GETENV('HOME')+'/TEMP'
	javabasecmdline='rsh hercules java -cp /global/hercules/users/shilaire/HEDC/util:/global/hercules/users/hedc/dm/classes/dm.jar:/global/hercules/users/hedc/dm/classes/sc_lib.jar '
	nbrOK=0L

	IF N_ELEMENTS(in) EQ 2 THEN BEGIN
		cmdline='query2 S12_HLE_CODE DAT_HLE_STARTDATE ge "'+anytim(in[0],/ECS,/trunc,/date)+'" AND DAT_HLE_ENDDATE lt "'+anytim(in[1],/ECS,/trunc,/date)+'"'
		SPAWN,javabasecmdline+cmdline,HLElist,stderr, exit_status=exit_status
		IF exit_status NE 0 THEN RETURN
	ENDIF ELSE HLElist=in[0]	
	IF HLElist[0] EQ '' THEN RETURN ELSE PRINT,HLElist
	FOR i=0L,N_ELEMENTS(HLElist)-1 DO BEGIN
		IF KEYWORD_SET(ELLIGIBLE) THEN BEGIN
			;check whether they're elligible...			
			cmdline='query1 S12_HLE_CODE eq '+HLElist[i]+' F10_HLE_RESERVE1'
			SPAWN,javabasecmdline+cmdline,stdout,stderr, exit_status=exit_status
			IF exit_status NE 0 THEN GOTO,NEXTPLEASE
			IF stdout[0] EQ '' THEN GOTO,NEXTPLEASE		
			IF N_ELEMENTS(ELLIGIBLE) GE 2 THEN BEGIN 
				PRINT,'Flux: '+stdout
				IF is_number(stdout[N_ELEMENTS(stdout)-1]) THEN goesmaxflux=FLOAT(stdout[N_ELEMENTS(stdout)-1]) ELSE goesmaxflux=1000
				IF ((goesmaxflux LT ELLIGIBLE[0]) OR (goesmaxflux GT ELLIGIBLE[1])) THEN GOTO,NEXTPLEASE
			ENDIF ELSE BEGIN
				;at least M1.0
				IF FLOAT(stdout[N_ELEMENTS(stdout)-1]) LT ELLIGIBLE[0] THEN GOTO,NEXTPLEASE
			ENDELSE
			;at least 150 secs long...
			cmdline='query1 S12_HLE_CODE eq '+HLElist[i]+' I08_HLE_DURATION'
			SPAWN,javabasecmdline+cmdline,stdout,stderr, exit_status=exit_status
			IF exit_status NE 0 THEN GOTO,NEXTPLEASE
			IF stdout[0] EQ '' THEN GOTO,NEXTPLEASE		
			IF N_ELEMENTS(ELLIGIBLE) GE 3 THEN BEGIN 
				IF FLOAT(stdout[N_ELEMENTS(stdout)-1]) LT ELLIGIBLE[2] THEN GOTO,NEXTPLEASE			
			ENDIF ELSE BEGIN
				IF FLOAT(stdout[N_ELEMENTS(stdout)-1]) LT 150 THEN GOTO,NEXTPLEASE			
			ENDELSE
		ENDIF

		cmdline='query1 S12_HLE_CODE eq '+HLElist[i]+' DAT_HLE_STARTDATE'
		SPAWN,javabasecmdline+cmdline,sttim,stderr, exit_status=exit_status
		IF exit_status NE 0 THEN GOTO,NEXTPLEASE
		IF sttim[0] EQ '' THEN GOTO,NEXTPLEASE		
		cmdline='query1 S12_HLE_CODE eq '+HLElist[i]+' DAT_HLE_ENDDATE'
		SPAWN,javabasecmdline+cmdline,endtim,stderr, exit_status=exit_status
		IF exit_status NE 0 THEN GOTO,NEXTPLEASE
		IF endtim[0] EQ '' THEN GOTO,NEXTPLEASE
		flare_time_interval=anytim([sttim[N_ELEMENTS(sttim)-1],endtim[N_ELEMENTS(endtim)-1]])+[-300,600]
		
		IF KEYWORD_SET(EIT) THEN mainfinotype='EIT195' ELSE mainfinotype='TRACE195'
		main_info={type:  mainfinotype, time_intv: anytim(flare_time_interval,/ECS) }
		IF KEYWORD_SET(IMSP) THEN hessi_info={HEDC_CODE: HLElist[i], eband_ss:[2,12],imsp:1} ELSE hessi_info={HEDC_CODE: HLElist[i], eband_ss:[1,3]}
		outmpegdir='/global/hercules/users/hedc/public_html/movies/'+psh_time2dir(flare_time_interval[0])
		IF NOT FILE_TEST(outmpegdir,/DIR) THEN FILE_MKDIR,outmpegdir
		
		IF KEYWORD_SET(EIT) THEN mpegfil=outmpegdir+HLElist[i]+'_EIT.mpg' ELSE mpegfil=outmpegdir+HLElist[i]+'.mpg'
		cube=psh_movie2(main_info, hessi_info, scratchdir=dir,  mpegfile=mpegfil, NOCRASH=NOCRASH)
		IF N_ELEMENTS(cube) GT 1 THEN BEGIN
			PRINT,'Modifying the HLE to add movie link...'
			IF KEYWORD_SET(EIT) THEN moviename='EIT-RHESSI movie' ELSE moviename='TRACE-RHESSI movie'
			IF KEYWORD_SET(EIT) THEN movieurl='http://www.hedc.ethz.ch/www/movies/'+psh_time2dir(flare_time_interval[0])+HLElist[i]+'_EIT.mpg' ELSE movieurl='http://www.hedc.ethz.ch/www/movies/'+psh_time2dir(flare_time_interval[0])+HLElist[i]+'.mpg'
			movie_link='<A HREF='+movieurl+'>'+moviename+'</A>'
			cmdline='query1 S12_HLE_CODE eq '+HLElist[i]+' LKY_HLE_ID'
			SPAWN,javabasecmdline+cmdline, HLEid, stderr,exit_status=exit_status 
			IF exit_status NE 0 THEN GOTO,NEXTPLEASE

			;get already existing stuff:
			SPAWN,/NOSHELL,['rsh','hercules','java','-cp','/global/hercules/users/shilaire/HEDC/util:/global/hercules/users/hedc/dm/classes/dm.jar:/global/hercules/users/hedc/dm/classes/sc_lib.jar','query1','LKY_HLE_ID','eq',strn(HLEid[N_ELEMENTS(HLEid)-1]),'TXT_HLE_COMMENTS'],stdout,stderr,exit_status=exit_status
			IF exit_status NE 0 THEN GOTO,NEXTPLEASE
			IF ((stdout[0] EQ '') OR (stdout[0] EQ 'null')) THEN newcomments='"'+movie_link+'"' ELSE newcomments='"'+stdout+' '+movie_link+'"'
			IF KEYWORD_SET(REPLACE) THEN newcomments='"'+movie_link+'"'
			
			SPAWN,/NOSHELL,['rsh','hercules','java','-cp','/global/hercules/users/shilaire/HEDC/util:/global/hercules/users/hedc/dm/classes/dm.jar:/global/hercules/users/hedc/dm/classes/sc_lib.jar','modify_tuple','TXT_HLE_COMMENTS',strn(HLEid[N_ELEMENTS(HLEid)-1]),newcomments],stdout,stderr,exit_status=exit_status
			IF exit_status NE 0 THEN GOTO,NEXTPLEASE
		ENDIF
		nbrOK=nbrOK+1
		NEXTPLEASE:
		PRINT,'Examined: '+strn(100.*(i+1)/N_ELEMENTS(HLElist))+' % of events.'
		CLOSE,/ALL
	ENDFOR
	PRINT,'..........................................................................'
	PRINT,strn(nbrOK)+' reached completion, out of '+strn(N_ELEMENTS(HLElist))
END

