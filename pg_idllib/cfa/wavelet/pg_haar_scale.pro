;+
; NAME:
;
; pg_haar_scale
;
; PURPOSE:
;
; return the Haar scaling function
;
; CATEGORY:
;
; wavelet tools
;
; CALLING SEQUENCE:
;
; res=pg_haar_scale(x,j,k)
;
; INPUTS:
;
; x: the real numeric argument
; j: scaling index of the function
; k: translation index of the function
;
; OPTIONAL INPUTS:
;
; NONE
;
; KEYWORD PARAMETERS:
;
; NONE
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
; MODIFICATION HISTORY:
; 
; written 15_MAY-2008 PG 
;
;-

FUNCTION pg_haar_scale,x,j,k
 
IF n_elements(j) EQ 0 THEN j=0
IF n_elements(k) EQ 0 THEN k=0

res=x*0

IF j EQ 0 AND k EQ 0 THEN BEGIN 
   ind=where( x GE 0 AND x LT 1d,count)
   IF count GT 0 THEN res[ind]=1
ENDIF $ 
ELSE res=pg_haar_scale(2d^j*x-k,0,0)

RETURN,res

END



