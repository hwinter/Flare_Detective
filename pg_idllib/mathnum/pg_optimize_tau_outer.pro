;+
; NAME:
;      pg_optimize_tau_outer
;
; PROJECT:
;      diffusion & acceleration (plasma physics)
;
; PURPOSE: 
;      optimize tau escape array from pivot points from sims
;
;
; CALLING SEQUENCE:
;      ???
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
;       31-JAN-2005 written PG (based on pg_cn_dosim)
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;       pgrigis@astro.phys.ethz.ch
;
;-

PRO pg_optimize_tau_outer_test








END

PRO pg_optimize_tau_outer,inputpar=inputpar,ygrid_tau=ygrid_tau,start_logtau=start_logtau

;start_logtau: alog10 of start_tau, start guess for best tau

;ygrid_tau=[-2,-1.3,1,10]


N=inputpar.steps_per_decade*(inputpar.maxen-inputpar.minen) ; total number of grid points
y=dindgen(N)/(N-1)*(inputpar.maxen-inputpar.minen)+inputpar.minen ; location in eergy of the grid points
                                ; distribuited uniformly in log scale
                                ; new variable y instead of E!
E=10d^y                         ; linear energy grid, old variable E (dimensionless, in units of mc^2)




ytmin=alog10(1./511.)
ytmax=alog10(100./511.)

ygrid_tau_core=findgen(10)/9.*(ytmax-ytmin)+ytmin
ygrid_tau=[min(y),ygrid_tau_core,max(y)]


;start_logtau=replicate(alog10(0.005),n_elements(ygrid_tau))
logtau_core=reverse(findgen(10)/9.*6-4);alog10([1d2,1d-2,1d-4,1d-4])
logtau=[logtau_core[0],logtau_core,logtau_core[n_elements(logtau_core)-1]]


minfactor=alog10(inputpar.dt*inputpar.dimless_time_unit);logtau should excede min (logtau)
maxfactor=4

;max_logtau=


;tau escape check...
;


plot,511*10^ygrid_tau,10^logtau,psym=-6,xrange=[1d-1,1d4],/xlog,/ylog,yrange=[1d-8,1d4]


; Interpolate:  
array_tauescape = 10^interpol(logtau, ygrid_tau, y)  

gamma=1+e
vv=sqrt(1-1/(gamma*gamma))
factor=inputpar.dt*inputpar.dimless_time_unit/array_tauescape*vv

plot,e*511,factor,/xlog,/ylog,yrange=[1d-4,1d1],xrange=[1d-1,1d4],psym=-6




plot,e*511,array_tauescape,/xlog,/ylog,yrange=[1d-5,1d2],xrange=[1d-1,1d4];,psym=-6


a=systime(1)  
pg_optimize_tau_inner,inputpar=inputpar,epiv=epiv,array_tauescape=array_tauescape
b=systime(1)  

print,epiv
print,b-a

IF NOT (finite(epiv)) THEN epiv=1d10


END 



