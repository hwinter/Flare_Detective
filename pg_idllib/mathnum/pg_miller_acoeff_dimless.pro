;+
; NAME:
;      pg_miller_acoeff
;
; PROJECT:
;      diffusion & acceleration (plasma physics)
;
; PURPOSE: 
;      Return the coefficient A(E) given in Miller (1996)
;
;      
;
; CALLING SEQUENCE:
;     
;
; INPUTS:
;      y: energy in units of log10(E/mc^2)
;   
; OUTPUTS:
;      
;      
; KEYWORDS:
;
;
; HISTORY:
;       14-JUL-2005 written PG
;       15-JUL-2005 computes v (and p) relativistically such that it does
;                   not get larger than c
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;
;-
FUNCTION pg_miller_acoeff_dimless,y,eldensity=eldensity,avckomega=avckomega $
                                 ,bfield=bfield,utdivbyub=utdivbyub

utdivbyub=fcheck(utdivbyub,2d-5)
avckomega=fcheck(avckomega,3d)
bfield=fcheck(bfield,500d)
eldensity=fcheck(eldensity,1d10)

c=3d10

alfvenspeed=2.03d11*bfield/(sqrt(eldensity)*c)

e=10d^y

gamma=1+e
vv=sqrt(1-1/(gamma*gamma))
p=gamma*vv


mu=alfvenspeed/vv

mc2=8.1871048d-7 ; electron mass times c^2
omegah=4.79d6;1/th!!!

logmu=alog(mu)
musq=mu*mu

f=-1.25-(1+2*musq)*logmu+musq+0.25*musq*musq
g=1/(4*gamma*gamma)*(4*musq*logmu-musq*musq+1)+f

ind=where(vv LE alfvenspeed,count)
IF count GT 0 THEN g[ind]=0.

res=0.25*!Dpi*alfvenspeed*alfvenspeed*utdivbyub*avckomega*p*g

RETURN,res

END
