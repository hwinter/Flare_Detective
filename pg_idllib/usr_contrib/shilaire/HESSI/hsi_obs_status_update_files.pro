
;checks whether current day file is in /global/hercules/data1/hessi/obs_times/. 
;If not, will download it.

; 2002/12/15: added keyword /FORCE + other improvements


PRO hsi_obs_status_update_files,anyday,dir=dir, FORCE=FORCE
	
	IF NOT KEYWORD_SET(dir) THEN dir='/global/hercules/data1/hessi/obs_times/'

	IF NOT KEYWORD_SET(FORCE) THEN bla=hsi_obs_status(anytim(anyday,/date)+[0.,86399.],/NIGHT) ELSE bla=-1

	IF bla EQ -1 THEN BEGIN
		PRINT,'WILL DOWNLOAD FILE...'
		yydoy=ut_2_yydoy(anytim(anyday))
		extim=anytim(anyday,/EX)			

		;1/ Send CGI request
		;example CGI-BIN: http://hessi.ssl.berkeley.edu/cgi-bin/soc/index.pl/saa_ecl.pl?month=3&dom=1&year=2002
		base_cgi='http://hessi.ssl.berkeley.edu/cgi-bin/soc/index.pl/saa_ecl.pl'
		add_cgi='month='+strn(extim[5])+'&dom='+strn(extim[4])+'&year='+strn(extim[6])
		full_cgi_url=base_cgi+'?'+add_cgi
		sock_list,base_cgi,output,/CGI		;knock on the door
		WAIT,10.
		sock_list,full_cgi_url,output,/CGI	;request
		WAIT,10.
		
		;2/ Retrieve filename
		;example url: http://hessi.ssl.berkeley.edu/soc/SAA_ECL/HESSI_02208_DUREVT.00		
		tmp=grep('DUREVT',output)
		tmp=rsi_strsplit(tmp[0],'"',/EXTRACT)
		url=tmp[1]
		PRINT,'URL to retrieve: '+url

		;3/ Copy file here.
		sock_copy,url,out_dir=dir
		
		;4/ Check on size of the file. If it is zero, delete it.
		break_url, url, server, path, filename
		IF FILE_TEST(dir+filename,/ZERO_LENGTH) THEN BEGIN			
			FILE_DELETE,dir+filename
			PRINT,'....... downloaded file had zero length... deleting...
		ENDIF
				
	ENDIF ELSE PRINT,'NO NEED TO DOWNLOAD NEW FILE FOR '+dir
END
