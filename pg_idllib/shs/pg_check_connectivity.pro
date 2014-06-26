;+
; NAME:
;
; pg_check_connectivity
;
; PURPOSE:
;
; check if the time intervals in spexst is connected or not
;
; CATEGORY:
;
; util for shs project
;
; CALLING SEQUENCE:
;
; result=pg_check_connectivity,spexst
;
; INPUTS:
;
; spexst: a spex output structure
;
; OPTIONAL INPUTS:
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
; AUTHOR:
;
; Paolo Grigis, Institute of Astronomy, ETH Zurich
; pgrigis@astro.phys.ethz.ch
;
; MODIFICATION HISTORY:
;
; 17-FEB-2004 written
; 
;-
FUNCTION pg_check_connectivity,spexst,addtag=addtag

   oktimes=reform(spexst.xselect[0,*])
   
   delta=oktimes-shift(oktimes,1)
   delta=delta[1:n_elements(delta)-1]

   IF max(delta)-min(delta) GT 0.1 THEN connected=0 ELSE connected=1

   IF keyword_set(addtag) THEN spexst=add_tag(spexst, connected ,'connected')

   return,connected


END


