;PSH 2001/10/03
;
;should be run from IDL 5.4  (because of the /ORDER keyword...)
;
; MODIFIED: 2002/12/12, PSH. /ORDER is now a keyword (in case I want to pass them to IDL 5.3 or earlier...).

PRO imagecube2png, imagecube, outdir, fileprefix=fileprefix, ORDER=ORDER

IF NOT exist(fileprefix) then fileprefix='frame'

TVLCT,r,g,b,/GET
S = Size(imagecube)

FOR i=0, S[3]-1 DO BEGIN
        temp=fileprefix+int2str(i,4)+'.png'
        write_png,outdir+'/'+temp,imagecube(*,*,i),r,g,b,ORDER=ORDER
ENDFOR

END

