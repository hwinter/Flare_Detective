;+
; NAME:
;
;   pg_tp_runsim
;
; PURPOSE:
;   run a small simple test particle simulation
;
; CATEGORY:
; 
;   test particle models
;
; CALLING SEQUENCE:
;
;  
;
; INPUTS:
;
;   
;
; OPTIONAL INPUTS:
;
;
;
; KEYWORD PARAMETERS:
;
;
;
; OUTPUTS:
;
;
;
; OPTIONAL OUTPUTS:
;
;
;
; COMMON BLOCKS:
;
;
;
; SIDE EFFECTS:
;
;
;
; RESTRICTIONS:
;
;
;
; PROCEDURE:
;
;
;
; EXAMPLE:
;
;
;
; AUTHOR:
;
;   Paolo Grigis, Institute for Astronomy, ETH, Zurich
;   pgrigis@astro.phys.ethz.ch
;
; MODIFICATION HISTORY:
;
;   17-JAN-2006 written
;
;-

FUNCTION pg_tp_runsim,npart=npart,length=L,seed=seed,taucoll=taucoll $
                ,dt=dt,niter=niter,xh=xh,muh=muh

npart=fcheck(npart,10000L)
taucoll=fcheck(taucoll,2.)
dt=fcheck(dt,0.1)
niter=fcheck(niter,1000L)

L=fcheck(l,20d)

mu=randomu(seed,npart)*2d *!DPi
x=randomu(seed,npart)*L-L/2

vel=replicate(1.,npart)
u=-alog(randomu(seed,npart))
tau=vel*0+taucoll

waitdist=tau*u

nhist=10L

xh=dblarr(npart,nhist)
muh=dblarr(npart,nhist)
j=0

lossn=dblarr(niter)
colln=dblarr(niter)

debug=0

t=0

FOR i=0,niter-1 DO BEGIN 


   IF (i MOD (niter/nhist)) EQ 0 THEN BEGIN
      xh[*,j]=x
      muh[*,j]=mu
      j=j+1
      
      print,'DONE '+smallint2str(i)+' ITERATIONS'
      
   ENDIF


   t=t+dt
   waitdist=waitdist-dt
   
   ;update positions
   x=x+vel*cos(mu)*dt

   ;remove particles which have escaped
   indlost=where((x GT L/2) OR (x LT -L/2),count)
   IF count GT 0 THEN BEGIN
      x[indlost]=randomu(seed,count)*L-L/2
      mu[indlost]=randomu(seed,count)*2d *!DPi
      vel[indlost]=replicate(1.,count)
      waitdist[indlost]=-tau[indlost]*alog(randomu(seed,count))
      lossn[i]=count
   ENDIF

   ;deal with collisions
   indcoll=where(waitdist LE 0.,count)
   IF count GT 0 THEN BEGIN
      mu[indcoll]=randomu(seed,count)*2d *!DPi
      ;vel[indcol]=;replicate(1.,count)
      waitdist[indcoll]=-tau[indcoll]*alog(randomu(seed,count))
      colln[i]=count
   ENDIF


   IF debug EQ 1 THEN BEGIN 
   part_plot,x,mu,vel
   wait,0.2
   ENDIF

ENDFOR

answer={pos:x,mu:mu,lossn:lossn,colln:colln,totaltime:t,npart:npart,niter:niter $
       ,length:l,seed:seed,dtime:dt,taucoll:taucoll}


return,answer





END












