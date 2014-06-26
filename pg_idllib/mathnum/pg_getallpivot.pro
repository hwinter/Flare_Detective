;+
; NAME:
;      pg_getallpivot
;
; PROJECT:
;      diffusion & acceleration (plasma physics)
;
; PURPOSE: 
;      get pivot point coordinates for many simulation runs
;
;
; CALLING SEQUENCE:
;      
;
; INPUTS:
;      res: result structure
;   
; OUTPUTS:
;      
;      
; KEYWORDS: 
;
;      thin,thick,electron --> decide wether the results apply for thin target
;                              photon spectra, thick target photon or
;                              electrons
;      exclude: thickness of outer layer of sim points to exclude (default=0)
;
;
; HISTORY:
;       13-JAN-2005 written PG
;       16-JAN-2005 added electrons & exclude inputs
;       
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;       pgrigis@astro.phys.ethz.ch
;
;-



FUNCTION pg_getallpivot,res,thin=thin,thick=thick,electrons=electrons,exclude=exclude

simpar=res.simpar[*]
exclude=fcheck(exclude,0)

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


;old method --> now in routin pg_getuniqres

;here we get a list of the unique elements present for the plot par
;FOR i=0,nplotpar-1 DO BEGIN 
;   tmparr=valplotpar[i,*]
;   untmparr=tmparr[uniq(tmparr,sort(tmparr))]
;   untmparr=untmparr[exclude:n_elements(untmparr)-1-exclude]
;   unplotpar[i]=ptr_new(untmparr)
;   elunplotpar[i]=n_elements(untmparr)
;ENDFOR

;same for the variable pars
;unvarpar=ptrarr(nvarpar)
;elunvarpar=dblarr(nvarpar)
;FOR i=0,nvarpar-1 DO BEGIN 
;   tmparr=valvarpar[i,*]
;   unvarpar[i]=ptr_new(tmparr[uniq(tmparr,sort(tmparr))])
;   elunvarpar[i]=n_elements(*unvarpar[i])
;ENDFOR

;number of plots to be done: product over the number of unique values
;of each variable parameter
nplot=product(elunvarpar)

pivdata=ptrarr(nplot)

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
         RETURN,-1
      ENDIF
      arr=arr[indarr]
   ENDFOR
   ;arr is the indices array of the sim with ok pars

   
   ;takes care of "excluded" variables
   FOR j=0,nplotpar-1 DO BEGIN
      thisparvalues=valplotpar[j,arr]
      indarr=where((thisparvalues GE (*unplotpar[j])[0]) AND $
                    (thisparvalues LE (*unplotpar[j])[elunplotpar[j]-1]),count)
      IF count GT 0 THEN arr=arr[indarr] ELSE RETURN,-1
      
   ENDFOR
   
   
   ;do plot
   spindex_thin=res.spindex_thin[arr]
   spindex_thick=res.spindex_thick[arr]
   fnorm_thin=res.fnorm_thin[arr]
   fnorm_thick=res.fnorm_thick[arr]
   simpar=res.simpar[arr]
   enorm=res.enorm

   IF keyword_set(thin) THEN BEGIN 
      thispivdata=pg_findpivot(spindex_thin,fnorm_thin,enorm)
   ENDIF

   IF keyword_set(thick) THEN BEGIN 
      thispivdata=pg_findpivot(spindex_thick,fnorm_thick,enorm)
   ENDIF

   thispivdata=add_tag(thispivdata,parvalues,'PARVALUES')
   thispivdata=add_tag(thispivdata,varpar,'PARNAMES')
   pivdata[i]=ptr_new(thispivdata)

 
ENDFOR

RETURN,pivdata

END






