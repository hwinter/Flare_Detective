; This routine will take the following info:
;	-list of main image files (STRARR)
;	-info for RHESSI images:	-generate on the fly? (need xyoffset...)
;					-tesseract fits file name
;					-HEDC code, where image tesseract has already been generated (+wanted e-bands contours...)
;It will return a cube.
;IF the TRACE files and the HESSI tesseract file are already available, then use simply 'cube=psh_trace_hessi_movie_make_cube(mainfiles,hessifile)'
;
;
;
; EXAMPLE 1:
;	main_info={type: 'TRACE195', time_intv: '2002/08/22 '+['01:40','02:30'], skip:0, exclude_time_intvs: -1 }	;if I need to download...
;	main_info={files: STRARR(100), skip:0, exclude_time_intvs: -1 } ;if files already there... 1 file per image...
;		Tags 'skip' and 'exclude_time_intvs' are not used for now.
;
;	hessi_info={file: 'hsi_tesseract.fits', eband_ss:[3,12]}
;	hessi_info={HEDC_CODE: 'HXS202261026', eband_ss:[3,12]}
;	hessi_info={HEDC_HLE_ID: 1234L, eband_ss:[3,12]}
;	hessi_info={xyoffset: [816,-272], ebands: [[4,8],[14,16],[25,30]]], exclude_time_intvs='2002/08/22 '+[['01:44','01:48'],['02:20','02:40']], hessi_dt:20}	; if whole stuff needs to be generated...
;
;	cube=psh_movie(main_info, hessi_info)
;
; EXAMPLE 2:
;	set_plot,'Z' & cube=psh_movie({type: 'TRACE195', time_intv: '2003/10/24 '+['02:20','03:15']}, {HEDC_CODE:'HXS310240234',eband_ss:[1,3]},workdir='/global/pandora/home/shilaire/mydata/TEMP/',mpeg='movie.mpg') & X
;
;	files='~/temp_20040209_144534/trac_195____a2_20031024_'+['022533','022624','022715','022741','022825','022901','022936','023011','023047','023122','023157','023218','023258','023343']+'.fts.gz'
;	cube=psh_movie({files:files}, {HEDC_CODE:'HXS310240234', eband_ss:[1,3],imsp:1})
;	
; PLANNED IMPROVEMENTS:
;	-Should align TRACE images with an EIT one...
;	-Should check whether we have HESSI data...?
;
;=================================================================================================================================================

FUNCTION psh_movie, main_info, hessi_info, dir=dir, NOERASE=NOERASE, MPEG=MPEG, NOCRASH=NOCRASH

	PRINT,".....PSH's MOVIEMAKING ......"
	Error_Status=0
	IF KEYWORD_SET(NOCRASH) THEN CATCH, Error_Status
	IF Error_Status NE 0 THEN BEGIN
		CATCH,/CANCEL
		PRINT,'...............................CAUGHT ERROR in psh_movie.pro !...................................'
		PRINT,'..........................ERROR MESSAGES:........................................'
		HELP, /Last_Message, Output=theErrorMessage
		FOR j=0,N_Elements(theErrorMessage)-1 DO PRINT, theErrorMessage[j]
		PRINT,'..........................END OF ERROR MESSAGES...................................'
		PRINT,'...................... psh_movie.pro FAILURE: ABORTING GRACEFULLY...........'		
		;;;Error_Status=0
		cube=-1 & GOTO,CLEANUP
	ENDIF

	;create and go to temporary workdir
	old_dir=curdir()
	IF NOT KEYWORD_SET(dir) THEN dir=old_dir
	workdir=dir+'/temp_'+time2file(systim2anytim(),/SEC)
	FILE_MKDIR,workdir
	CD,workdir

; 'MAIN' STUFF
	IF tag_exist(main_info,'files') THEN BEGIN	;we already have all necessary files locally.
		mainfiles=main_info.files	
	ENDIF ELSE BEGIN				; we have to download all necessary files
		IF tag_exist(main_info,'type') THEN BEGIN
			CASE STRUPCASE(main_info.type) OF
				'TRACE195': BEGIN
					IF tag_exist(main_info,'time_intv') THEN BEGIN
						psh_smmdac_download,'TRACE',main_info.time_intv, files=mainfiles, wl='195',workdir
						IF datatype(mainfiles) EQ 'INT' THEN BEGIN
							PRINT,'Apparently, no '+main_info.type+' files available at smmdac..... ABORTING psh_movie.pro....'
							cube=-1 & GOTO,CLEANUP
						ENDIF
						mainfiles=workdir+'/'+mainfiles
					ENDIF ELSE BEGIN
						PRINT,'ABORT:.......... Need main_info.time_intv !'
						cube=-1 & GOTO,CLEANUP
					ENDELSE
				END
				'EIT195': BEGIN
					IF tag_exist(main_info,'time_intv') THEN BEGIN
						psh_smmdac_download,'EIT',main_info.time_intv, files=mainfiles, wl='195',workdir
						IF datatype(mainfiles) EQ 'INT' THEN BEGIN
							PRINT,'Apparently, no '+main_info.type+' files available at smmdac..... ABORTING psh_movie.pro....'
							cube=-1 & GOTO,CLEANUP
						ENDIF
						mainfiles=workdir+'/'+mainfiles
					ENDIF ELSE BEGIN
						PRINT,'ABORT:.......... Need main_info.time_intv !'
						cube=-1 & GOTO,CLEANUP
					ENDELSE
				END
				ELSE: BEGIN
					PRINT,'ABORT:................main_info.type not recognized!'
					cube=-1 & GOTO,CLEANUP
				END
			ENDCASE
		ENDIF ELSE BEGIN
			PRINT,'ABORT:.................................Need main_info.type !'
			cube=-1 & GOTO,CLEANUP
		ENDELSE
	ENDELSE
	
	;if we've reached this far, we have a list of mainfiles...(full pathnames)
	PRINT,'Number of mainfiles: '+strn(N_ELEMENTS(mainfiles))	

;'HESSI' stuff...
	hessifile=-1
	basecmd='rsh hercules java -cp ".:/global/hercules/users/hedc/dm/classes/dm.jar:/global/hercules/users/hedc/dm/classes/sc_lib.jar::/global/hercules/users/shilaire/HEDC/util" '
	basearchpath='/global/hercules/data2/archive/'

	HLE_CODE=-1
	IF tag_exist(hessi_info,'HEDC_HLE_ID') THEN BEGIN
		cmd=basecmd+'query1 LKY_HLE_ID eq '+strn(hessi_info.HEDC_HLE_ID)+' S12_HLE_CODE'
		SPAWN,cmd,res,err
		HLE_CODE=res[0]
	ENDIF
	
	IF (tag_exist(hessi_info,'HEDC_CODE') OR (datatype(HLE_CODE) NE 'INT')) THEN BEGIN 
		IF tag_exist(hessi_info,'imsp') THEN addterm='imsp' ELSE addterm='pten'
		IF tag_exist(hessi_info,'HEDC_CODE') THEN rootfilename='HEDC_DP_'+addterm+'_'+STRUP(hessi_info.HEDC_CODE) ELSE rootfilename='HEDC_DP_'+addterm+'_'+STRUP(HEDC_CODE)		
		cmd=basecmd+'query1 TXT_FIL_NAME eq '+rootfilename+'.fits FKY_FIL_ARC_ID'
		SPAWN,cmd,res,err
		IF res[0] NE '' THEN BEGIN			
			cmd=basecmd+'query1 LKY_ARC_ID eq '+res[0]+' TXT_ARC_PATH'
			SPAWN,cmd,res,err
			IF res[0] NE '' THEN hessifile=basearchpath+res[0]+rootfilename+'.fits'
		ENDIF
	ENDIF ELSE BEGIN
			IF tag_exist(hessi_info,'file') THEN BEGIN
				hessifile=hessi_info.file
			ENDIF ELSE BEGIN
				;we have to generate the whole stuff 'on the fly'
				;hessi_time_intvs=anytim(tmp.time)+hessi_dt*[-0.5,0.5]
				;FOR i=1,N_ELEMENTS(mainfiles)-1 DO BEGIN
				;	fits2map,mainfiles[i],tmp			
				;	hessi_time_intvs=[[hessi_time_intvs],[anytim(tmp.time)+hessi_dt*[-0.5,0.5]]]
				;ENDFOR
				;hessi_ebands=[[6,12],[12,25],[25,50]]
				;IF KEYWORD_SET(hessi_exclude_time_intvs) THEN BEGIN
				;donttakeit=-1
				;FOR i=0L,N_ELEMENTS(hessi_time_intvs[0,*])-1 DO BEGIN
				;	FOR j=0L,N_ELEMENTS(hessi_exclude_time_intvs[0,*])-1 DO BEGIN
				;		IF has_overlap(hessi_time_intvs[*,i],hessi_exclude_time_intvs[*,j]) THEN BEGIN
				;			IF donttakeit[0] EQ -1 THEN donttakeit=i ELSE donttakeit=[donttakeit,i]
				;		ENDIF
				;	ENDFOR
				;ENDFOR
				;IF donttakeit[0] NE -1 THEN BEGIN
				;	takeit=LINDGEN(N_ELEMENTS(hessi_time_intvs[0,*]))
				;	FOR i=0L,N_ELEMENTS(donttakeit)-1 DO takeit=remove_element(takeit,donttakeit[i])	
				;	hessi_time_intvs=hessi_time_intvs[*,takeit]
				;ENDIF 
				;ENDIF
				;ptim, hessi_time_intvs
				;
				;hessifile=workdir+'/hsi_tesseract.fits'
				;rhessi_migen, hessi_time_intvs, hessi_ebands, xyoffset, hessifile															
			ENDELSE
	ENDELSE
	
;now, I'm supposed to have a fits file name with the RHESSI tesseract....	
	IF datatype(hessifile) NE 'STR' THEN BEGIN
		PRINT,'ABORT:....................... no hessi tesseract fits file!'
		cube=-1 & GOTO,CLEANUP
	ENDIF ELSE PRINT,'HESSI tesseract file: '+hessifile


;...........MAKING CUBE...
	IF tag_exist(hessi_info,'eband_ss') THEN eband_ss=hessi_info.eband_ss ELSE eband_ss=0
HELP,mainfiles,hessifile & PRINT,hessifile
	cube=psh_trace_hessi_movie_make_cube(mainfiles,hessifile,ebands_ss=eband_ss)
HELP,cube
	HEAP_GC
		
	IF KEYWORD_SET(MPEG) THEN BEGIN
		;do MPEG output: SPAWN an IDL 5.3 process that will run in background ('&')
		IF datatype(MPEG) NE 'STR' THEN MPEG=old_dir+'/movie.mpg'
		PRINT,'Doing MPEG encoding...'		
		psh_cube2mpeg, cube, MPEG
	ENDIF

CLEANUP:
	CD, old_dir
	IF NOT KEYWORD_SET(NOERASE) THEN BEGIN
		;erase all temporary stuff in workdir+directory itself.
		PRINT,'Erasing all temporary files...'
		;SPAWN,/NOSHELL,['rm','-rf ',workdir]
		SPAWN,'rm -rf '+workdir
	ENDIF	
	RETURN,cube
END

