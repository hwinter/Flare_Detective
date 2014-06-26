;+
; V3: Will automatically redo any EIT movie and add the link to the TXT_HLE_COMMENTS field.
;	If redoing fails or is bypassed, will look for already existing EIT movie...
;	Will check if any TRACE movie already exists. If yes, will also add the link to the TXT_HLE_COMMENTS field.	
;
; 	V2 might be the version to look up for full flexibility...
;	 
;
; 'in' can is either a single HLEcode, or an anytim time_intv.
; ELLIGIBLE can be a scalar, 2-element array, or 3-element array.
; 		[0]: MIN GOES FLUX [uW/m^2]
;		[1]: MAX GOES FLUX [uW/m^2]
;		[2]: MIN DURATION (DEFAULT:150 secs)
;
;
; EXAMPLE:
;	hedc_dbmod_movies3, 'HXS202201106',/BYPASS
;
;	hedc_dbmod_movies3, 'HXS311021837'
;	hedc_dbmod_movies3, 'HXS310240053',/NOCRASH
;	hedc_dbmod_movies3, ['2003/10/19','2003/11/06']
;	hedc_dbmod_movies3, ['2003/10/21','2003/10/22'],/ELLIG
;	hedc_dbmod_movies3, ['2003/10/19','2003/11/06'],ELLIG=[3,10]
;	hedc_dbmod_movies3, ['2003/10/19','2003/11/06'],ELLIG=[3,1000,100],/NOCRASH
;
;	hedc_dbmod_movies3, 'HXS404061319',/IMSP
;
;	REPROCESSING:
;	hedc_dbmod_movies3,/IMSP,ELLIG=[10.,10000.,100.],['2003/02/22','2003/06/01']
;	hedc_dbmod_movies3,/IMSP,'HXS304230118',dir='/global/saturn/home/shilaire/TEMP'
;	hedc_dbmod_movies3,/IMSP,'HXS202201106',dir='/global/saturn/home/shilaire/TEMP'
;	hedc_dbmod_movies3,/IMSP,dir='/global/saturn/home/shilaire/TEMP',['2003/02/22','2003/06/01'],ELLIG=[10,10000,100],/NOCRASH
;
;	hedc_dbmod_movies3,IMSP=2,'HXS402082031','/global/saturn/home/shilaire/TEMP'
;
;	hedc_dbmod_movies3,IMSP=2,['2002/02/13','2002/07/01'],'/global/pandora/home/shilaire/TEMP',ELLIG=[10.,10000.,100.],/NOCRASH
;-
PRO hedc_dbmod_movies3, in, dir, ELLIGIBLE=ELLIGIBLE, NOCRASH=NOCRASH, IMSP=IMSP, BYPASS=BYPASS
	PRINT,'Remember, dir has to be (NFS-) reachable by pandora!!!'
	PRINT,'And /global/hercules/users/hedc/public_html/movies/ must be (NFS-) reachable by local machine!'
	PRINT,"Don't forget to newgrp hedc and umask 002 before running this IDL session!!!"
	PRINT,'Ok to go on? (y/n):'
	bla='asdsa'
	READ,bla
	IF bla NE 'y' THEN RETURN
	
	;use /BYPASS when file already exists.

	moviedir='/global/hercules/users/hedc/public_html/movies/'
	
	SET_PLOT,'Z'
	IF NOT KEYWORD_SET(dir) THEN dir=GETENV('HOME')+'/TEMP'
	javabasecmdline='rsh hercules java -cp /global/hercules/users/shilaire/HEDC/util:/global/hercules/users/hedc/dm/classes/dm.jar:/global/hercules/users/hedc/dm/classes/sc_lib.jar '
	nbrOK=0L
	nbrAttempted=0L

	IF N_ELEMENTS(in) EQ 2 THEN BEGIN
		cmdline='query2 S12_HLE_CODE DAT_HLE_STARTDATE ge "'+anytim(in[0],/ECS,/trunc,/date)+'" AND DAT_HLE_ENDDATE lt "'+anytim(in[1],/ECS,/trunc,/date)+'"'
		SPAWN,javabasecmdline+cmdline,HLElist,stderr, exit_status=exit_status
		IF exit_status NE 0 THEN RETURN
	ENDIF ELSE HLElist=in[0]	
	IF HLElist[0] EQ '' THEN RETURN ELSE PRINT,HLElist
	FOR i=0L,N_ELEMENTS(HLElist)-1 DO BEGIN
		PRINT,HLElist[i]
		EITmovie=0
		dohyperlink=0
		IF KEYWORD_SET(ELLIGIBLE) THEN BEGIN
			;check whether they're elligible...			
			cmdline='query1 S12_HLE_CODE eq '+HLElist[i]+' F10_HLE_RESERVE1'
			SPAWN,javabasecmdline+cmdline,stdout,stderr, exit_status=exit_status
			IF exit_status NE 0 THEN GOTO,NEXTPLEASE
			IF stdout[0] EQ '' THEN GOTO,NEXTPLEASE		
			IF N_ELEMENTS(ELLIGIBLE) GE 2 THEN BEGIN 
				PRINT,'Flux: '+stdout
				IF is_number(stdout[N_ELEMENTS(stdout)-1]) THEN goesmaxflux=FLOAT(stdout[N_ELEMENTS(stdout)-1]) ELSE goesmaxflux=0.001
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

		nbrAttempted=nbrAttempted+1		

		cmdline='query1 S12_HLE_CODE eq '+HLElist[i]+' DAT_HLE_STARTDATE'
		SPAWN,javabasecmdline+cmdline,sttim,stderr, exit_status=exit_status
		IF exit_status NE 0 THEN GOTO,NEXTPLEASE
		IF sttim[0] EQ '' THEN GOTO,NEXTPLEASE		
		cmdline='query1 S12_HLE_CODE eq '+HLElist[i]+' DAT_HLE_ENDDATE'
		SPAWN,javabasecmdline+cmdline,endtim,stderr, exit_status=exit_status
		IF exit_status NE 0 THEN GOTO,NEXTPLEASE
		IF endtim[0] EQ '' THEN GOTO,NEXTPLEASE
		flare_time_interval=anytim([sttim[N_ELEMENTS(sttim)-1],endtim[N_ELEMENTS(endtim)-1]])+[-300,600]
		
		mainfinotype='EITall'
		main_info={type:  mainfinotype, time_intv: anytim(flare_time_interval,/ECS) }
		IF KEYWORD_SET(IMSP) THEN hessi_info={HEDC_CODE: HLElist[i], imsp:IMSP} ELSE hessi_info={HEDC_CODE: HLElist[i]}
			;IF KEYWORD_SET(IMSP) THEN hessi_info={HEDC_CODE: HLElist[i], eband_ss:[2,12],imsp:1} ELSE hessi_info={HEDC_CODE: HLElist[i], eband_ss:[1,3]}
		outmpegdir=moviedir+psh_time2dir(flare_time_interval[0])
		IF NOT FILE_TEST(outmpegdir,/DIR) THEN FILE_MKDIR,outmpegdir
		
		mpegfil=outmpegdir+HLElist[i]+'_EIT.mpg'
		IF KEYWORD_SET(BYPASS) THEN cube=-1 ELSE cube=psh_movie2(main_info, hessi_info, scratchdir=dir,  mpegfile=mpegfil, NOCRASH=NOCRASH)

		IF N_ELEMENTS(cube) GT 1 THEN BEGIN
			PRINT,'Imagecube completed. Hyperlinking it...'
			EITMOVIE=1
		ENDIF ELSE BEGIN		
			PRINT,'Imagecube not properly generated for EIT, or bypassed. Checking if there are previous ones...'
			IF FIND_FILE(moviedir+psh_time2dir(flare_time_interval[0])+HLElist[i]+'_EIT*.mpg') NE '' THEN BEGIN
				PRINT,'Found previous EIT movie! Hyperlinking it...'
				EITMOVIE=1
			ENDIF ELSE PRINT,'Not found...'
		ENDELSE
		IF EITMOVIE EQ 1 THEN BEGIN	
			moviename='EIT-RHESSI movie'
			movieurl='http://www.hedc.ethz.ch/www/movies/'+psh_time2dir(flare_time_interval[0])+HLElist[i]+'_EIT.mpg'
			movie_link='<A HREF='+movieurl+'>'+moviename+'</A>'
			dohyperlink=1
		ENDIF
		PRINT,'Checking for old TRACE movie...'
		IF FIND_FILE(moviedir+psh_time2dir(flare_time_interval[0])+HLElist[i]+'.mpg') THEN BEGIN
			PRINT,'Found!'
			moviename='TRACE-RHESSI movie'
			movieurl='http://www.hedc.ethz.ch/www/movies/'+psh_time2dir(flare_time_interval[0])+HLElist[i]+'.mpg'
			IF EITMOVIE EQ 1 THEN BEGIN
				movie_link=movie_link+' <A HREF='+movieurl+'>'+moviename+'</A>'
			ENDIF ELSE BEGIN
				movie_link='<A HREF='+movieurl+'>'+moviename+'</A>'
			ENDELSE
			dohyperlink=1
		ENDIF ELSE PRINT,'...Not found.'

		IF dohyperlink EQ 1 THEN BEGIN
			cmdline='query1 S12_HLE_CODE eq '+HLElist[i]+' LKY_HLE_ID'
			SPAWN,javabasecmdline+cmdline, HLEid, stderr,exit_status=exit_status 
			IF exit_status NE 0 THEN GOTO,NEXTPLEASE

			;get already existing stuff:
			SPAWN,/NOSHELL,['rsh','hercules','java','-cp','/global/hercules/users/shilaire/HEDC/util:/global/hercules/users/hedc/dm/classes/dm.jar:/global/hercules/users/hedc/dm/classes/sc_lib.jar','query1','LKY_HLE_ID','eq',strn(HLEid[N_ELEMENTS(HLEid)-1]),'TXT_HLE_COMMENTS'],stdout,stderr,exit_status=exit_status
			IF exit_status NE 0 THEN GOTO,NEXTPLEASE
			IF ((stdout[0] EQ '') OR (stdout[0] EQ 'null')) THEN newcomments='"'+movie_link+'"' ELSE newcomments='"'+stdout+' '+movie_link+'"'
			newcomments='"'+movie_link+'"'
			
			SPAWN,/NOSHELL,['rsh','hercules','java','-cp','/global/hercules/users/shilaire/HEDC/util:/global/hercules/users/hedc/dm/classes/dm.jar:/global/hercules/users/hedc/dm/classes/sc_lib.jar','modify_tuple','TXT_HLE_COMMENTS',strn(HLEid[N_ELEMENTS(HLEid)-1]),newcomments],stdout,stderr,exit_status=exit_status
			IF exit_status NE 0 THEN GOTO,NEXTPLEASE
		ENDIF 
		

		nbrOK=nbrOK+1
		NEXTPLEASE:
		IF FILE_EXIST(outmpegdir) THEN BEGIN
			IF NOT FILE_EXIST(outmpegdir+'/*') THEN FILE_DELETE,outmpegdir
		ENDIF
		PRINT,'Examined: '+strn(100.*(i+1)/N_ELEMENTS(HLElist))+' % of events.'
		CLOSE,/ALL
	ENDFOR;i
	PRINT,'..........................................................................'
	PRINT,strn(nbrOK)+' reached completion, out of '+strn(nbrAttempted)+' attempted.'
END

