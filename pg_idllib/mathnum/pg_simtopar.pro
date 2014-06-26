;+
; NAME:
;     pg_simtopar
;
; PROJECT:
;      diffusion & acceleration (plasma physics)
;
; PURPOSE: 
;      prints par values as a function of sim number
;
;
; CALLING SEQUENCE:
;      
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
;       11-JAN-2005 written PG (originally from pg_cn_dooverviewplot)
;       
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;       pgrigis@astro.phys.ethz.ch
;
;-

PRO pg_simtopar,res;,thin=thin,thick=thick;,inputpar=inputpar;,plotpar=plotpar

loadct,0
   
lev=[2.,3.,4.,5.,6,7,8,10.,15]


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
unplotpar=ptrarr(nplotpar)
elunplotpar=dblarr(nplotpar)
FOR i=0,nplotpar-1 DO BEGIN 
   tmparr=valplotpar[i,*]
   unplotpar[i]=ptr_new(tmparr[uniq(tmparr,sort(tmparr))])
   elunplotpar[i]=n_elements(*unplotpar[i])
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
   ;simpar=res.simpar[arr]
   enorm=res.enorm

   tauescape=simpar[arr].tauescape
   iacc=simpar[arr].utdivbyub*simpar[arr].avckomega


 
   print,'SIM: '+smallint2str(i)
   FOR k=0,n_elements(varpar)-1 DO BEGIN 
      print,varpar[k]+': '+string(parvalues[k])
   ENDFOR



;nspectra=n_elements(el_sp)

;tauescape=res.simpar[1:nspectra].tauescape
;iacc=res.simpar[1:nspectra].utdivbyub*res.simpar[1:nspectra].avckomega

   ;stop

   ;pg_refuniq,iacc,tauescape,spindex_thin,a_out=ia,b_out=tau,c_out=delta
   ;pg_refuniq,iacc,tauescape,fnorm_thin,a_out=ia,b_out=tau,c_out=flux




;loadct,13

   ;stop


ENDFOR

END






