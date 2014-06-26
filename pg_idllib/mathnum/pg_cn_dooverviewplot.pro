;+
; NAME:
;      pg_cn_dooverviewplot
;
; PROJECT:
;      diffusion & acceleration (plasma physics)
;
; PURPOSE: 
;      plots delta versus flux for many simulation runs
;
;
; CALLING SEQUENCE:
;      pg_cn_dooverviewplot [...]
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
;       10-JAN-2005 written PG
;       16-JAN-2005 now calls pg_uniqres PG
;       
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;       pgrigis@astro.phys.ethz.ch
;
;-

PRO pg_cn_dooverviewplot_test

dir='~/accsimres/'
restore,dir+'photonspectra.sav'
restore,dir+'res.sav'
restore,dir+'inputpar.sav'
;res=pg_phspectratoindex(phspectra)
;save,filename=dir+'res.sav',res

pg_cn_dooverviewplot,res;,inputpar,plotpar=plotpar

END


PRO pg_cn_dooverviewplot,res,thin=thin,thick=thick,electron=electron,exclude=exclude
;,inputpar=inputpar;,plotpar=plotpar

simpar=res.simpar[*]

plotpar=fcheck(plotpar,['TAUESCAPE','UTDIVBYUB'])
nplotpar=n_elements(plotpar)
tagplotpar=tag_index(simpar[0],plotpar)
;this are the variables which need to be varied in one plot

varpar=fcheck(varpar,['YTHERM','DENSITY','THRESHOLD_ESCAPE_KEV'])
nvarpar=n_elements(varpar)
tagvarpar=tag_index(simpar[0],varpar)
;this are constant for one plot

nsim=n_elements(res.simpar)

valplotpar=dblarr(nplotpar,nsim)
valvarpar=dblarr(nvarpar,nsim)

FOR i=0,nplotpar-1 DO valplotpar[i,*]=simpar[*].(tagplotpar[i])
FOR i=0,nvarpar-1 DO valvarpar[i,*]=simpar[*].(tagvarpar[i])
;array with the different values in the arrays

;here we get a list of the unique elements present for the plot par
ans=pg_getuniqres(res,plotpar,exclude=exclude)
unplotpar=ans.uniqval;ptrarr(nplotpar)
elunplotpar=ans.eluniqval;dblarr(nplotpar)

ans=pg_getuniqres(res,varpar,exclude=exclude)
unvarpar=ans.uniqval;ptrarr(nplotpar)
elunvarpar=ans.eluniqval;dblarr(nplotpar)


;number of plots to be done: product over the number of unique values
;of each variable parameter
nplot=product(elunvarpar)


;do all the plots
FOR i=0,nplot-1 DO BEGIN 
   indexlist=pg_juggleindex(elunvarpar,i)
   parvalues=dblarr(nvarpar)

   ;list of the variable par values corresponding to plot number i
   FOR j=0,nvarpar-1 DO parvalues[j]=(*unvarpar[j])[indexlist[j]]

   
   ;find which sims feature the required parameter values in parvalues
   arr=lindgen(nsim)
   FOR j=0,nvarpar-1 DO BEGIN 
      indarr=where(valvarpar[j,arr] EQ parvalues[j],count)
      IF count EQ 0 THEN BEGIN 
         print,'WARNING: ERROR iN THE DATA'
         RETURN
      ENDIF
      arr=arr[indarr]
   ENDFOR
   ;arr is the indices array of the sim with ok pars
   
   ;do plot
   spindex_thin=res.spindex_thin[arr]
   spindex_thick=res.spindex_thick[arr]
   fnorm_thin=res.fnorm_thin[arr]
   fnorm_thick=res.fnorm_thick[arr]
   simpar=res.simpar[arr]
   enorm=res.enorm

   title='NSIM: '+smallint2str(i)

   IF keyword_set(thin) THEN $
   pg_plot_deltaflux_inner,res=res,spindex_thin=spindex_thin,fnorm_thin=fnorm_thin $
                           ,simpar=simpar,enorm=enorm,/thin,title=title,charsize=1.2

   IF keyword_set(thick) THEN $
   pg_plot_deltaflux_inner,res=res,spindex_thick=spindex_thick,fnorm_thick=fnorm_thick $
                           ,simpar=simpar,enorm=enorm,/thick,title=title,charsize=1.2

 
ENDFOR

END






