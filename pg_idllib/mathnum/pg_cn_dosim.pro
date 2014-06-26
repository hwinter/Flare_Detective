;+
; NAME:
;      pg_cn_dosim
;
; PROJECT:
;      diffusion & acceleration (plasma physics)
;
; PURPOSE: 
;      runs a simulation job with an input simpar tructure
;
;
; CALLING SEQUENCE:
;      pg_cn_dosim,inputtpar,dir
;
; INPUTS:
;      simpar: simulation par structure
;      dir: directory used for storing results
;   
; OUTPUTS:
;      
;      
; KEYWORDS:
;       convert: if set, convert electron to photon spectra
;       array_escape: if set, calls pg_tauparam to get an array for
;          the escape time
;
; HISTORY:
;       14-DEC-2005 written PG
;       19-DEC-2005 added convert keyword
;       07-FEB-2005 added array_escape keyword
;       17-MAR-2005 added couple_tau_ut keyword
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;       pgrigis@astro.phys.ethz.ch
;
;-

PRO pg_cn_dosim_test

dir='~/work2/accsimres2/result_run1/'

temp=[2.,5.,10.,20.,50.]
density=[1d9,1d10,1d11]

tauescape=10^(dindgen(10)/(9)*2-4)
avckomega=1d
utdivbyub=10^(dindgen(10)/(9)*1.4-3.2)

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


inputpar={dir:dir,temp:temp,density:density,tauescape:tauescape,avckomega:avckomega, $
          utdivbyub:utdivbyub,clmblog:clmblog,eref:eref,steps_per_decade:steps_per_decade, $
          minen:minen,maxen:maxen,threshold_escape_kev:threshold_escape_kev, $
          collision_strength_scale:collision_strength_scale,niter:niter,dt:dt}

pg_cn_dosim,inputpar

END

PRO pg_cn_dosim,inputpar,convert=convert,preview=preview,array_escape=array_escape $
               ,quiet=quiet,_extra=_extra,couple_tau_ut=couple_tau_ut

 
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

IF keyword_set(couple_tau_ut) THEN BEGIN 
   indtau=where(tagnames EQ 'TAUESCAPE',count1)
   indut =where(tagnames EQ 'UTDIVBYUB',count2)
   IF count1+count2 NE 2 THEN BEGIN
      print,'ERROR! Could not find tag TAUESCAPE or UTDIVBYUB!'
      RETURN
   ENDIF

   utlist=inputpar.utdivbyub
   taulist=inputpar.tauescape

   ntagel[indtau]=1
ENDIF


loopoverind=where(ntagel GT 1,count)

IF count GT 0 THEN BEGIN

   FOR i=1L,ntag-1 DO BEGIN 
      IF ntagel[i] EQ 1 THEN BEGIN 
         IF keyword_set(couple_tau_ut) THEN BEGIN 
            IF i NE indtau THEN $
               onedimpar=add_tag(onedimpar,inputpar.(i),tagnames[i]) $
            ELSE $
               onedimpar=add_tag(onedimpar,0.,tagnames[i])
         ENDIF $
         ELSE $
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
         onedimpar.(loopoverind[k])=(inputpar.(loopoverind[k]))[indexlist[k]]
         print,tagnames[loopoverind[k]],string( onedimpar.(loopoverind[k]))
      ENDFOR


      ;stop

      IF keyword_set(couple_tau_ut) THEN BEGIN 
         
         ind=where(utlist EQ onedimpar.utdivbyub,countutlist)

         IF countutlist NE 1 THEN BEGIN 
            print,'ERROR: value of UTDIVBYUB of '+string(onedimpar.utdivbyub)+' NOT FOUND!'
            RETURN
         ENDIF

         onedimpar.tauescape=taulist[ind]
         print,'TAUESCAPE: ',string(onedimpar.tauescape)
               
      ENDIF

 
      escapeok=onedimpar.dimless_time_unit*onedimpar.dt/onedimpar.tauescape

      IF escapeok GE 1. THEN BEGIN 
         print,'WARNING: escape time too small!'
         plot,[1,2,1],title=string(j)
      ENDIF



      ;stop

      ;do sim            
      etherm=kel2kev(onedimpar.temp*1d6)/onedimpar.eref
      ytherm=alog10(etherm)
      startgrid=onedimpar.density*pg_maxwellian(e,etherm)

      
      IF NOT keyword_set(preview) THEN BEGIN 

        IF keyword_set(array_escape) THEN BEGIN

           print,'VECTOR TAU'
           ;stop
           
  
           tauescape_array=pg_paramtau(onedimpar,/doplot);inputparttrap=onedimpar.esc_ttrap $
                                      ;,estep=onedimpar.esc_estep $
                                      ;,escslope=onedimpar.esc_slope $
                                      ;,tmin=onedimpar.esc_taumin $
                                      ;,tinf=onedimpar.esc_tauinf $
                                      ;,/doplot)
 
           pg_cn_millerfix,startdist=startgrid,ygrid=y,ytherm=ytherm,niter=inputpar.niter $ ;1000L $
                       ,diagnostic=d,accfactor=1. $ 
                       ,xrange=[1d-8,1d10],yrange=[1d-5,1d15],dt=inputpar.dt $ ;1000d $
                       ,avckomega=onedimpar.avckomega,utdivbyub=onedimpar.utdivbyub,/relescape $
                       ,tauescape=onedimpar.tauescape,maxwsrctemp=ytherm,noplot=1 $
                       ,/compensate,density=onedimpar.density,clmblog=onedimpar.clmblog $
                       ,threshold_escape_kev=onedimpar.threshold_escape_kev $
                       ,collision_strength_scale=onedimpar.collision_strength_scale $
                       ,array_tauescape=tauescape_array,quiet=quiet,_extra=_extra;,/quiet;,/debug
           
        ENDIF ELSE BEGIN 

        print,'SCALAR TAU'


        pg_cn_millerfix,startdist=startgrid,ygrid=y,ytherm=ytherm,niter=inputpar.niter $ ;1000L $
                       ,diagnostic=d,accfactor=1. $ 
                       ,xrange=[1d-8,1d10],yrange=[1d-5,1d15],dt=inputpar.dt $ ;1000d $
                       ,avckomega=onedimpar.avckomega,utdivbyub=onedimpar.utdivbyub,/relescape $
                       ,tauescape=onedimpar.tauescape,maxwsrctemp=ytherm,noplot=1 $
                       ,/compensate,density=onedimpar.density,clmblog=onedimpar.clmblog $
                       ,threshold_escape_kev=onedimpar.threshold_escape_kev $
                       ,collision_strength_scale=onedimpar.collision_strength_scale,_extra=_extra
      
        ENDELSE


        pg_savesim,d,savedir=onedimpar.dir
  
       ENDIF


      print,'DONE'
   ENDFOR
ENDIF

IF keyword_set(convert) AND (NOT keyword_set(preview)) THEN pg_convertelres2photsp,onedimpar.dir

END 



