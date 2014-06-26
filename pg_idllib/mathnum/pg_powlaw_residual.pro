;+
; NAME:
;      pg_powlaw_residual
;
; PROJECT:
;      diffusion & acceleration (plasma physics)
;
; PURPOSE: 
;      return the special function psi(delta) defined in theory.tex
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
;       27-JUN-2005 written PG
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;
;-

FUNCTION pg_powlaw_residual,par,a_=a,b_=b,c_=c,alpha=alpha,beta=beta,gamma=gamma,e0=e0,e1=e1,n=n $
                           ,fref=fref,eref=eref

delta=par[0]

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

;D=P*(1-delta)/(e1^(1-delta)-e0^(1-delta))
D=fref*eref^delta

;stop

   ;this is the integrand 
integrand=((0.5*A*(alpha-delta)*(alpha-delta-1)*e^(alpha-delta-2)- $
           B*(beta-delta)*e^(beta-delta-1)-C*e^(gamma-delta))*D)^2


;stop

   ;perform the integral
result=int_tabulated(e,integrand)

return,result   

END



;test of integrals...

; N=1000

; alpha=-4.8733d

; x=10^(dindgen(N+1)/(N)*0.01+0.0001)-1.
; y=x^alpha


; plot,x,y,psym=-4

; print,int_tabulated(x,y)
; print,int_tabulated(alog(x),y*x)

; print,(max(x)^(alpha+1)-min(x)^(alpha+1))/(alpha+1)










