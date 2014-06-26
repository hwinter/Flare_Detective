;+
; NAME:
;    f_pg_powpara_defaults
;
; PURPOSE: 
;    SPEX defaults for f_pg_powpara
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

function f_pg_powpara_defaults

  defaults={$
           fit_comp_params:[-0.6,2,1.3], $
           fit_comp_minima:[-20.,-20,-20], $
           fit_comp_maxima:[20.,20,20], $
           fit_comp_free_mask:[1,1,1]}

  return,defaults

END 











