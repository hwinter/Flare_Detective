; PSH, 2004/02/12
; This script will modify the times array in a Callisto fits file...
;
;setenv,'RAG_ARCHIVE=/ftp/pub/rag/callisto/observations/'
;data=rapp_get_spectrogram('2003/10/27 '+['12:10','12:20'],xax=x,yax=y)
;
;
;================================================================================================================================================
PRO callisto_modtimes_investigate, fil, nextfil 
	PRINT,'====================================================================================================='
	PRINT,'Stats for file: '+fil
	radio_spectro_fits_read,fil,spg,x,y
	nx=N_ELEMENTS(x)
	PRINT,'Number of time points: '+strn(nx)
	ptim,[x[0],x[nx-1]]
	PRINT,' Uncorrected time interval is: '+strn(x[nx-1]-x[0])
	PRINT,' Uncorrected dt is: '+strn((x[nx-1]-x[0])/nx)

	IF N_PARAMS() GT 1 THEN BEGIN
		BREAK_FILE, FIL, DISK_LOG, DIR, FILNAM1, EXT, FVERSION, NODE
		BREAK_FILE, NEXTFIL, DISK_LOG, DIR, FILNAM2, EXT, FVERSION, NODE
		tim1=STRMID(FILNAM1,0,4)+'/'+STRMID(FILNAM1,4,2)+'/'+STRMID(FILNAM1,6,2)+' '+STRMID(FILNAM1,8,2)+':'+STRMID(FILNAM1,10,2)+':'+STRMID(FILNAM1,12,2)
		tim2=STRMID(FILNAM2,0,4)+'/'+STRMID(FILNAM2,4,2)+'/'+STRMID(FILNAM2,6,2)+' '+STRMID(FILNAM2,8,2)+':'+STRMID(FILNAM2,10,2)+':'+STRMID(FILNAM2,12,2)

		PRINT,' Time intv between files is in fact: '+strn(anytim(tim2)-anytim(tim1))
		corr_dt=(anytim(tim2)-anytim(tim1))/(nx+1)
		PRINT,' Corrected dt is: '+strn(corr_dt)
		PRINT,' ...and last time in file will be: '+anytim(anytim(tim1)+nx*corr_dt,/ECS)
		PRINT,'Next file name: '+nextfil
	ENDIF
	PRINT,'----------------------------------------------------------------------------------------------------'
END
;================================================================================================================================================
PRO callisto_modtimes_modfile, file, nextstarttime

	;from Peter Messmer's calMeasurements__define.pro:
	  ; RAGFitsWrite, data, *self.timePtr, frequency ,$
	  ; FILE = filenamestr_int,                              $
	  ; CONTENT = dateObs + " " + timeObs + ' Flux Density', $
	  ; ORIGIN  = obsInfo.origin,                            $
	  ; TELESCOPE = obsInfo.telescope,                       $
	  ; INSTRUMENT = obsInfo.instrument,                     $ 
	  ; OBJECT = obsInfo.object,                             $
	  ; DATEOBS = dateObs, DATEEND = dateObs,                $
	  ; TIMEEND = timeEnd, BUNIT = bunit,                    $
	  ; CTYPE1 = 'Time in UT', CTYPE2 = 'Frequency in MHz',  $
	  ; SCALING='BYTE'
	
	ragfitsread, file,img,x,y,/SILENT, HEADER=HEADER, 	$
		CONTENT=CONTENT, ORIGIN=ORIGIN, TELESCOPE=TELESCOPE, $
		INSTRUMENT=INSTRUMENT, OBJECT=OBJECT, $
		DATEOBS=DATEOBS,DATEEND=DATEEND, TIMEOBS=TIMEOBS, TIMEEND=TIMEEND, $
		CTYPE1=CTYPE1, CTYPE2=CTYPE2, bunit=bunit

	;rescaling time axis...
	nx=N_ELEMENTS(x)
	dt=(anytim(nextstarttime,/time)-x[0])/nx
	newx=x[0]+dt*DINDGEN(nx)

	;deleting previous file:
	FILE_DELETE,file
	
	;newfile name...
	IF STRMID(file,/REVERSE,2) EQ '.gz' THEN newfile=STRMID(file,0,STRLEN(file)-3) ELSE newfile=file

	; rewriting the fits file...
	timeend=anytim(nextstarttime,/ECS,/time,/trunc)
	RAGFitsWrite, img, newx, y ,$
		FILE = newfile, $
		CONTENT = dateObs + " " + timeObs + ' Flux Density', $
		ORIGIN  = origin,				$
		TELESCOPE = telescope,                       $
		INSTRUMENT = instrument,                     $ 
		OBJECT = object,                             $
		DATEOBS = dateObs, DATEEND = dateObs,                $
		TIMEEND = timeEnd, BUNIT = bunit,                    $
		CTYPE1 = 'Time in UT', CTYPE2 = 'Frequency in MHz',  $
		SCALING='BYTE'

	;gzipping it...
	SPAWN,'gzip -f '+newfile
	
END
;================================================================================================================================================
PRO callisto_modtimes, dir, AUTO=AUTO
	files=FINDFILE(dir+'/*.fit.gz')
	IF N_ELEMENTS(files) EQ 1 THEN BEGIN
		IF files EQ '' THEN BEGIN
			PRINT,'No appropriate files... aborting gracefully...'		
		ENDIF ELSE BEGIN
			PRINT,'Single file in this directory !'
			PRINT,'Start time according to file name is: '+ragfile2time(files,/ECS)
			radio_spectro_fits_read,files,spg,x,y
			nx=N_ELEMENTS(x)
			PRINT,'Data time intervals in file:'			
			PRINT,anytim(x[0],/ECS)+'-'+anytim(x[nx-1],/ECS)
			PRINT,'nx:'+strn(nx)+'   -  Duration:'+strn(x[nx-1]-x[0])
			PRINT,'With dt='+strn((x[nx-1]-x[0])/(nx+1))

			IF KEYWORD_SET(AUTO) THEN BEGIN
				starttime=ragfile2time(files)
				nextstarttime=starttime+(x[nx-1]-x[0])*700./900.
				callisto_modtimes_modfile, files, nextstarttime
			ENDIF ELSE BEGIN
				changeit=0
				ask,' 1-No changes 2-Change by duration ?: ',ANSWER, VALID=['1','2']
				CASE ANSWER OF
					'2': BEGIN
						starttime=ragfile2time(files)
						tmp=700d
						READ,tmp
						nextstarttime=starttime+tmp
						callisto_modtimes_modfile, files, nextstarttime						
					END
					ELSE: PRINT,'Not changing file...'
				ENDCASE
			ENDELSE
		ENDELSE
	ENDIF ELSE BEGIN
		nf=N_ELEMENTS(files)
		FOR i=0,nf-2 DO callisto_modtimes_modfile, files[i], ragfile2time(files[i+1])
		;now, for the very last file...
		ragfitsread,files[nf-1],img,x,y,/SILENT
		callisto_modtimes_modfile, files[nf-1], ragfile2time(files[nf-1])+.5*700./900.*N_ELEMENTS(x)
	ENDELSE	
END
;================================================================================================================================================
;================================================================================================================================================
PRO callisto_mod_timeend, dir
	files=FINDFILE(dir+'/*.fit.gz')
	nfiles=N_ELEMENTS(files)
	FOR i=0,nfiles-1 DO BEGIN
		
		;loading stuff
		ragfitsread, files[i],img,x,y,/SILENT, HEADER=HEADER, 	$
			CONTENT=CONTENT, ORIGIN=ORIGIN, TELESCOPE=TELESCOPE, $
			INSTRUMENT=INSTRUMENT, OBJECT=OBJECT, $
			DATEOBS=DATEOBS,DATEEND=DATEEND, TIMEOBS=TIMEOBS, TIMEEND=TIMEEND, $
			CTYPE1=CTYPE1, CTYPE2=CTYPE2, bunit=bunit

		;deleting previous file:
		FILE_DELETE,files[i]
	
		;newfile name...
		IF STRMID(files[i],/REVERSE,2) EQ '.gz' THEN newfile=STRMID(files[i],0,STRLEN(files[i])-3) ELSE newfile=files[i]

		; rewriting the fits file...
		IF i NE (nfiles-1) THEN timeend=anytim(ragfile2time(files[i+1]),/ECS,/time,/trunc) ELSE timeend=anytim(2*x[N_ELEMENTS(x)-1]-x[N_ELEMENTS(x)-2],/ECS,/time,/trunc)
ptim,timeend
		RAGFitsWrite, img, x, y ,$
			FILE = newfile, $
			CONTENT = dateObs + " " + timeObs + ' Flux Density', $
			ORIGIN  = origin,				$
			TELESCOPE = telescope,                       $
			INSTRUMENT = instrument,                     $ 
			OBJECT = object,                             $
			DATEOBS = dateObs, DATEEND = dateObs,                $
			TIMEEND = timeEnd, BUNIT = bunit,                    $
			CTYPE1 = 'Time in UT', CTYPE2 = 'Frequency in MHz',  $
			SCALING='BYTE'
	
		;gzipping it...
		SPAWN,'gzip -f '+newfile
	ENDFOR
END
;================================================================================================================================================
