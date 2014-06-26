;+
; NAME:
;      pg_powlaw_phivsdelta
;
; PROJECT:
;      diffusion & acceleration (plasma physics)
;
; PURPOSE: 
;      return the special function phi(delta) defined in theory.tex
;
; EXPLICATION:
;      see theory.tex
;
;
; CALLING SEQUENCE:
;     
;
; INPUTS:
;
;   
; OUTPUTS:
;      
;      
; KEYWORDS:
;
;
; HISTORY:
;       28-JUN-2005 written PG
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;
;-

FUNCTION pg_powlaw_phivsdelta,delta,a_=a,b_=b,c_=c,alpha=alpha,beta=beta,gamma=gamma,e0=e0,e1=e1,n=n $
                           ,fref=fref,eref=eref,eout=e


a=fcheck(a,1.3089367e-06)
alpha=fcheck(alpha,1.8130040)

b=fcheck(b,1.4656473e-06)
beta=fcheck(beta,0.77373934)

c=fcheck(c,0.000236452)
gamma=fcheck(gamma,0.43648745)

e0=fcheck(e0,20./511.)
e1=fcheck(e1,100./511.)

fref=fcheck(fref,1d5)
eref=fcheck(eref,50./511.)

n=fcheck(N,1001)

e=findgen(N+1)/(N)*(e1-e0)+e0


print,a,b,c
print,alpha,beta,gamma
print,e0,e1


D=fref*eref^delta

phi=0.5*A*D*(alpha-delta)*(alpha-delta-1)*e^(alpha-delta-2)- $
        B*D*(beta-delta)*e^(beta-delta-1)- $
        C*D*e^(gamma-delta)


return,phi

END







