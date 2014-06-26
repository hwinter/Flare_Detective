;+
; NAME:
;      pg_getuniqres
;
; PROJECT:
;      diffusion & acceleration (plasma physics)
;
; PURPOSE: 
;      return the unique values of one or more parameters
;
;
; CALLING SEQUENCE:
;      ans=pg_getuniqres,res,parnames
;
; INPUTS:
;      res: sim result structure
;      parnames: array of strings of par names
;      exclude: number of extremal values to exclude (default 0)
;   
; OUTPUTS:
;      
;      
; KEYWORDS:
;
;
; HISTORY:
;       13-JAN-2005 written PG
;       16-JAN-2005 added exclude keyword
;       
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;       pgrigis@astro.phys.ethz.ch
;
;-


FUNCTION pg_getuniqres,res,parnames,exclude=exclude

simpar=res.simpar[*]
nsim=n_elements(res.simpar)
exclude=fcheck(exclude,0)

varpar=fcheck(parnames,['YTHERM','DENSITY','THRESHOLD_ESCAPE_KEV'])
nvarpar=n_elements(varpar)
tagvarpar=tag_index(simpar[0],varpar)
IF tagvarpar[0] EQ -1 THEN BEGIN 
   print,'ERROR: INVALID TAG NAME!'
   RETURN,-1
ENDIF



;produce unique list
unvarpar=ptrarr(nvarpar)
elunvarpar=dblarr(nvarpar)
FOR i=0,nvarpar-1 DO BEGIN 
   tmparr=simpar[*].(tagvarpar[i])
   untmparr=tmparr[uniq(tmparr,sort(tmparr))]
   untmparr=untmparr[exclude:n_elements(untmparr)-1-exclude]
   unvarpar[i]=ptr_new(untmparr)
   elunvarpar[i]=n_elements(*unvarpar[i])
ENDFOR

return,{parnames:varpar,uniqval:unvarpar,eluniqval: elunvarpar}

END



