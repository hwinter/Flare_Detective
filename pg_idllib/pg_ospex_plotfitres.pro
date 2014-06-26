;+
; NAME:
;      pg_ospex_plotfitres
;
; PURPOSE: 
;      plot fit results from an ospex object
;
; CALLING SEQUENCE:
;     
;      pg_plotospex_overview,osp,npar
;
; INPUTS:
;     
;      osp: SPEX object
;      npar: index of the parameter to plot 
;  
; OUTPUTS:
;      
;      
; KEYWORDS:
;      /overplot
;
; HISTORY:
;      
;      12-MAY-2005 written PG
;      23-JUN-2005 added output options outpar,outtime PG
;      26-SEP-2005 added /ploterror and outsigma option
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;       pgrigis@astro.phys.ethz.ch
;
;-


PRO pg_ospex_plotfitres,osp,npar=npar,timerange=timerange,thick=thick $
       ,yrange=yrange,linestyle=linestyle,overplot=overplot,_extra=_extra $
       ,color=color,chisq=chisq,chirange=chirange,outpar=outpar,outtime=outtime $
       ,noplot=noplot,ploterror=ploterror,outsigma=outsigma

IF NOT exist(osp) THEN BEGIN
   print,'Please input a SPEX object!'
   RETURN
ENDIF

t0=osp->get(/spex_fit_time_interval)
apar0=osp->get(/spex_summ_params)
sigmapar=osp->get(/spex_summ_sigmas)
;fitfun0=osp[0]->get(/spex_summ_fit_function)

ntimes=n_elements(t0)/2-1

linestyle=fcheck(linestyle,0)
thick=fcheck(thick,1)
npar=fcheck(npar,0)

color=fcheck(color,!p.color)

range=[min(apar0[npar,*]),max(apar0[npar,*])]
drange=range[1]-range[0]
yrange=fcheck(yrange,range+0.1*[-drange,drange])

IF keyword_set(chisq) THEN BEGIN 
   chirange=fcheck(chirange,[0,3])
   yrange=chirange
ENDIF


timerange=fcheck(timerange,[min(t0),max(t0)])

IF NOT keyword_set(noplot) THEN BEGIN 

IF NOT keyword_set(overplot) THEN $
  utplot,[0,1],[0,0],t0[0],yrange=yrange,timerange=timerange,_extra=_extra


IF keyword_set(chisq) THEN BEGIN
   fchisq=osp->get(/spex_summ_chisq)
   FOR i=0,ntimes DO BEGIN 
      outplot,[t0[0,i],t0[1,i]]-t0[0],fchisq[[i,i]],t0[0],thick=thick $
          ,linestyle=linestyle,color=color
      outplot,[t0[1,i],t0[1,i]]-t0[0],fchisq[[i,(i+1)<(ntimes)]],t0[0] $
          ,thick=thick,linestyle=linestyle,color=color
   ENDFOR

 
ENDIF ELSE BEGIN 

;stop

FOR i=0,ntimes DO BEGIN 
   outplot,[t0[0,i],t0[1,i]]-t0[0],apar0[npar,[i,i]],t0[0],thick=thick $
          ,linestyle=linestyle,color=color
   outplot,[t0[1,i],t0[1,i]]-t0[0],apar0[npar,[i,(i+1)<(ntimes)]],t0[0] $
          ,thick=thick,linestyle=linestyle,color=color
   IF keyword_set(ploterror) THEN BEGIN 
      print,'plotting errors'+string(i)
      outplot,0.5*(t0[0,i]+t0[1,i])*[1,1]-t0[0],apar0[npar,[i,i]]+sigmapar[npar,i]*[-1,1],t0[0],thick=thick $
             ,linestyle=linestyle,color=color
   ENDIF
ENDFOR

ENDELSE

ENDIF

outpar=apar0[npar,*]
outsigma=sigmapar[npar,*]
outtime=t0


END



