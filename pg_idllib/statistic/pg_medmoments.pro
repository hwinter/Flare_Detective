;+
; NAME:
;
; pg_medmoments
;
; PURPOSE:
;
; returns the median and the average deviation (= mean absolute
; deviation) of a sample (see num. rec. in C, 14.1)
;
; CATEGORY:
;
; statistics util
;
; CALLING SEQUENCE:
;
; res=pg_medmoments(x)
;
; INPUTS:
;
; x: a numerical array
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
; an array with the median and avg. deviation from the median
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
; written 09-SEP-2004 PG
;
;-
FUNCTION pg_medmoments,x

med=median(x)

adev=1d/n_elements(x)*total(abs(x-med))

return,[med,adev]

END

