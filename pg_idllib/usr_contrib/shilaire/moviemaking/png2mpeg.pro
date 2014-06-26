;PSH 2001/10/03
;
;assumes all images are same size!!!
;should be run from IDL 5.3.1
;
;
;
; MODIFICATIONS: 
;	PSH 2002/03/12 : added MULT keyword. Set it to a positive integer: the number
;						of frames will be multiplied by this number.
;
;	


PRO png2mpeg, indir, fileprefix=fileprefix, outmpegfile=outmpegfile, mult=mult

IF NOT exist(fileprefix) then fileprefix='frame'
IF NOT exist(outmpegfile) then outmpegfile='/global/helene/home/www/staff/shilaire/private/MOVIES/scratch.mpg'

firstimage=read_png(indir+'/'+fileprefix+'0000.png',r,g,b)
tvlct,r,g,b
S=size(firstimage)

nbr=1
WHILE file_exist(indir+'/'+fileprefix+int2str(nbr,4)+'.png') DO nbr=nbr+1

imagecube=bytarr(S[1],S[2],nbr)
imagecube(*,*,0)=firstimage

FOR i=1,nbr-1 DO imagecube(*,*,i)=read_png(indir+'/'+fileprefix+int2str(i,4)+'.png')

IF KEYWORD_SET(mult) THEN BEGIN
	multcube=bytarr(S[1],S[2],nbr*mult)
		FOR i=0,nbr-1 DO BEGIN
			FOR j=0,mult-1 DO multcube(*,*,mult*i+j)=imagecube(*,*,i)
		ENDFOR
	imagecube=multcube
ENDIF

mpeg_maker, imagecube, filename=outmpegfile
END
