;+
; NAME:
;
;    pg_arange
;
; PURPOSE:
;
;    imitates python numpy arange function
;
; CATEGORY:
;
;
;
; CALLING SEQUENCE:
;
;    x=pg_arange(min,max,delta,nbins=nbins)
;
; INPUTS:
;
;    min,max,delta: range intervals and delta
;    nbins: (optional) number of bins
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
; MODIFICATION HISTORY:
;
;-

FUNCTION pg_arange,min,max,delta,nbins=nbins


IF n_elements(nbins) EQ 0 THEN BEGIN 

   nelements=(max-min)/delta+1

   x=min+findgen(nelements)*delta

ENDIF $
ELSE BEGIN 

   delta=(max-min)/float(nbins-1)
   
   x=min+findgen(nbins)*delta

ENDELSE 

return,x

END 
