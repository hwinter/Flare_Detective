; This script is called from a batch job engendered by a call to psh_cube2mpeg.pro in an IDL session > 5.3
;-------------------------------------------------------------------------------------------------------------------------
tmpfil=(rd_ascii('/global/hercules/users/shilaire/latest_psh_cube2mpeg__idl53part.txt'))[0]
HELP,tmpfil

IF tmpfil EQ '' THEN BEGIN
	PRINT,'................image fits file was not specified in  /global/hercules/users/shilaire/latest_psh_cube2mpeg__idl53part.txt ! .... ABORTING GRACEFULLY...'
ENDIF ELSE BEGIN
	set_plot,'Z'	;IMPORTANT, otherwise, job hangs!!!!
	;right now, I'm supposing I'm using the following color table:
	LOADCT,1
	rainbow_linecolors
	TVLCT,r,g,b,/GET
	DEVICE,/CLOSE
	
	tmp=mrdfits(tmpfil+'.fits',1)
	break_file, tmpfil+'.fits', DISK_LOG, DIR, FILNAM, EXT, FVERSION, NODE
	image2movie, tmp.data, /mpeg,r,g,b, movie_name=tmpfil+'.mpg', scratchdir=dir
	;mpeg_maker,tmp.data,filename=tmpfil+'.mpg'
ENDELSE
END
