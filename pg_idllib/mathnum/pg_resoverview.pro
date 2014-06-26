;+
; NAME:
;
;   pg_resoverview
;
; PURPOSE:
;
;   print a small, nice overview of the results in a res structure
;
; CATEGORY:
; 
;   stochastic acceleration simulation project
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
;
; KEYWORD PARAMETERS:
;
;
;
; OUTPUTS:
;
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
;   Paolo Grigis
;   pgrigis@astro.phys.ethz.ch
;
; MODIFICATION HISTORY:
;
;   01-MAR-2006 written PG
;
;-

PRO pg_resoverview,res


  print,'OVERVIEW OF THE SIM PARS'
  print,' '


  simpar0=res.simpar[0]
  
  ntags=n_tags(simpar0)
  tagnames=tag_names(simpar0)

  FOR i=0,ntags-1 DO BEGIN 
     
     dummy=simpar0.(i)

     IF n_elements(dummy) EQ 1 THEN BEGIN 
        ad=res.simpar[*].(i);all data
        ads=sort(ad);sorted
        uniqdata=ad[ads[uniq(ad[ads])]]

        IF n_elements(uniqdata) GT 1 THEN BEGIN 

           print,tagnames[i]+' :'
           print,' '
           print,uniqdata
           print,'--'
           print,' '

        ENDIF

     ENDIF
     
  ENDFOR



END
