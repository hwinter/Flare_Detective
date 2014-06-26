;+
; NAME:
;
; pg_moments
;
; PURPOSE:
;
; calculates statistical averages and standard deviations, eliminating
; NAN and INF from the data beforehand
;
; CATEGORY:
;
; statistics util
;
; CALLING SEQUENCE:
;
; res=pg_ccorr_conf(x)
;
; INPUTS:
;
; x: an array
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
; an array with the first 4 statistical moments
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
; cleans the data set and invokes IDL function moment
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
; written 24-JUN-2004 PG
;
;-
FUNCTION pg_moments,x

ind=where(finite(x))

RETURN,moment(x[ind])

END

