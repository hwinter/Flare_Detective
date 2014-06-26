; Donwloads all file sfrom SMMDAC matching the pattern, in the appropriate day...
; If outdir is not specified, the it is assumed the files are not to be downloaded, just their number/names examined.
; 'files' OPT. OUTPUT is -1 if no files were available...
;
; EXAMPLE:
;	psh_smmdac_download,'TRACE',wl='195','2003/03/03 '+['21:00','22:00'], files=files		;does not download
;	psh_smmdac_download,'TRACE',wl='195','2003/03/03 '+['21:00','22:00'], files=files, 'TEMP/'	;downloads...
;	psh_smmdac_download,'TRACE',wl='195','2003/10/24 '+['02:20','02:30'], files=files, curdir()+'/TEMP/'	;downloads...
;
;
;	outdir='TEMP/'
;	psh_smmdac_download,'TRACE','2002/08/22 '+['01:40','02:00'], files=files, outdir,wl='195'
;	mapptr=psh_fitsfiles2map(outdir+'/'+files)
;	cube=psh_mapptr2cube(mapptr,xr=[700,900],yr=[-400,-200],/LOG)
;	xstepper,cube
;

PRO psh_smmdac_download, instr,wl=wl,time_intv, outdir, $
			files=files

	IF N_PARAMS() LT 3 THEN NO_DOWNLOAD=1 ELSE NO_DOWNLOAD=0
	CASE STRLOWCASE(instr) OF
		'trace': pattern='trac'
		'eit': pattern='eit'
		'nobeyama': pattern='nobe'
		'mdi': pattern='mdi'
		ELSE: pattern=instr
	ENDCASE

	IF KEYWORD_SET(wl) THEN pattern=pattern+'*'+STRUPCASE(wl)
	pattern=pattern+'*'
	
	ftp=OBJ_NEW('ftp')
	ftp->open,'smmdac.nascom.nasa.gov'
	IF NOT NO_DOWNLOAD THEN ftp->lcd,outdir

	dir=-1
	i=0
	WHILE ( anytim(time_intv[0],/date)+86400*i LE anytim(time_intv[1],/date) ) DO BEGIN
		timex=anytim(anytim(time_intv[0])+86400*i,/EX)	
		IF datatype(dir) EQ 'INT' THEN dir=int2str(timex[6],2)+int2str(timex[5],2)+int2str(timex[4],2) ELSE dir=[dir,int2str(timex[6],2)+int2str(timex[5],2)+int2str(timex[4],2)]
		i=i+1
	ENDWHILE
	
	files=-1
	FOR i=0,N_ELEMENTS(dir)-1 DO BEGIN
		dailyfiles=-1
		ftp->cd,'/pub/data/synoptic/fits/'+dir[i]+'/'
	 	ftp->ls,tmp1
		;for each line of tmp1, extract all substrings separated by spaces, and match them with pattern...
		FOR j=0,N_ELEMENTS(tmp1)-1 DO BEGIN
			tmp2=STRSPLIT(tmp1[j],/EXTRACT)
			FOR k=0,N_ELEMENTS(tmp2)-1 DO BEGIN
				IF STRMATCH(tmp2[k],pattern) THEN BEGIN
					fil=tmp2[k]
					tmp3=file2time(fil)
					IF ((anytim(tmp3) GE anytim(time_intv[0])) AND (anytim(tmp3) LE anytim(time_intv[1]))) THEN BEGIN
						IF datatype(dailyfiles) EQ 'INT' THEN dailyfiles=fil ELSE dailyfiles=[dailyfiles,fil]
					ENDIF
				ENDIF
			ENDFOR			
		ENDFOR
		IF datatype(dailyfiles) NE 'INT' THEN BEGIN
			IF datatype(files) EQ 'INT' THEN files=dailyfiles ELSE files=[files,dailyfiles]
			IF NOT KEYWORD_SET(NO_DOWNLOAD) THEN BEGIN
				ftp->setprop,rfile=dailyfiles,lfile=dailyfiles
				ftp->mget,out
			ENDIF
		ENDIF
	ENDFOR
	OBJ_DESTROY,ftp	

	IF datatype(files) EQ 'INT' THEN PRINT,'No appropriate data files...' ELSE files=files[SORT(files)]	
END
