;+
; NAME:
;      pg_eval_simres
;
; PROJECT:
;      diffusion & acceleration (plasma physics)
;
; PURPOSE: 
;      transform raw data into useful output variables
;
;
; CALLING SEQUENCE:
;      pg_eval_simres,outptr
;
; INPUTS:
;      outptr: a pointer to a sim result structure, or an array thereof
;   
; OUTPUTS:
;      
;      
; KEYWORDS:
;
;
; HISTORY:
;      07-OCT-2005 written PG 
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;
;-

FUNCTION  pg_eval_simres,o,energy_range=energy_range,emin=emin,eref=eref $
                        ,adaptiter=adaptiter,quiet=quiet

mc2=511.

erange=fcheck(energy_range,[20d,100])
eref=fcheck(eref,60d)
emin=fcheck(emin,20d)

no=n_elements(o)

spindex=dblarr(no)
feref=dblarr(no)

parnames=(*o[0]).simpar.parnames

parvalues=dblarr(n_elements(parnames),no)

res={eref:eref,emin:emin,erange:erange,spindex:dblarr(no),flux:dblarr(no) $
    ,parnames:parnames,parvalues:parvalues,iter:lonarr(no),eltotnumber:dblarr(no) $
    ,realeltotnumber:dblarr(no)}

a=*o[0]
x=a.energy*mc2
ind=where((x GE min(erange)) AND (x LE max(erange)),count)
ind2=where(x GE emin)
iterind=n_elements(a.iter)

IF count LT 0 THEN BEGIN 
   print,'AN ERROR OCCURRED... RETURNING -1.'
   RETURN,-1
ENDIF


FOR i=0,no-1 DO BEGIN 

   IF NOT keyword_set(quiet) THEN print,i

   a=*o[i]

   IF keyword_set(adaptiter) THEN BEGIN
      spindarr=dblarr(iterind)
      FOR j=0,iterind-1 DO BEGIN 
         y=a.grid[*,j]
         fitres=linfit(alog(x[ind]),alog(y[ind])) 
         spindarr[j]=fitres[1]       
      ENDFOR
      diff=spindarr-shift(spindarr,1)
      ;stop
      okind=where(abs(diff) LT 1d-4,count)
      IF count EQ 0 THEN BEGIN 
         okind=iterind-1
         ;print,'AN ERROR OCCURRED... RETURNING -1.'
         ;RETURN,-1
      ENDIF
      iterind=min(okind)+1
   ENDIF
      
   y=a.grid[*,iterind-1]

   fitres=linfit(alog(x[ind]),alog(y[ind])) 

   res.spindex[i]=fitres[1]
   res.flux[i]=exp(double(fitres[0])>(-300.)<300.)* $
               exp(double(alog(eref)*fitres[1])>(-300.)<300.) 

   res.parvalues[*,i]=a.simpar.parvalues
   res.iter[i]=a.iter[iterind-1]

   totnumber=int_tabulated(alog(x[ind2]),x[ind2]*y[ind2])/mc2
   res.eltotnumber[i]=totnumber

   realtotnumber=int_tabulated(alog(x),x*y)/mc2
   res.realeltotnumber[i]=realtotnumber

ENDFOR
   
RETURN,res

END
