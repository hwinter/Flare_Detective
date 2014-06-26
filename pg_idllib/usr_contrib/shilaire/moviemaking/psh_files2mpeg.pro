;+
;	PSH 2005/02/18
;
;	The filepattern and moviefile must be NFS-accessible from pandora, if /PANDORA is set.
;	Careful with the movie filename: The extension determines what kind of movie it'll be! (i.e. .gif -> GIF animation...)
;
;	EXAMPLE:
;		psh_files2mpeg, '*.gif'
;		psh_files2mpeg, '/global/helene/home/shilaire/*.png',/PANDORA
;		psh_files2mpeg, '/global/saturn/data/www/staff/shilaire/private/MOVIES/js_19990908_sxt_smoothed/*.png',moviefile='/global/helene/home/shilaire/movie.mpg',/PANDORA
;
;-

PRO psh_files2mpeg, filepattern, moviefile=moviefile, PANDORA=PANDORA, quality=quality
	IF NOT KEYWORD_SET(moviefile) THEN moviefile=GETENV('HOME')+'/movie.mpg'
	
	spawn_cmd='convert '+filepattern
	IF KEYWORD_SET(quality) THEN spawn_cmd=spawn_cmd+' -quality '+strn(quality)
	spawn_cmd=spawn_cmd+' '+moviefile
	
	IF KEYWORD_SET(PANDORA) THEN spawn_cmd='rsh pandora "setenv PATH ${PATH}:/usr/local/mpeg-2/mpeg2/src/mpeg2enc ; '+spawn_cmd+'"'
				;spawn_cmd='rsh pandora "'+spawn_cmd+'"'

	SPAWN,spawn_cmd,res,err,count=count,exit_status=exit_status
	PRINT,err
END
