;+
; NAME:
;    f_pg_powpara
;
; PURPOSE: 
;    quadratic funtion in log log space
;
; CALLING SEQUENCE:
;    
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
;    30-AUG-2006 written PG
;
; AUTHOR
;    Paolo Grigis, Institute for Astronomy, ETH, Zurich
;    pgrigis@astro.phys.ethz.ch
;
;-

function f_pg_powpara,x_edges,params,_extra=_extra

  x=0.5*total(x_edges,1)

  return,exp(params[0]*alog(x)^2+params[1]*alog(x)+params[2])

END 











