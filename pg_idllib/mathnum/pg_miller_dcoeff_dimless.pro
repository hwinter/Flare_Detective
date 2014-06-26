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
;
;      y:  energy (or energies) of the test particle, in units of
;          log_10(E/mc^2)
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
FUNCTION pg_miller_dcoeff_dimless,y,eldensity=eldensity,avckomega=avckomega $
                                 ,utdivbyub=utdivbyub,bfield=bfield

utdivbyub=fcheck(utdivbyub,2d-5)
avckomega=fcheck(avckomega,3d)
eldensity=fcheck(eldensity,1d10)
bfield=fcheck(bfield,500d)

c=3d10

alfvenspeed=2.03d11*bfield/(sqrt(eldensity)*c)


e=10^y

gamma=1+e
vv=sqrt(1-1/(gamma*gamma))
p=gamma*vv


mu=alfvenspeed/vv

mc2=8.1871048d-7 ; electron mass times c^2

omegah=4.79d6;1/th

musq=mu*mu

f=-1.25-(1+2*musq)*alog(mu)+musq+0.25*musq*musq


ind=where(vv LE alfvenspeed,count)
IF count GT 0 THEN f[ind]=0.


res=!Dpi/8d *alfvenspeed*alfvenspeed*utdivbyub*avckomega*p*p*f*vv

RETURN,res

END
