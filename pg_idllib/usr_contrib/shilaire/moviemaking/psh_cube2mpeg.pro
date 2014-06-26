;To produce an MPEG movie file from an IDL>5.3 session...
;
;This routine will take an imagecube (assumes current r,g,b), 
;save them a fits file in the TEMP directory on hercules (which must be NFS-accessible from local host!),
;then SPAWN an IDL 5.3 session on hercules to transform it into an mpeg file,
;which will be saved as temporarily in tmpdir. It will then be moved to 'movie_fullpathname' (of course, accessible from local host)...
;And the tmp fits file and mpeg file will be erased...
;
; EXAMPLE:
;	psh_cube2mpeg, cube, 'scratch.mpg'	
;

PRO psh_cube2mpeg, cube, movie_fullpathname, tmpdir=tmpdir

	rsh_host='hercules'
	;rsh_host='hercules-aw'

	IF NOT KEYWORD_SET(tmpdir) THEN tmpdir='/global/hercules/users/shilaire/TEMP'	
	tmpfil=tmpdir+'/images_'+time2file(systim2anytim(),/SEC)
	
	TVLCT,r,g,b,/GET
	mwrfits,{data:cube},tmpfil+'.fits'

	;put fits file name into the latest_psh_cube2mpeg__idl53part.txt file on hercules, to be later read by the SPAWN job
	cmd='rsh '+rsh_host+' echo '+tmpfil+' > /global/hercules/users/shilaire/latest_psh_cube2mpeg__idl53part.txt'
	SPAWN,cmd,res,err
	IF err[0] NE '' THEN BEGIN
		PRINT,'........Error message from "'+cmd+'" SPAWN job:'
		PRINT,err		
	ENDIF
	
	cmd='rsh '+rsh_host+' /ftp/pub/hedc/fs/data1/rapp_idl/shilaire/psh_ssw53_exec psh_cube2mpeg__idl53part "<"/dev/null ">&"/dev/null'
	SPAWN,cmd,res,err
	IF err[0] NE '' THEN BEGIN
		PRINT,'........Error message from "'+cmd+'" SPAWN job:'
		PRINT,err
	ENDIF	

	IF GETENV('HOSTNAME') NE '' THEN thehostname=GETENV('HOSTNAME') ELSE thehostname='pandora'
	cmd='rsh hercules rcp '+tmpfil+'.mpg '+thehostname+':'+movie_fullpathname
	SPAWN,cmd,res,err
	IF err[0] NE '' THEN BEGIN
		PRINT,'........Error message from "'+cmd+'" SPAWN job:'
		PRINT,err
	ENDIF
			
	FILE_DELETE, tmpfil+'*'
	FILE_DELETE, tmpfil+'*'
	FILE_DELETE, tmpfil+'*'
	FILE_DELETE, tmpfil+'*'
	PRINT,'.............................psh_cube2mpeg.pro completed without crashing...'
END

