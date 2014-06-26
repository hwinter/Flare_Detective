; Creates an array of pointers to maps corresponding to each fits file.
; If only 1 filename is given, and it is an image tesseract (assumed from RHESSI), then acts accordingly.
; Returns -1 if an error occured...
;
;
;EXAMPLE:
;	mapptr=psh_fits2map(file)
;
;	HISTORY:
;		Written by PSH from Zarro's fits2map.pro a long, long time ago, in a galaxy far, far away...
;		PSH 2004/10/05: Updated to accomodate modifications in imagetesseract fitsfiles from RHESSI...
;               P. Grigis 2004/11/11: added imtime_start keyword: if
;               set, the image time given is the start of the
;               integration time, not the average 
;-------------------------------------------------------------------------------------------------------
FUNCTION psh_fits2map, fitsfiles, ext1=ext1, BREAKONERROR=BREAKONERROR, imtime_start=imtime_start

	Error_Status=0
	IF NOT KEYWORD_SET(BREAKONERROR) THEN CATCH, Error_Status
	IF Error_Status NE 0 THEN BEGIN
		CATCH,/CANCEL
		PRINT,'...............................CAUGHT ERROR IN psh_fits2map.pro!...................................'
		;PRINT, 'Error index: ', Error_status
		;PRINT, 'Error message:', !ERR_STRING
		;HELP, CALLS=caller_stack
		;PRINT,'Error caller stack:',caller_stack
		;;;!error_state.code=Error_Status
		PRINT,'..........................ERROR MESSAGES:........................................'
		HELP, /Last_Message, Output=theErrorMessage
		FOR j=0,N_Elements(theErrorMessage)-1 DO PRINT, theErrorMessage[j]
		PRINT,'..........................END OF ERROR MESSAGES...................................'
		PRINT,'...................... psh_fits2map.pro will return -1 value..............'		
		;;;Error_Status=0
		;CLOSE,/ALL	; in case fits_info.pro is the source of the problem multiple times... but it would be better to better use fits_info.pro instead of using this fix...
		RETURN,-1
	ENDIF


	IF N_ELEMENTS(fitsfiles) EQ 1 THEN BEGIN
		;check whether it has at least one extension...
		fits_info,fitsfiles[0],/SILENT,N_ext=N_ext
		IF N_ext GE 1 THEN BEGIN
			;check whether that extension has a times_arr/ebands_arr tag...--> we should then have a valid image tesseract
			ext1=mrdfits(fitsfiles[0],1)			
			IF (tag_exist(ext1,'ebands_arr') OR tag_exist(ext1,'times_arr') OR tag_exist(ext1,'im_energy_binning') OR tag_exist(ext1,'im_time_interval')) THEN BEGIN
				IF tag_exist(ext1,'im_time_interval') THEN time_intvs=ext1.im_time_interval
				IF tag_exist(ext1,'times_arr') THEN time_intvs=ext1.times_arr
				n_times=N_ELEMENTS(time_intvs[0,*])
				IF tag_exist(ext1,'im_energy_binning') THEN ebins=ext1.im_energy_binning
				IF tag_exist(ext1,'ebands_arr') THEN ebins=ext1.ebands_arr					
				n_ebands=N_ELEMENTS(ebins[0,*])

				tess=mrdfits(fitsfiles[0],0)
				mapptr=PTRARR(n_ebands,n_times)			
				FOR i=0L,n_times-1 DO BEGIN
					FOR j=0L,n_ebands-1 DO BEGIN
                                                        IF keyword_set(imtime_start) THEN time=anytim(time_intvs[0,i],/tai) $
                                                        ELSE time=anytim(MEAN(anytim(time_intvs[*,i])),/tai)
							newmap= make_map(tess[*,*,j,i], $
					           	 xc=ext1.xyoffset[0], $
					                 yc=ext1.xyoffset[1], $
					                 dx=ext1.pixel_size[0], $
					                 dy=ext1.pixel_size[1], $
					                 time=time, $
							 dur=anytim(time_intvs[1,i])-anytim(time_intvs[0,i]),$
							 xunits='arcsecs',$ 
							 yunits='arcsecs',$
							 id='HESSI'	)
						mapptr[j,i]=PTR_NEW(newmap)
					ENDFOR;j
				ENDFOR;i
				RETURN,mapptr
			ENDIF ELSE PRINT,'No "times_arr/im_time_interval" and/or no "ebands_arr/im_energy_binning" tags in first extension...'
		ENDIF ELSE PRINT,"No extensions, or possibly a gzipped file (in which case, ignore fits_info's error message...)"
	ENDIF 

	;if I'm here, it's cuz I must have usual files with single fits images...
	FOR i=0L,N_ELEMENTS(fitsfiles)-1 DO BEGIN
		fits2map,fitsfiles[i],map,/SILENT
		IF i EQ 0 THEN mapptr=PTR_NEW(map) ELSE mapptr=[mapptr,PTR_NEW(map)]
	ENDFOR
	RETURN,mapptr
END
;-------------------------------------------------------------------------------------------------------
