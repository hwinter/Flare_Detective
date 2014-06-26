;+
; NAME:
;
; pg_fit_model
;
; PURPOSE:
;
; fits a given model to the data for all phases...
;
; CATEGORY:
;
; shs project util, spex util
;
; CALLING SEQUENCE:
;
; 
;
; INPUTS:
;
; 
; KEYWORDS:
;
;    invmodel: if set, switch x and y as input for mpfitfun
;    psplotfilename: if set to a filename string, generates a ps plot
;                    of the different fittings
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
; 06-JUL-2004 written
; 19-AUG-2004 added invmodel keyword
; 20-AUG-2004 added psplotfilename
;-

FUNCTION pg_fit_model,stp=stp,rise_mi=rise_mi,decay_mi=decay_mi,model=model $
  ,parinfo=parinfo,erefel=erefel,ph_energy=ph_energy,maxit=maxit $
  ,quiet=quiet,functargs=functargs,startguess=startguess,invmodel=invmodel $
  ,psplotfilename=psplotfilename


IF (size(psplotfilename,/type) EQ 7) AND NOT keyword_set(invmodel) THEN BEGIN

   doplot=1 

   pg_set_ps,filename=psplotfilename
   !P.multi=[0,2,3]

   xrange=[1d30,6d32]

   linthick=2
   cs=1.5

   ;user defined plot symbol: small filled circle
   d=0.25                    ;circle radius
   N=32.
   A = FINDGEN(N+1) * (!PI*2./N)
   USERSYM, d*COS(A), d*SIN(A), /FILL


ENDIF $ 
ELSE doplot=0

IF n_elements(startguess) GT 0 THEN useguess=1 ELSE useguess=0
;startguess is an array nfit by npar of starting guesses...
   
maxit=fcheck(maxit,200)
erefel=fcheck(erefel,60.)
ph_energy=fcheck(ph_energy,35.)

r_fitpar=dblarr(n_elements(rise_mi),3)
d_fitpar=dblarr(n_elements(decay_mi),3)

fitstr={r_fitpar:r_fitpar,d_fitpar:d_fitpar $
       ,ph_energy:double(ph_energy),el_energy:double(erefel)}


FOR i=0,n_elements(rise_mi)-1 DO BEGIN

   print,'RISE '+strtrim(string(i),2)

   flarenum=rise_mi[i].flarenum  
   phasenum=rise_mi[i].phasenum
   ind=*rise_mi[i].ind

 
   tagname='APAR_ARR'
   apararr=pg_getptrstrtag(stp[flarenum],tagname,/transpose)

   spindex=reform(pg_apar2physpar(apararr,/spindex))
   flux=pg_apar2physpar(apararr,eref=ph_energy)

   res=pg_photon2electron(flux,spindex,ph_energy,erefel)
   flux=res.elflux
   spindex=res.elspindex

   x=flux[ind]
   y=spindex[ind]

   IF keyword_set(invmodel) THEN BEGIN
      tmp=x
      x=y
      y=tmp
   ENDIF



   IF useguess THEN BEGIN
   parms = MPFITFUN(model,x,y $
                   ,replicate(1,n_elements(x)),startguess[i,*],parinfo=parinfo $
                   ,functargs=functargs,maxiter=maxit,quiet=quiet)
   ENDIF $
   ELSE BEGIN  
   parms = MPFITFUN(model,x,y $
                   ,replicate(1,n_elements(x)),parinfo=parinfo $
                   ,functargs=functargs,maxiter=maxit,quiet=quiet)
   ENDELSE

   r_fitpar[i,*]=parms


   IF doplot THEN BEGIN


      plot,flux,spindex,xrange=xrange,/xstyle $
           ,yrange=[3.5,11],/ystyle,/xlog,ylog=1 $
           ,psym=8,xtitle=xtitle $
           ,ytitle='Spectral index FLARE '+strtrim(string(flarenum),2)+ $
           ' PHASE '+strtrim(string(phasenum),2) $
           ,ytickv=[4,5,6,7,8,9,10] $
           ,yticks=6,charsize=cs $
           ,title='RISE - P1: '+strtrim(string(parms[0],format='(g12.3)'),2) $
           +' P2: '+strtrim(string(parms[1],format='(g12.3)'),2) 
 
      oplot,flux[ind],spindex[ind],psym=1

      fflux=findgen(1001)/1000*(max(!X.crange)-min(!X.crange))+min(!X.crange)
      fflux=10^fflux
      ddelta=call_function(model,fflux,parms,_extra=functargs)

      oplot,fflux,ddelta,thick=linthick
   ENDIF


                   
ENDFOR

FOR i=0,n_elements(decay_mi)-1 DO BEGIN

   print,'DECAY '+strtrim(string(i),2)

   flarenum=decay_mi[i].flarenum  
   phasenum=decay_mi[i].phasenum
   ind=*decay_mi[i].ind

 
   tagname='APAR_ARR'
   apararr=pg_getptrstrtag(stp[flarenum],tagname,/transpose)

   spindex=reform(pg_apar2physpar(apararr,/spindex))
   flux=pg_apar2physpar(apararr,eref=ph_energy)

   res=pg_photon2electron(flux,spindex,ph_energy,erefel)
   flux=res.elflux
   spindex=res.elspindex

   x=flux[ind]
   y=spindex[ind]

   IF keyword_set(invmodel) THEN BEGIN
      tmp=x
      x=y
      y=tmp
   ENDIF

 
   IF useguess THEN BEGIN
      parms = MPFITFUN(model,x,y $
                       ,replicate(1,n_elements(x)),startguess[i+n_elements(rise_mi),*],parinfo=parinfo $
                       ,functargs=functargs,maxiter=maxit,quiet=quiet)
   ENDIF $
   ELSE BEGIN 
      parms = MPFITFUN(model,x,y $
                      ,replicate(1,n_elements(x)),parinfo=parinfo $
                      ,functargs=functargs,maxiter=maxit,quiet=quiet)
   ENDELSE 

   d_fitpar[i,*]=parms

   IF doplot THEN BEGIN


      plot,flux,spindex,xrange=xrange,/xstyle $
           ,yrange=[3.5,11],/ystyle,/xlog,ylog=1 $
           ,psym=8,xtitle=xtitle $
           ,ytitle='Spectral index FLARE '+strtrim(string(flarenum),2)+ $
           ' PHASE '+strtrim(string(phasenum),2) $
           ,ytickv=[4,5,6,7,8,9,10] $
           ,yticks=6,charsize=cs $
           ,title='DECAY - P1: '+strtrim(string(parms[0],format='(g12.3)'),2) $
           +' P2: '+strtrim(string(parms[1],format='(g12.3)'),2) 
 
      oplot,flux[ind],spindex[ind],psym=1

      fflux=findgen(1001)/1000*(max(!X.crange)-min(!X.crange))+min(!X.crange)
      fflux=10^fflux
      ddelta=call_function(model,fflux,parms,_extra=functargs)

      oplot,fflux,ddelta,thick=linthick
   ENDIF
                
ENDFOR

fitstr.r_fitpar=r_fitpar
fitstr.d_fitpar=d_fitpar

IF doplot THEN BEGIN
   device,/close
   set_plot,'X'
ENDIF



RETURN,fitstr
       
END



