;+
; NAME:
;      pg_getsign
;
; PROJECT:
;      math util
;
; PURPOSE: 
;
;      returns the sign of an input number or array
;      the sign of 0 is given as 0
;
; CALLING SEQUENCE:
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
;       05-DEC-2006 written PG
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;       pgrigis@astro.phys.ethz.ch
;
;-



FUNCTION pg_getsign,x

  ans=((x GE 0) + (x GT 0))-1

  RETURN,ans

END

