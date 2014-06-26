;EX: rhessi_test_datafiles, ['2002/02/20','2002/02/26']


FUNCTION rhessi_test_datafiles_oneday, date
		
	filelist=hsi_filedb_filename(anytim(date,/date)+[0.,86399.])
	IF datatype(filelist) EQ 'INT' THEN BEGIN
		PRINT,'......NO FILES IN FILEDB FOR THAT DATE !!!'
		RETURN,0
	ENDIF
	filelist=filelist[1:*]
	extim=anytim(date,/date,/EX)
	yyyy=int2str(extim[6],4)
	mm=int2str(extim[5],2)
	dd=int2str(extim[4],2)
	filelist=GETENV('HSI_DATA_ARCHIVE')+'/'+yyyy+'/'+mm+'/'+dd+'/'+filelist	
	FOR i=0L,N_ELEMENTS(filelist)-1 DO BEGIN
		fits_info,filelist[i],/SILENT,N_ext=n
		IF n EQ -1 THEN BEGIN
			PRINT,"Problem with file "+filelist[i]
			RETURN,-1
		ENDIF
	ENDFOR
	PRINT,'.............----> OK! No problems !'
	RETURN,1
END



PRO rhessi_test_datafiles, date_intv
	n_days=CEIL(  (anytim(date_intv[1],/date)-anytim(date_intv[0],/date))/86400.  )
	
	FOR i=0L, n_days DO BEGIN
		curdate=anytim(date_intv[0],/date)+i*86400.
		PRINT,'Checking '+anytim(curdate,/ECS,/date)
		res=rhessi_test_datafiles_oneday(curdate)
		IF res LT 0 THEN BEGIN
			PRINT,"Problem with "+anytim(curdate,/ECS,/date)
			RETURN
		ENDIF
	ENDFOR
	PRINT,'.............----> OK! No problems ! Everything tip-top pico bello!'
END

