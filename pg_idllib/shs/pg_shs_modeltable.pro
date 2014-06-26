;+
; NAME:
;
; pg_shs_modeltable
;
; PURPOSE:
;
; output a small table with overview info for the different models
; 
;
; CATEGORY:
;
; shs tool
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
; KEYWORD PARAMETERS:
;
;
; OUTPUTS:
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
; Paolo Grigis, Institute of Astronomy, ETH Zurich
; pgrigis@astro.phys.ethz.ch
;
; MODIFICATION HISTORY:
;
; 20-SEP-2004 written PG
; 
;-

forward_function mpfit2dpeak_gauss


PRO pg_shs_modeltable,modpar=modpar,modelname=modelname $
                     ,savindexfile=savindexfile

resolve_routine,'mpfit2dpeak',/either,/compile_full_file

;modelname=fcheck(modelname,['pg_pivpoint','pg_fixedn','pg_fixede','pg_brown'])
modelname=fcheck(modelname,['PIVOT POINT','CONSTANT RATE', $
   'CONSTANT POWER','STOCHASTIC ACCELERATION'])

totnmod=n_elements(modpar)
cs=0.75

switchlist=[1,0,0,1]

xrangelist=dblarr(totnmod,2)
yrangelist=dblarr(totnmod,2)

xrangelist[0,*]=[1d-1, 100]
yrangelist[0,*]=[1d30, 1d45]

xrangelist[1,*]=[1d-1, 100]
yrangelist[1,*]=[1d32, 1d45]

xrangelist[2,*]=[1d-1, 100]
yrangelist[2,*]=[1d34, 1d45]

xrangelist[3,*]=[1d-1, 100]
yrangelist[3,*]=[1d32, 1d45]

lambda=0.5

savst=replicate({model:'',rfitregionind:ptr_new(),dfitregionind:ptr_new()$
                ,r3sigind:ptr_new(),d3sigind:ptr_new()},totnmod)


FOR modeln=0,totnmod-1 DO BEGIN 


   par=*modpar[modeln]

   model=par.model
   savst[modeln].model=model

;   print,'Now doing model '+model


   one=1-switchlist[modeln]
   zero=switchlist[modeln]

   fixind=where(par.parfixed NE 1)
   xparnam='!7e!X!D*!N';par.parnames[fixind[zero]]
   yparnam='N';par.parnames[fixind[one]]

   rparx=par.r_parms[*,fixind[zero]]
   rpary=par.r_parms[*,fixind[one]]
   dparx=par.d_parms[*,fixind[zero]]
   dpary=par.d_parms[*,fixind[one]]

   ;plot of rpar and dpar for this model...


   ;take extreme values away

   IF modeln NE 3 THEN BEGIN 
      indrise =where(rparx GT 1d-1 AND rpary LT 1d45)
      inddecay=where(dparx GT 1d-1 AND dpary LT 1d45)

      savst[modeln].rfitregionind=ptr_new(indrise)
      savst[modeln].dfitregionind=ptr_new(inddecay)

      rparxcut=rparx[indrise]
      rparycut=rpary[indrise]
      
      dparxcut=dparx[inddecay]
      dparycut=dpary[inddecay]

      ;rise
      
      titlestr=strupcase(modelname[modeln])+' MODEL: RISE PHASES'
      parmsr=pg_shs_2dimplotfitdist(rparxcut,rparycut $
         ,title=titlestr,xtitle=xparnam,binoplot=0 $
         ,ytitle=yparnam,lambda=lambda,xrange=xrangelist[modeln,*] $
         ,yrange=yrangelist[modeln,*],status=status,charsize=cs $
         ,yrmin=40d,yrmax=140d,xrmin=-10d,xrmax=10d,xmargin=[10,4])

      oplot,rparxcut,rparycut,psym=8

      ;select in-outlier

      parms=parmsr

      nsigma=3
      lev=parms[0]+parms[1]*exp(-0.5*nsigma^2)
      z=mpfit2dpeak_gauss(alog(rparx), alog(rpary), parms, /tilt)

      indlev=where(z GE lev)
      rparx3sig=rparx[indlev]
      rpary3sig=rpary[indlev]

      savst[modeln].r3sigind=ptr_new(indlev)

      pg_setplotsymbol,'STAR',size=1.
      oplot,rparx3sig,rpary3sig,psym=8

      ;decay

      titlestr=strupcase(modelname[modeln])+' MODEL: DECAY PHASES'
      parmsd=pg_shs_2dimplotfitdist(dparxcut,dparycut $
         ,title=titlestr,xtitle=xparnam ,binoplot=0 $
         ,ytitle=yparnam,lambda=lambda,xrange=xrangelist[modeln,*] $
         ,yrange=yrangelist[modeln,*],status=status,charsize=cs $
         ,yrmin=40d,yrmax=140d,xrmin=-10d,xrmax=10d,xmargin=[10,4])
   
      oplot,dparxcut,dparycut,psym=8



      ;select in-outlier

      parms=parmsd

      nsigma=3
      lev=parms[0]+parms[1]*exp(-0.5*nsigma^2)
      z=mpfit2dpeak_gauss(alog(dparx), alog(dpary), parms, /tilt)

      indlev=where(z GE lev)
      dparx3sig=dparx[indlev]
      dpary3sig=dpary[indlev]

      savst[modeln].d3sigind=ptr_new(indlev)

      pg_setplotsymbol,'STAR',size=1.
      oplot,dparx3sig,dpary3sig,psym=8
   

   ENDIF ELSE BEGIN
      indrise =where(rparx GT 1d-1 AND rpary^2 LT 1d45)
      inddecay=where(dparx GT 1d-1 AND dpary^2 LT 1d45)

      savst[modeln].rfitregionind=ptr_new(indrise)
      savst[modeln].dfitregionind=ptr_new(inddecay)

      rparxcut=rparx[indrise]
      rparycut=rpary[indrise]

      dparxcut=dparx[inddecay]
      dparycut=dpary[inddecay]

      ;rise
   
      titlestr=strupcase(modelname[modeln])+' MODEL: RISE PHASES'
      parmsr=pg_shs_2dimplotfitdist(rparxcut,rparycut^2 $
         ,title=titlestr,xtitle=xparnam,binoplot=0 $
         ,ytitle=yparnam,lambda=lambda,xrange=xrangelist[modeln,*] $
         ,yrange=yrangelist[modeln,*],status=status,charsize=cs $
         ,yrmin=40d,yrmax=140d,xrmin=-10d,xrmax=10d,xmargin=[10,4])

      oplot,rparxcut,rparycut^2,psym=8

      ;select in-outlier

      parms=parmsr

      nsigma=3
      lev=parms[0]+parms[1]*exp(-0.5*nsigma^2)
      z=mpfit2dpeak_gauss(alog(rparx), alog(rpary^2), parms, /tilt)

      indlev=where(z GE lev)
      rparx3sig=rparx[indlev]
      rpary3sig=rpary[indlev]
      savst[modeln].r3sigind=ptr_new(indlev)

      pg_setplotsymbol,'STAR',size=1.
      oplot,rparx3sig,rpary3sig^2,psym=8

      ;decay

      titlestr=strupcase(modelname[modeln])+' MODEL: DECAY PHASES'
      parmsd=pg_shs_2dimplotfitdist(dparxcut,dparycut^2 $
         ,title=titlestr,xtitle=xparnam ,binoplot=0 $
         ,ytitle=yparnam,lambda=lambda,xrange=xrangelist[modeln,*] $
         ,yrange=yrangelist[modeln,*],status=status,charsize=cs $
         ,yrmin=40d,yrmax=140d,xrmin=-10d,xrmax=10d,xmargin=[10,4])
   
      oplot,dparxcut,dparycut^2,psym=8

      ;select in-outlier

      parms=parmsd

      nsigma=3
      lev=parms[0]+parms[1]*exp(-0.5*nsigma^2)
      z=mpfit2dpeak_gauss(alog(dparx), alog(dpary^2), parms, /tilt)

      indlev=where(z GE lev)
      dparx3sig=dparx[indlev]
      dpary3sig=dpary[indlev]
      savst[modeln].d3sigind=ptr_new(indlev)

      pg_setplotsymbol,'STAR',size=1.
      oplot,dparx3sig,dpary3sig^2,psym=8

   ENDELSE


   ellypangle=parmsr[6]-!DPi/2
   rhoriz=sqrt(parmsr[3]^2*sin(ellypangle)^2+parmsr[2]^2*cos(ellypangle)^2)
   rverti=sqrt(parmsr[3]^2*cos(ellypangle)^2+parmsr[2]^2*sin(ellypangle)^2)
   ellypangle=parmsd[6]-!DPi/2
   dhoriz=sqrt(parmsd[3]^2*sin(ellypangle)^2+parmsd[2]^2*cos(ellypangle)^2)
   dverti=sqrt(parmsd[3]^2*cos(ellypangle)^2+parmsd[2]^2*sin(ellypangle)^2)


   print,'------------------------------------------------------------'
   print,'         MODEL '+strupcase(modelname[modeln])
   print,'------------------------------------------------------------'
   print,''
   print,'RISE PHASE'
   print,'   TOTAL # OF POINTS    : '+strtrim(string(n_elements(rparx)),2)
   print,'   POINTS IN FIT SECTOR : '+strtrim(string(n_elements(rparxcut)),2)
   print,'   POINTS IN 3-SIGMA    : '+strtrim(string(n_elements(rparx3sig)),2) 
   print,'   X (LOG) CENTROID     : '+strtrim(string(exp(parmsr[4])),2)
   print,'   Y (LOG) CENTROID     : '+strtrim(string(exp(parmsr[5])),2)
   print,'   AXIS 1--WIDTH        : '+strtrim(string(parmsr[2]),2)
   print,'   AXIS 2--WIDTH        : '+strtrim(string(parmsr[3]),2)   
   print,'   ROTATION ANGLE       : '+strtrim(string(parmsr[6]),2)
   print,'   HORIZONTAL PROJECTION: '+strtrim(string(exp(rhoriz)),2)
   print,'   VERTICAL PROJECTION  : '+strtrim(string(exp(rverti)),2)
   print,''
   print,'DECAY PHASE'
   print,'   TOTAL # OF POINTS    : '+strtrim(string(n_elements(dparx)),2)
   print,'   POINTS IN FIT SECTOR : '+strtrim(string(n_elements(dparxcut)),2)
   print,'   POINTS IN 3-SIGMA    : '+strtrim(string(n_elements(dparx3sig)),2) 
   print,'   X (LOG) CENTROID     : '+strtrim(string(exp(parmsd[4])),2)
   print,'   Y (LOG) CENTROID     : '+strtrim(string(exp(parmsd[5])),2)
   print,'   AXIS 1--WIDTH        : '+strtrim(string(parmsd[2]),2)
   print,'   AXIS 2--WIDTH        : '+strtrim(string(parmsd[3]),2)   
   print,'   ROTATION ANGLE       : '+strtrim(string(parmsd[6]),2)
   print,'   HORIZONTAL PROJECTION: '+strtrim(string(exp(dhoriz)),2)
   print,'   VERTICAL PROJECTION  : '+strtrim(string(exp(dverti)),2)


ENDFOR

IF exist(savindexfile) THEN mwrfits,savst,savindexfile

END


;.comp pg_shs_modeltable
