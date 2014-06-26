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
;   19-JAN-2006 written
;
;-

FUNCTION pg_runsim2,npart=npart,tcoll=tcoll,seed=seed $
                ,dx=dx,dt=dt,niter=niter,xh=xh,muh=muh $
                ,pup=pup,pdown=pdown,expomodel=expomodel $
                ,debug=debug

npart=fcheck(npart,10000L)

tcoll=fcheck(tcoll,1.)

dt=fcheck(dt,0.01)
dx=fcheck(dx,1.)

x=fltarr(npart)

x[*]=0.


niter=fcheck(niter,10000L)

avup=fltarr(niter)
avdown=fltarr(niter)


pup=fcheck(pup,0.5)
pdown=fcheck(pdown,0.5)

mom=dblarr(4,niter)

oldp=!P
!P.multi=[0,1,2]

if keyword_set(expomodel) then begin 

    print,'EXPO MODEL!'
   
    waitlist=-tcoll*alog(randomu(seed,npart))



for i=0L,niter-1 do begin 
    mom[*,i]=moment(x)
    ;y[i]=x[1000]
    if i mod 1000L EQ 0 then begin 
        print,i
        ;pg_plot_histo,x,min=-50,max=50,binsize=1
        ;wait,0.5
    endif
    waitlist=waitlist-dt
    indcoll=where(waitlist LE 0.,count)
    if count GT 0 then begin 
        waitlist[indcoll]=-tcoll*alog(randomu(seed,count))

        coin=randomu(seed,npart)
        indup=where(coin LE pup,countup)
        inddown=where( (coin LE pup+pdown) AND (coin GT pup),countdown)

;        coin=randomu(seed,count)
;        indup=where(coin LE pup,countup);,complement=inddown,ncomplement=countdown)
;        coin=randomu(seed,count)
;        inddown=where(coin LE pdown,countdown);,complement=inddown,ncomplement=countdown)
        ;stop
        if countup GT 0 then x[indcoll[indup]]=x[indcoll[indup]]+dx
        if countdown GT 0 then x[indcoll[inddown]]=x[indcoll[inddown]]-dx
    endif
endfor


endif else begin 

for i=0L,niter-1 do begin 
    mom[*,i]=moment(x)
    ;y[i]=x[1000]
    if i mod 100L EQ 0 then begin 
        print,i

        if keyword_set(debug) then begin 
        pg_plot_histo,x,min=-50,max=50,binsize=1
        plot,findgen(niter),mom[1,*]
        wait,0.5
        endif

        ;wait,0.5
    endif
;    waitlist=waitlist-dt
;    indcoll=where(waitlist LE 0.,count)
;    if count GT 0 then begin 
;        waitlist[indcoll]=-tcoll*alog(randomu(seed,count))
 
    coin=randomu(seed,npart)
    indup=where(coin LE pup,countup)
    inddown=where( (coin LE pup+pdown) AND (coin GT pup),countdown)

    if countup GT 0 then x[indup]=x[indup]+dx
    if countdown GT 0 then x[inddown]=x[inddown]-dx
 
    avup[i]=countup
    avdown[i]=countdown
  

endfor

endelse



answer={pos:x,npart:npart,niter:niter,pup:pup,pdown:pdown,dt:dt $
       ,seed:seed,dtime:dt,dx:dx,tcoll:tcoll,mom:mom,avup:avup,avdown:avdown}


return,answer



END












