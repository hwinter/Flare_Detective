; EXAMPLE:
;	hedc_mk_imagetesseract, 'HXS202261026'
;	hedc_mk_imagetesseract, files	; where files is a 2-d string array [ntimes,nenergy] of filenames of HESSI fits images.
;
;	/A_only
;	/F_only: should ALWAYS BE SET, as Afiels are not properly handled (as they have different time_intvs...).
;

PRO hedc_mk_imagetesseract, in, outfile=outfile, A_only=A_only, F_only=F_only, OK=OK
	OK=0
	IF N_ELEMENTS(in) EQ 1 THEN BEGIN		
		eventcode=in
		Ffiles=''
		Afiles=''
		IF NOT KEYWORD_SET(A_only) THEN Ffiles=FINDFILE('/global/hercules/data2/archive/fil/*/HEDC_DP_movF*'+eventcode+'.fits')
		IF NOT KEYWORD_SET(F_only) THEN Afiles=FINDFILE('/global/hercules/data2/archive/fil/*/HEDC_DP_movA*'+eventcode+'.fits')

		startletter='F'
		nenergy=6L
		IF ((Ffiles[0] EQ '') AND (Afiles[0] NE '')) THEN BEGIN
			Ffiles=Afiles
			startletter='A'
			nenergy=5L			
		ENDIF

		IF Ffiles[0] EQ '' THEN BEGIN
			PRINT,'No proper movie files were found, it appears...'
			RETURN
		ENDIF ELSE ntimes=N_ELEMENTS(Ffiles)
	
		epos=STRPOS(Ffiles[0],'mov',33,/REVERSE_OFFSET)+3
		;tpos=STRPOS(Ffiles[0],'frame',33,/REVERSE_OFFSET)+5
		
		files=REPLICATE(STRMID(Ffiles[0],0,epos),ntimes,nenergy)
		FOR i=0L,ntimes-1 DO BEGIN
			FOR j=0L,nenergy-1 DO BEGIN
				files[i,j]=files[i,j]+STRING(BYTE(startletter)+BYTE(j))+'_frame'+int2str(i,4)+'_'+eventcode+'.fits'
			ENDFOR
		ENDFOR
	ENDIF ELSE BEGIN
		files=in
		nenergy=N_ELEMENTS(files[0,*])
		ntimes=N_ELEMENTS(files[*,0])
		get_date,dte,/TIME
		eventcode=time2file(dte,/SEC)
	ENDELSE

	IF NOT KEYWORD_SET(outfile) THEN outfile='hsi_imagetesseract_'+eventcode+'.fits'

;FIRST, read all of 'em to get time_arr and ebands_arr correct (they are written with the first image...)
	times_arr=DBLARR(2,ntimes)
	ebands_arr=DBLARR(2,nenergy)

	FOR i=0L,ntimes-1 DO BEGIN
		FOR j=0L,nenergy-1 DO BEGIN
			imo=hsi_image_fitsread(fitsfile=files[i,j],/OBJ)			
			times_arr[*,i]=imo->get(/absolute_time_range)
			ebands_arr[*,j]=imo->get(/energy_band)
			OBJ_DESTROY,imo
		ENDFOR
	ENDFOR

;SECOND: do the work!	
	FOR i=0L,ntimes-1 DO BEGIN
		FOR j=0L,nenergy-1 DO BEGIN
			imo=hsi_image_fitsread(fitsfile=files[i,j],/OBJ)			
			IF ((i EQ 0) AND (j EQ 0)) THEN BEGIN
				imgdim=imo->get(/image_dim)
				imgtesseract=FLTARR(imgdim[0],imgdim[1],nenergy,ntimes)
				fitscreate=1
			ENDIF ELSE BEGIN
				PTR_FREE,imgtes_ptr
				PTR_FREE,control_ptr
				PTR_FREE,info_ptr				
				fitscreate=0
			ENDELSE
			imgtesseract[*,*,j,i]=imo->getdata()
			imgtes_ptr=PTR_NEW(imgtesseract)
			control_ptr=PTR_NEW(imo->get(/control))
			info_ptr=PTR_NEW(imo->get(/info))				
			saved_data={data:imgtes_ptr,control:control_ptr,info:info_ptr}
			imo->fitswrite,fitsfile=outfile,saved_data=saved_data,times_arr=times_arr,ebands_arr=ebands_arr,CREATE=fitscreate
			OBJ_DESTROY,imo
		ENDFOR
	ENDFOR
	OK=1
END
