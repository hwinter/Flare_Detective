;+
; NAME:
;
; pg_norm_dist
;
; PURPOSE:
;
; returns the normalized probability function for a normal distribution
;
; CATEGORY:
;
; util, statistics
;
; CALLING SEQUENCE:
;
; 
;
; INPUTS:
;
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
;
;
; AUTHOR:
;
; Paolo Grigis, Institute of Astronomy, ETH Zurich
;
; 
; MODIFICATION HISTORY:
;
; 06-SEP-2004 written
; 
;-

FUNCTION pg_norm_dist,x,inverse=inverse

IF keyword_set(inverse) THEN BEGIN

   N=1000
  

   inputx=[10d -dindgen(N)/(N-1)*20d ]
   outputy=pg_norm_dist(inputx)

   y=interpol(inputx,outputy,x)
   
   RETURN,y

ENDIF

y=0.5d +0.5d *erf(x/sqrt(2d)) 

RETURN,y
  
END
