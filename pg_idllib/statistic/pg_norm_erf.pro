;+
; NAME:
;
; pg_norm_erf
;
; PURPOSE:
;
; returns the cumulative normal probbility function, such that its
; density is the gaussian distribution. The syntax is mpfit compatible.
;
; CATEGORY:
;
; statistic & fitting util
;
; CALLING SEQUENCE:
;
; y=pg_norm_erf(x,parms)
;
; INPUTS:
;
; x: array of ascissa values
; parms: array ['AVG','STDEV'] with average and standard deviation
; of the gaussian
;
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
; pgrigis@astro.phys.ethz.ch
;
; MODIFICATION HISTORY:
;
; 08-SEP-2004 written PG
;
;-

FUNCTION pg_norm_erf,x,parms,getparnames=getparnames

IF keyword_set(getparnames) THEN BEGIN
   RETURN,['AVG','STDEV']
ENDIF


AVG=parms[0]
STDEV=parms[1]

y=erf((x-AVG)/(sqrt(2)*STDEV))

RETURN,y

END
