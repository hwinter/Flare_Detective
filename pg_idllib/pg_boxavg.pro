;+
;
; NAME:
;        pg_boxavg
;
; PURPOSE: 
;
;        averages N elements of the input array together 
;
; CALLING SEQUENCE:
;
;        avgarr=pg_boxavg(inarr,navg=navg)
;    
; 
; INPUTS:
;
;        inarr: a one-dimensional array
;        navg: the number of elemnts to average together, default: 2
;
; KEYWORDS:
;        
;                
; OUTPUT:
;        avgarr
;
; CALLS:
;        
;
; EXAMPLE:
; 
;       
; 
; VERSION:
;       
;       19-JUL-2006 written
;       
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;       pgrigis@astro.phys.ethz.ch
;-

FUNCTION pg_boxavg,inarr,navg=navg

navg=fcheck(navg,2L)>1L

n=n_elements(inarr)

IF n MOD navg NE 0 THEN max=n/navg*navg-1 ELSE max=n-1

RETURN,total(reform(inarr[0:max],navg,n/navg),1)/navg


END












