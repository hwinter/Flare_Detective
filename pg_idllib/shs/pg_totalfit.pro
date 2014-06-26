;+
; NAME:
;
; pg_totalfit
;
; PURPOSE:
;
; fits a given model to the data for all phases, all flares and all points
;
; CATEGORY:
;
; shs project util, spex util
;
; CALLING SEQUENCE:
;
; result=pg_totalfit(stp=stp,rise_mi=rise_mi,decay_mi=decay_mi, $
;                    modelname=modelname,parinfo=parinfo, $
;                    el_enorm=el_enorm,ph_enorm=ph_enorm)
;
;
; INPUTS:
;
; 
; KEYWORDS:
;
;    
;
; OUTPUTS:
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
; EXAMPLE:
;
;
;
; AUTHOR:
;
; Paolo Grigis, Institute of Astronomy, ETH Zurich
; pgrigis@astro.pyhs.ethz.ch
; 
; MODIFICATION HISTORY:
;
; 25-AUG-2004 written
; 26-AUG-2004 corrected bug in the number of parameters used by model 
; 01-SEP-2004 corrected bug that caused an incorrect computation of CHISQ
;-

FUNCTION pg_totalfit,stp=stp,rise_mi=rise_mi,decay_mi=decay_mi, $
                     modelname=modelname,parinfo=parinfo, $
                     el_enorm=el_enorm,ph_enorm=ph_enorm, $
                     maxit=maxit,quiet=quiet,justoverall=justoverall, $
                     debug=debug


   npar=n_elements(parinfo);number of parameters accepted by model

;part 1: all the points
 

   print,'FITTING THE OVERALL TREND'

   tagname='APAR_ARR'
   apararr=pg_getptrstrtag(stp,tagname,/transpose)

   spindex=reform(pg_apar2physpar(apararr,/spindex))
   flux=pg_apar2physpar(apararr,eref=ph_enorm)

   res=pg_photon2electron(flux,spindex,ph_enorm,el_enorm)
   elflux=res.elflux
   elspindex=res.elspindex

   x=elflux
   y=elspindex

   IF keyword_set(debug) THEN stop

   overall_parms = MPFITFUN(modelname,x,y $
                   ,replicate(1,n_elements(x)),parinfo=parinfo $
                   ,maxiter=maxit,quiet=quiet,status=status)

   overall_chisq=pg_compchi(x,y,overall_parms,modelname,dof=dof)

   overall_status=status


;part 2: single flares

   IF NOT keyword_set(justoverall) THEN BEGIN 

   flare_parms=dblarr(24,npar)
   flare_chisq=dblarr(24)
   flare_status=intarr(24)
   
   j=0

   FOR i=0,n_elements(stp)-1 DO BEGIN
      IF ptr_valid(stp[i]) THEN BEGIN

           print,'FITTING FLARE NUMBER '+strtrim(string(i),2)

           tagname='APAR_ARR'
           apararr=pg_getptrstrtag(stp[i],tagname,/transpose)

           spindex=reform(pg_apar2physpar(apararr,/spindex))
           flux=pg_apar2physpar(apararr,eref=ph_enorm)

           res=pg_photon2electron(flux,spindex,ph_enorm,el_enorm)
           elflux=res.elflux
           elspindex=res.elspindex

           x=elflux
           y=elspindex

        
           flare_parms[j,*] = MPFITFUN(modelname,x,y $
                   ,replicate(1,n_elements(x)),parinfo=parinfo $
                   ,maxiter=maxit,quiet=quiet,status=status)
           

           flare_chisq[j]=pg_compchi(x,y,flare_parms[j,*],modelname,dof=dof)
           flare_status[j]=status

           j=j+1

      ENDIF

   ENDFOR
 


;part 3: single phases


r_parms=dblarr(n_elements(rise_mi),npar)
r_chisq=dblarr(n_elements(rise_mi))
r_status=intarr(n_elements(rise_mi))
d_parms=dblarr(n_elements(decay_mi),npar)
d_chisq=dblarr(n_elements(decay_mi))
d_status=intarr(n_elements(decay_mi))


;just rise
FOR i=0,n_elements(rise_mi)-1 DO BEGIN

   print,'FITTING RISE PHASE '+strtrim(string(i),2)

   flarenum=rise_mi[i].flarenum  
   phasenum=rise_mi[i].phasenum
   ind=*rise_mi[i].ind

 
   tagname='APAR_ARR'
   apararr=pg_getptrstrtag(stp[flarenum],tagname,/transpose)

   spindex=reform(pg_apar2physpar(apararr,/spindex))
   flux=pg_apar2physpar(apararr,eref=ph_enorm)

   res=pg_photon2electron(flux,spindex,ph_enorm,el_enorm)
   flux=res.elflux
   spindex=res.elspindex

   x=flux[ind]
   y=spindex[ind]

   parms = MPFITFUN(modelname,x,y $
                   ,replicate(1,n_elements(x)),parinfo=parinfo $
                   ,maxiter=maxit,quiet=quiet,status=status)
 
   r_chisq[i]=pg_compchi(x,y,parms,modelname,dof=dof)
   r_parms[i,*]=parms
   r_status[i]=status
                   
ENDFOR

;just decay
FOR i=0,n_elements(decay_mi)-1 DO BEGIN

   print,'FITTING DECAY PHASE '+strtrim(string(i),2)

   flarenum=decay_mi[i].flarenum  
   phasenum=decay_mi[i].phasenum
   ind=*decay_mi[i].ind

 
   tagname='APAR_ARR'
   apararr=pg_getptrstrtag(stp[flarenum],tagname,/transpose)

   spindex=reform(pg_apar2physpar(apararr,/spindex))
   flux=pg_apar2physpar(apararr,eref=ph_enorm)

   res=pg_photon2electron(flux,spindex,ph_enorm,el_enorm)
   flux=res.elflux
   spindex=res.elspindex

   x=flux[ind]
   y=spindex[ind]
 
 
   parms = MPFITFUN(modelname,x,y $
                    ,replicate(1,n_elements(x)),parinfo=parinfo $
                    ,maxiter=maxit,quiet=quiet,status=status)
  

   d_chisq[i]=pg_compchi(x,y,parms,modelname,dof=dof)
   d_parms[i,*]=parms
   d_status[i]=status

 
ENDFOR

;part 4: save the results in a structure...

result={model:modelname,ph_enorm:ph_enorm,el_enorm:el_enorm, $
        overall_parms:overall_parms,overall_chisq:overall_chisq, $
        overall_status:overall_status, $
        flare_parms:flare_parms,flare_chisq:flare_chisq, $
        flare_status:flare_status, $
        r_parms:r_parms,r_chisq:r_chisq,r_status:r_status, $
        d_parms:d_parms,d_chisq:d_chisq,d_status:d_status, $
        dof:dof,parnames:parinfo.parname,parvalues:parinfo.value, $
        parfixed:parinfo.fixed,parlimits:parinfo.limits, $
        parlimited:parinfo.limited}

ENDIF ELSE BEGIN
result={model:modelname,ph_enorm:ph_enorm,el_enorm:el_enorm, $
        overall_parms:overall_parms,overall_chisq:overall_chisq, $
        overall_status:overall_status, $       
        dof:dof,parnames:parinfo.parname,parvalues:parinfo.value, $
        parfixed:parinfo.fixed,parlimits:parinfo.limits, $
        parlimited:parinfo.limited}
ENDELSE

RETURN,result
       
END



