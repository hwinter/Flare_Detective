;+
; NAME:
;      pg_miller_acoeff
;
; PROJECT:
;      diffusion & acceleration (plasma physics)
;
; PURPOSE: 
;      Return the coefficient D(E) given in Miller (1996)
;
;      
;
; CALLING SEQUENCE:
;     
;
; INPUTS:
;      e: energy in uniots of mc^2
;   
; OUTPUTS:
;      
;      
; KEYWORDS:
;
;
; HISTORY:
;       14-JUL-2005 written PG
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;
;-
FUNCTION pg_miller_dcoeff,e,eldensity=eldensity;,avckomega=avckomega,utdivbyub=utdivbyub

utdivbyub=fcheck(utdivbyub,0.03)
avckomega=2d-2

c=3d10
;p=sqrt(2*e)
;v=sqrt(2*c*c*e)

;vv=v/c

gamma=1+e
vv=sqrt(1-1/(gamma*gamma))
p=gamma*vv

eldensity=fcheck(eldensity,1d10)
alfvenspeed=2.03d11*500./sqrt(eldensity)/c

mu=alfvenspeed/vv

mc2=8.1871048d-7 ; electron mass times c^2
;th=2.09d-7
omegah=4.79d6

f=-1.25-(1+2*mu^2)*alog(mu)+mu^2+0.25*mu^4
;g=1/(4*gamma^2)*(4*mu^2*alog(mu)-mu^4+1)+f

ind=where(vv LE alfvenspeed,count)
IF count GT 0 THEN f[ind]=0.

;res=mc2^2*omegah*!Dpi/16.*alfvenspeed^2*utdivbyub*avckomega*p*p*f*2*vv
res=!Dpi/16.*alfvenspeed^2*utdivbyub*avckomega*p*p*f*2*vv

RETURN,res

END
