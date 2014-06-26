;+
;
; NAME:
;        pg_getescaped_part
;
; PURPOSE: 
;        computes how many particles have escaped from an input
;        distribution with neergy and the simpar structure...
;
; CALLING SEQUENCE:
;
;        esc_pop=pg_getescaped_part(en_mc2,grid,simpar)
;
; INPUTS:
;
;       
; OUTPUT:
;        
; EXAMPLE:
;
;        
;
; VERSION:
;
;        05-DEC-2005 written PG
;        
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;-

FUNCTION pg_getescaped_part,en_mc2,grid,simpar

   egrid=en_mc2

   IF tag_exist(simpar,'THRESHOLD_ESCAPE_KEV') THEN $
      threshold=simpar.threshold_escape_kev/511. $
   ELSE $
      threshold=0.

   indescape=where(egrid GE threshold,count_indescape)

   IF count_indescape EQ 0 THEN BEGIN 
      print,'The escape energy lower threshold is so high'
      print,'that the model is equivalent to one without escape!'
      RETURN,-1
   ENDIF


   gamma=1+egrid
   vv=sqrt(1-1/(gamma*gamma))
   dgridescape=grid*0.
   dgridescape[indescape]= $
     simpar.dtime_iter*simpar.dimless_time_unit/simpar.tauescape*vv[indescape]*grid[indescape]

   return,dgridescape
   

END
