;+
;Will download EIT files during a certain time interval, and return the file list.
;
; EX:
;	files=psh_eit_download('2005/01/01 '+['00:00:00','01:00:00'],wave='all',/NODOWNLOAD)
;
;	files=psh_eit_download('2005/01/01 '+['00:00:00','01:00:00'], ldir='TEMP')
;	mapptr=psh_fits2map(files)
;	plot_map,*mapptr[0],/LOG
;-

FUNCTION psh_eit_download, time_intv, ldir=ldir, wavel=wavel, NODOWNLOAD=NODOWNLOAD, uname=uname

	timeout='180'	;in seconds, a string, please!

	IF NOT KEYWORD_SET(ldir) THEN ldir=curdir()	;GETENV('HOME')
	IF NOT KEYWORD_SET(wavel) THEN wave='195' ELSE wave=strn(wavel)
	IF NOT KEYWORD_SET(uname) THEN uname='hedc'

	months=['January','February','March','April','May','June','July','August','September','October','November','December']

;1) parameters for http form request:
	extim=anytim(time_intv[0],/EX)
	start_year=strn(extim[6])
	start_month=months[extim[5]-1]
	start_day=strn(extim[4])
	start_hour=strn(extim[0])+':00'

	extim=anytim(time_intv[1],/EX)
	IF TOTAL(extim[1:3]) NE 0 THEN extim=anytim(anytim(time_intv[1])+3600,/EX)
	
	stop_year=strn(extim[6])
	stop_month=months[extim[5]-1]
	stop_day=strn(extim[4])
	stop_hour=strn(extim[0])+':00'

	PRINT,'........psh_eit_download.pro: '+start_day+' '+start_month+' '+start_year+' '+start_hour+' to '+stop_day+' '+stop_month+' '+stop_year+' '+stop_hour+': '+wave+' files.'

	form_cmds='"start_year='+start_year+'" "start_month='+start_month+'" "start_day='+start_day+'" "start_hour='+start_hour+'" "stop_year='+stop_year+'" "stop_month='+stop_month+'" "stop_day='+stop_day+'" "stop_hour='+stop_hour+'"
	form_cmds=form_cmds+' "xsize=all" "ysize=all"'
	form_cmds=form_cmds+' "wave='+wave+'"'
	form_cmds=form_cmds+' "filter=all" "object=all" "xbin=all" "ybin=all" "fovx=" "fovy=" "sciobj=" "highc=all"'
	
	;herk_cmdline='rsh hercules /usr/local/bin/w3c -post http://umbra.nascom.nasa.gov/cgi-bin/eit-catalog.cgi -form '+form_cmds
	herk_cmdline='rsh hercules /usr/local/bin/w3c -n -timeout '+timeout+' -post http://umbra.nascom.nasa.gov/cgi-bin/eit-catalog.cgi -form '+form_cmds
	SPAWN,herk_cmdline, res, err, count=count, exit_status=exit_status
	PRINT,err
	WAIT,10

;2) Analysing answer and second form...
	ss1=(WHERE(res EQ '<INPUT TYPE="checkbox" NAME=alldata" VALUE="'))[0]
	IF ss1 EQ -1 THEN BEGIN
		PRINT,'........psh_eit_download.pro: No '+wave+' files found, it seems. Retrying to be sure...'
		SPAWN,herk_cmdline, res, err, count=count, exit_status=exit_status
		PRINT,err
		WAIT,10
		ss1=(WHERE(res EQ '<INPUT TYPE="checkbox" NAME=alldata" VALUE="'))[0]
		IF ss1 EQ -1 THEN BEGIN
			PRINT,'........psh_eit_download.pro: No, really no '+wave+' files found. Returning -1...'		
			RETURN,-1
		ENDIF
	ENDIF
	PRINT, str_match(res,'ALL LISTED FILES',found=found)
	IF found[0] EQ -1 THEN BEGIN
		PRINT,'........psh_eit_download.pro: Looks like there might be a problem on their side... Returning -1...'
		RETURN,-1 
	ENDIF ELSE ss2=found[0]
	PRINT,".........# of EIT files: "+strn(ss2-ss1-1)

	IF KEYWORD_SET(NODOWNLOAD) THEN RETURN,res[ss1+1:ss2-1]

	form_cmds='"alldata='+res[ss1+1]
	FOR i=ss1+2,ss2-1 DO form_cmds=form_cmds+' '+res[i]
	FOR i=ss1+1,ss2-1 DO PRINT,res[i]
	form_cmds=form_cmds+'"'
	form_cmds=[form_cmds,'"a_lastname='+uname+'"','"d_email=hedc@astro.phys.ethz.ch"']
	;herk_cmdline=["rsh","hercules","/usr/local/bin/w3c","-post","http://umbra.nascom.nasa.gov/cgi-bin/download.cgi","-form",form_cmds]
	herk_cmdline=["rsh","hercules","/usr/local/bin/w3c","-n","-timeout",timeout,"-post","http://umbra.nascom.nasa.gov/cgi-bin/download.cgi","-form",form_cmds]
	SPAWN,herk_cmdline, res2, err, count=count, exit_status=exit_status,/NOSHELL
	PRINT,err
	WAIT,10
	
;3) Get ftp path and filename of file to download
	ligne=str_match(res2,"ftp://")
	IF ligne EQ '' THEN BEGIN
		PRINT,'........psh_eit_download.pro: No ftp file, it seems. Retrying to be sure...'
		SPAWN,herk_cmdline, res2, err, count=count, exit_status=exit_status,/NOSHELL
		PRINT,err
		WAIT,10
		ligne=str_match(res2,"ftp://")
		IF ligne EQ '' THEN BEGIN
			PRINT,'........psh_eit_download.pro: No, really no ftp file. Returning -1...'
			RETURN,-1
		ENDIF
	ENDIF
	ss1=STRPOS(ligne,"ftp://")
	ss2=STRPOS(ligne,">")
	r_path=STRMID(ligne,ss1,ss2-ss1)

	ligne=str_match(res2,".tar.gz")
	remchar,ligne,' '
	IF ligne EQ '' THEN BEGIN
		PRINT,'........psh_eit_download.pro: No .tar.gz file, it seems!'
		RETURN,-1
	ENDIF
	ss1=STRPOS(ligne,"eit_")
	ss2=7+STRPOS(ligne,".tar.gz")
	file_name=STRMID(ligne,ss1,ss2-ss1)

;4) DOWNLOAD the stuff on the local directory
	PRINT,'...Attempting to download '+file_name
	break_url, r_path+file_name, server, path, file, ftp=isftp, http=ishttp
	IF isftp THEN BEGIN
		ftp=OBJ_NEW('ftp')
		ftp->pass,'hedc@astro.phys.ethz.ch'
		ftp->lcd,ldir
		ftp->open,server
		ftp->cd,path
		ftp->setprop,rfile=file,lfile=file
		ftp->verbose
		ftp->mget,out
		OBJ_DESTROY,ftp
		IF out EQ '' THEN BEGIN
			PRINT,'........psh_eit_download.pro: FTP transfer seemed unsuccessful!'
			RETURN,-1
		ENDIF
	ENDIF ELSE BEGIN
		PRINT,'........psh_eit_download.pro: Path is not an ftp path, it seems!'
		RETURN,-1
	ENDELSE

	files=-1
;5) If file is gzipped, unzip it!
	IF STRMID(file,2,/REVERSE) EQ '.gz' THEN BEGIN
		SPAWN,'gunzip '+ldir+'/'+file, res, err, count=count, exit_status=exit_status
		SPAWN,['rm','TEMP/'+file], res, err, count=count, exit_status=exit_status, /NOSHELL
		file=STRMID(file,0,STRLEN(file)-3)
	ENDIF

;6) If file is tared, untar it!
	IF STRMID(file,3,/REVERSE) EQ '.tar' THEN BEGIN
		SPAWN,'tar xvf '+ldir+'/'+file, files, err, count=count, exit_status=exit_status
		SPAWN,['rm','TEMP/'+file], res, err, count=count, exit_status=exit_status, /NOSHELL
	ENDIF
RETURN,files
END



