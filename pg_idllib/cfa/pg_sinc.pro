;+
; NAME:
;
; pg_sinc
;
; PURPOSE:
;
; returns the sinc function y=sin(pi*x)/(pi*x). Note that x=0 returns 1 (not NAN).
;
; CATEGORY:
;
; math utils
;
; CALLING SEQUENCE:
;
; y=sinc(x)
;
; INPUTS:
;
; x: floating or double precision real number
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
; print,sinc([0.0,0.5,1.0])
;
;
; AUTHOR:
;
; Paolo C Grigis, pgrigis@cfa.harvard.edu
;
; MODIFICATION HISTORY:
;
; 17-SEP-2009 written PG
;
;-

FUNCTION pg_sinc,x

ind=where( finite(x) EQ 1 AND x EQ x*0,count)

arg=!Pi*x

y=sin(arg)/arg
IF count GT 0 THEN y[ind]=1.0

RETURN,y

END





