; This routine will take a time interval (anytim) as input,
; check the HESSI flare list for HESSI flares, and put a 
; cleaned PHOENIX spectrogram in an anon ftp directory, to
; be mirrored by Zarro's SDAC.
;
;
;Default is to encode the data in LOG scale, unless keyword /LIN is used.
;

PRO rapp_spg_for_hessi_flarelist, time_intv,	LIN=LIN
	
	IF NOT KEYWORD_SET(LIN) THEN LIN=0
	AnteTime=600.
	PostTime=600.
	;basedir='/global/helene/data/rag/observations/bursts/fits/'
	;basedir='/global/hercules/data3/rag/observations/bursts/fits/'
	basedir='/global/hercules/data3/rag/phoenix-2/bursts/fits/'

	
	flo = OBJ_NEW('hsi_flare_list') 
	flo->set,obs_time_interval=time_intv	
	fl=flo->getdata()	
	IF datatype(fl) EQ 'INT' THEN BEGIN
		PRINT,' No flares in this time interval, according to the flare list '
		RETURN
	ENDIF

	nflares=N_ELEMENTS(fl)
	FOR i=0L,nflares-1 DO BEGIN
	PRINT,'............Trying '+anytim(fl[i].PEAK_TIME,/ECS)
		rapp_start=anytim(fl(i).START_TIME)-AnteTime
		rapp_end=anytim(fl(i).END_TIME)+PostTime
		image=rapp_get_spectrogram([rapp_start,rapp_end],xaxis=xaxis,yaxis=yaxis,/ELIM,/BACK,LOG=1-LIN)	
		IF datatype(image) NE 'STR' THEN BEGIN
			IF NOT KEYWORD_SET(LIN) THEN BEGIN
				image=image > (-9.)
				image=45*alog(image+10)
			ENDIF			

			extime=anytim(fl(i).PEAK_TIME,/EX)
			outdir=basedir+int2str(extime[6],4)+'/'+int2str(extime[5],2)+'/'+int2str(extime[4],2)+'/'
			IF NOT is_dir(outdir) THEN BEGIN
				FILE_MKDIR,outdir
				FILE_CHMOD,outdir,/A_READ
			ENDIF

			filename=outdir+'phnx_'+time2file(anytim(fl(i).PEAK_TIME))+'.fits'
			ragfitswrite, image, xAxis, yAxis, FILENAME = filename,		$
			        DATEOBS = anytim(rapp_start,/ECS,/date_only),		$
					DATEEND = anytim(rapp_end,/ECS,/date_only)
		ENDIF ELSE PRINT,image
	ENDFOR
	OBJ_DESTROY,flo
END
