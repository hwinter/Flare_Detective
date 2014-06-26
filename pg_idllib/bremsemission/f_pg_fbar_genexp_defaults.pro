;+
; NAME:
;      f_pg_fbar_genexp_defaults
;
; PURPOSE: 
;      returns the dafult values for f_pg_fbar_genexp as used by spex
;
; CALLING SEQUENCE:
;      
;
; INPUTS:
;     
;
; KEYWORDS:
;     
;
; OUTPUT:
;      
;       
;
; COMMENT:
;
;
; EXAMPLE   
;
;
;
; VERSION:
;       28-SEP-2005 written PG
;       
; AUTHOR:
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;-

FUNCTION f_pg_fbar_genexp_defaults

 defaults = { $
        fit_comp_params:       [1.,1,1.5], $
	fit_comp_minima:       [1e-20, 0.1,0.5], $
	fit_comp_maxima:       [1e20,  100, 100], $
	fit_comp_free_mask:    1B+Bytarr(3) $
	}

RETURN, defaults


END
