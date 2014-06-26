;+
; NAME:
;      pg_optimize_tau
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

PRO pg_optimize_tau_test

dir='~/work2/tauoptimize/'

temp=10.;[1.,2.,5.,10.,25.,50.]
density=1d10;[1d9,1d10,1d11]
threshold_escape_kev=0.;[0.,1.,10.,50.,100.]

tauescape=1d-2;10^(dindgen(10)/(9)*3-4.5)
avckomega=1d
utdivbyub=10^(dindgen(5)/(4)-3)

clmblog=18.

eref=510.99892d

steps_per_decade=1000            ;number of grid points in a decade of energy
steps_per_decade=30            ;number of grid points in a decade of energy
minen=-18                        ;log_10 of the minimum energy in problem, in this case 10E-8 mc^2
maxen=10d                         ;log_10 of the maximum energy in problem, in this case 10E1  mc^2

;threshold_escape_kev=0.
collision_strength_scale=1.

niter=800L
dt=250.

inputpar={dir:dir,temp:temp,density:density,tauescape:tauescape,avckomega:avckomega, $
          utdivbyub:utdivbyub,clmblog:clmblog,eref:eref,steps_per_decade:steps_per_decade, $
          minen:minen,maxen:maxen,threshold_escape_kev:threshold_escape_kev, $
          collision_strength_scale:collision_strength_scale,niter:niter,dt:dt, $
          dimless_time_unit:2.09d-7}




testtau=byte(floor(256*randomu(seed,10,3)))

epivlist=pg_optimize_tau(testtau,inputpar=inputpar,time_out=time_out)

END

FUNCTION pg_optimize_tau,tauval,inputpar=inputpar,time_out=time_out

stauval=size(tauval)

nbins=stauval[1];number of energy bins for tau
npop=stauval[2];number of individul tau parameters to be evaluated


;energy grid computation
N=inputpar.steps_per_decade*(inputpar.maxen-inputpar.minen) ; total number of grid points
y=dindgen(N)/(N-1)*(inputpar.maxen-inputpar.minen)+inputpar.minen ; location in eergy of the grid points
                                ; distribuited uniformly in log scale
                                ; new variable y instead of E!
E=10d^y                         ; linear energy grid, old variable E (dimensionless, in units of mc^2)


;boundaries for tau
mintau=alog10(inputpar.dt*inputpar.dimless_time_unit);logtau should excede min (logtau)
mintau=mintau+abs(mintau*0.05)
maxtau=4.

;energy corresponding to the tau bins
ytmin=alog10(1./511.)
ytmax=alog10(100./511.)

ygrid_tau_core=findgen(nbins)/(nbins-1.)*(ytmax-ytmin)+ytmin
ygrid_tau=[min(y),ygrid_tau_core,max(y)]


epiv_out=fltarr(npop)
time_out=fltarr(npop)

FOR i=0,npop-1 DO BEGIN 

thistau=tauval[*,i]


;transform byte encoded tau to logarithm of tau
logtau_core=float(thistau)/256.*(maxtau-mintau)+mintau
logtau=[logtau_core[0],logtau_core,logtau_core[n_elements(logtau_core)-1]]


;plot,511*10^ygrid_tau,10^logtau,psym=-6,xrange=[1d-1,1d4],/xlog,/ylog,yrange=[1d-8,1d4]


; Interpolate tau to real tau
array_tauescape = 10^interpol(logtau, ygrid_tau, y)  

;gamma=1+e
;vv=sqrt(1-1/(gamma*gamma))
;factor=inputpar.dt*inputpar.dimless_time_unit/array_tauescape*vv
;plot,e*511,factor,/xlog,/ylog,yrange=[1d-4,1d1],xrange=[1d-1,1d4],psym=-6
;plot,e*511,array_tauescape,/xlog,/ylog,yrange=[1d-5,1d2],xrange=[1d-1,1d4];,psym=-6


a=systime(1)  
pg_optimize_tau_inner,inputpar=inputpar,epiv=epiv,array_tauescape=array_tauescape
b=systime(1)  

;print,epiv
;print,b-a
time_out[i]=b-a

IF NOT (finite(epiv)) THEN epiv_out[i]=1d6 ELSE epiv_out[i]=epiv

ENDFOR

RETURN,epiv_out

;return abs(epiv - goal_epiv)

END 



