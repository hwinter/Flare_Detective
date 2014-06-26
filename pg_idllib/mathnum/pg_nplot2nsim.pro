;+
; NAME:
;      pg_nplot2nsim
;
; PROJECT:
;      diffusion & acceleration (plasma physics)
;
; PURPOSE: 
;      from inputa parameters nplot and tau,u returns the sim number
;
;
; CALLING SEQUENCE:
;      pg_nplot2nsim
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
;       16-JAN-2005 written PG
;       
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;       pgrigis@astro.phys.ethz.ch
;
;-

FUNCTION pg_nplot2nsim,res,thisplot=thisplot,par=par,plotpar=plotpar,varpar=varpar

simpar=res.simpar[*]
exclude=0

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
unplotpar=ptrarr(nplotpar)
elunplotpar=dblarr(nplotpar)
FOR i=0,nplotpar-1 DO BEGIN 
   tmparr=valplotpar[i,*]
   untmparr=tmparr[uniq(tmparr,sort(tmparr))]
   untmparr=untmparr[exclude:n_elements(untmparr)-1-exclude]
   unplotpar[i]=ptr_new(untmparr)
   elunplotpar[i]=n_elements(untmparr)
ENDFOR


;same for the variable pars
unvarpar=ptrarr(nvarpar)
elunvarpar=dblarr(nvarpar)
FOR i=0,nvarpar-1 DO BEGIN 
   tmparr=valvarpar[i,*]
   unvarpar[i]=ptr_new(tmparr[uniq(tmparr,sort(tmparr))])
   elunvarpar[i]=n_elements(*unvarpar[i])
ENDFOR

;number of plots to be done: product over the number of unique values
;of each variable parameter
nplot=product(elunvarpar)

pivdata=ptrarr(nplot)

;do all the plots
;FOR i=0,nplot-1 DO BEGIN 

i=thisplot

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
         RETURN,-1
      ENDIF
      arr=arr[indarr]
   ENDFOR
   ;arr is the indices array of the sim with ok pars

  


 
;   ;takes care of "excluded" variables
   FOR j=0,nplotpar-1 DO BEGIN
      thisparvalues=valplotpar[j,arr]
      goalparval=par[j]
      dummy=min(abs(thisparvalues-goalparval),indmin)
      okparval=thisparvalues[indmin[0]]
      indarr=where(thisparvalues EQ okparval,count)
      IF count GT 0 THEN arr=arr[indarr] ELSE RETURN,-1
   ENDFOR

      
RETURN,arr


END






