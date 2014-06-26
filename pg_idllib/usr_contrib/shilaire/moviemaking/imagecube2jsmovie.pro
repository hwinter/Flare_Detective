; PSH 2001/10/02 created
;	shilaire@astro.phys.ethz.ch OR psainth@hotmail.com
;
;PURPOSE:
;	Takes an IDL image cube, produces .png image files in outdir directory.
;	Returns list of filenames.
;
;INPUTS:
;	imagecube : an image cube xsize*ysize*nbrframes
;	outdir	: without the ending '/', please!
;
;OPTIONAL INPUT KEYWORDS:
;	fileprefix	: default is 'frame'.
;
;RESTRICTIONS:
;	the imagecube is assumed to have a byte scale
;
;EXAMPLE:
;	imagecube2jsmovie, imagecube, '/global/helene/home/www/staff/shilaire/private/MOVIES/js_19990908_latest', fileprefix=fileprefix
;


PRO imagecube2jsmovie, imagecube, outdir, fileprefix=fileprefix

IF NOT exist(fileprefix) then fileprefix='frame'

TVLCT,r,g,b,/GET
S = Size(imagecube)

imagefiles=-1
FOR i=0, S[3]-1 DO BEGIN
	temp=fileprefix+int2str(i,4)+'.png'
	write_png,outdir+'/'+temp,imagecube(*,*,i),r,g,b
	IF DATATYPE(imagefiles) EQ 'INT' THEN imagefiles=temp ELSE imagefiles=[imagefiles,temp]
ENDFOR

myjsmovie, outdir+'/runme.html',imagefiles

END
