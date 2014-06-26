
;+
; NAME:
;      nearest_value_locate
;
; CALLING SEQUENCE:
;       
;      ind=nearest_value_locate(target,data)
;
;
; PURPOSE: 
;      similar to value_locate (cfr.) only that gives the index of the
;      nearest value in target to data instead of the index of the
;      lower bound of the interval
;
; INPUTS:
;      target: target array, should be monotonically increasing
;      data: data array, whose positions in target have to be located
;  
; OUTPUTS:
;      ind: the array of indices
;      
; KEYWORDS:
;        
;
; CALLS:
;      value_locate
;
; HISTORY:
;       29-SEP-2003 written
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;
;-

FUNCTION nearest_value_locate,target,data

ind=value_locate(target,data)

norm=where((ind GE 0) AND (ind LT (n_elements(target)-1)),normc)
ind=ind > 0; -1 values are nearest the 0 element --> nothing to do here
           ; note that values=(n_elements(target)-1) are also ok!

IF normc GT 0 THEN BEGIN

    ind2=ind[norm]

    left_diff=data-target[ind2]
    right_diff=target[ind2+1]-data

    wrong_ind=where(left_diff GT right_diff,diffcount)
    IF diffcount GT 0 THEN $
        ind2[wrong_ind]=ind2[wrong_ind]+1

    ind[norm]=ind2

ENDIF


RETURN,ind

END
