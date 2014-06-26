;+
; NAME:
;
; pg_get_connession_ind
;
; PURPOSE:
;
; get indices of the connected part of a spex structure
; if time is [1,2,3,5,7,8,9] and deltat=1 get [2,3], that is elements=3,5 
;
; CATEGORY:
;
; util for shs project
;
; CALLING SEQUENCE:
;
; ind=pg_get_connession_ind(psexst)
;
; INPUTS:
;
; spexst: spex structure
;
;
;
; OUTPUTS:
;
; none
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
; AUTHOR:
;
; Paolo Grigis, Institute of Astronomy, ETH Zurich
; pgrigis@astro.phys.ethz.ch
;
; MODIFICATION HISTORY:
;
; 17-FEB-2004 written
;-

FUNCTION pg_get_connession_ind,spexst

   deltat=spexst.ut[1]-spexst.ut[0]

   time=spexst.xselect[0,*]
   
   dtime=reform(time-shift(time,1))
   dtime=dtime[1:n_elements(dtime)-1]

   ind=where(abs(dtime-deltat) GE 0.1)   

   return,ind

END





