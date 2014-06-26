;+
; NAME:
;      pg_optimize_tau_inner
;
; PROJECT:
;      diffusion & acceleration (plasma physics)
;
; PURPOSE: 
;      runs a batch of simulations and find the pivot point
;
; CALLING SEQUENCE:
;      ???
;
; INPUTS:
;      simpar: simulation par structure
;      dir: directory used for storing results
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

PRO pg_optimize_tau_inner_test

dir='~/work2/tauoptimize/'

temp=10.;[2.,5.,10.,20.,50.]
density=1d10;[1d9,1d10,1d11]

tauescape=0.01;10^(dindgen(10)/(9)*2-4)
avckomega=1d
;utdivbyub=10^(dindgen(10)/(9)*1.4-3.2)
utdivbyub=10^(dindgen(5)/(9)*1.4-3.2)

clmblog=18.

eref=510.99892d

steps_per_decade=1000            ;number of grid points in a decade of energy
steps_per_decade=30            ;number of grid points in a decade of energy
minen=-18                        ;log_10 of the minimum energy in problem, in this case 10E-8 mc^2
maxen=10d                         ;log_10 of the maximum energy in problem, in this case 10E1  mc^2

threshold_escape_kev=0.
collision_strength_scale=1.

niter=1000L
dt=1000.

;N=inputpar.steps_per_decade*(inputpar.maxen-inputpar.minen) ; total number of grid points
;size needed for tauescape_array

inputpar={dir:dir,temp:temp,density:density,tauescape:tauescape,avckomega:avckomega, $
          utdivbyub:utdivbyub,clmblog:clmblog,eref:eref,steps_per_decade:steps_per_decade, $
          minen:minen,maxen:maxen,threshold_escape_kev:threshold_escape_kev, $
          collision_strength_scale:collision_strength_scale,niter:niter,dt:dt}

pg_optimize_tau_inner,inputpar=inputpar;,/preview

END

PRO pg_optimize_tau_inner,inputpar=inputpar,photonpar=photonpar $
                         ,array_tauescape=array_tauescape,preview=preview $
                         ,epiv=epiv,elepiv=elepiv,thick_epiv=thick_epiv


onedimpar={dir:inputpar.dir}


N=inputpar.steps_per_decade*(inputpar.maxen-inputpar.minen) ; total number of grid points
y=dindgen(N)/(N-1)*(inputpar.maxen-inputpar.minen)+inputpar.minen ; location in eergy of the grid points
                                ; distribuited uniformly in log scale
                                ; new variable y instead of E!
E=10d^y                         ; linear energy grid, old variable E (dimensionless, in units of mc^2)


tagnames=tag_names(inputpar)
ntag=n_elements(tagnames)

ntagel=lonarr(ntag)

FOR i=0,ntag-1 DO ntagel[i]=n_elements(inputpar.(i))

loopoverind=where(ntagel GT 1,count)

IF count GT 0 THEN BEGIN

   FOR i=1L,ntag-1 DO BEGIN 
      IF ntagel[i] EQ 1 THEN BEGIN 
         onedimpar=add_tag(onedimpar,inputpar.(i),tagnames[i])
      ENDIF $ 
      ELSE BEGIN
         onedimpar=add_tag(onedimpar,(inputpar.(i))[0],tagnames[i])
      ENDELSE

   ENDFOR


 
   nsim=product(ntagel[loopoverind])
   values=dblarr(count,nsim)
   FOR j=0L,nsim-1 DO BEGIN 
      indexlist=pg_juggleindex(ntagel[loopoverind],j)
      print,'Now doing simulation run '+string(j)
      FOR k=0,count-1 DO BEGIN 
         print,tagnames[loopoverind[k]],string((inputpar.(loopoverind[k]))[indexlist[k]])
         onedimpar.(loopoverind[k])=(inputpar.(loopoverind[k]))[indexlist[k]]
      ENDFOR


      ;stop

      ;do sim            
      etherm=kel2kev(onedimpar.temp*1d6)/onedimpar.eref
      ytherm=alog10(etherm)
      startgrid=onedimpar.density*pg_maxwellian(e,etherm)

      
      IF NOT keyword_set(preview) THEN BEGIN 
        pg_cn_millerfix,startdist=startgrid,ygrid=y,ytherm=ytherm,niter=inputpar.niter $ ;1000L $
                       ,diagnostic=d,accfactor=1. $ 
                       ,xrange=[1d-8,1d10],yrange=[1d-5,1d15],dt=inputpar.dt $ ;1000d $
                       ,avckomega=onedimpar.avckomega,utdivbyub=onedimpar.utdivbyub,/relescape $
                       ,tauescape=onedimpar.tauescape,maxwsrctemp=ytherm,noplot=1 $
                       ,/compensate,density=onedimpar.density,clmblog=onedimpar.clmblog $
                       ,threshold_escape_kev=onedimpar.threshold_escape_kev $
                       ,collision_strength_scale=onedimpar.collision_strength_scale $
                       ,array_tauescape=array_tauescape,/quiet,/debug
      


        pg_savesim,d,savedir=onedimpar.dir
  
       ENDIF


      print,'DONE'
   ENDFOR
ENDIF

;convert spectra
IF  NOT keyword_set(preview) THEN BEGIN 

   pg_convertelres2photsp,onedimpar.dir,phspectra=phspectra,/nosave;,/quiet;


   ;stop
   spawn,'rm ~/work2/tauoptimize/*'
   ;stop

   spres=pg_phspectratoindex(phspectra)

   ;stop

;   IF keyword_set(electron) THEN BEGIN 
      thispivdata2=pg_findpivot(spres.el_spindex,spres.el_fnorm,spres.el_enorm)
;   ENDIF ELSE BEGIN       
      thispivdata1=pg_findpivot(spres.spindex_thin,spres.fnorm_thin,spres.enorm)
;   ENDELSE 
      thispivdata3=pg_findpivot(spres.spindex_thick,spres.fnorm_thick,spres.enorm)


plot,spres.fnorm_thin,spres.spindex_thin,psym=-6,/xlog,xrange=[1d-8,1d2]


   epiv=thispivdata1.epiv
   thick_epiv=thispivdata3.epiv
   elepiv=thispivdata2.epiv

ENDIF



END 



