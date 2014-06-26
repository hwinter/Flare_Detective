;+
; NAME:
;
; pg_ptrvalid
;
; PURPOSE:
;
; returns the number of valid pointer in the input ptr array
;
; CATEGORY:
;
; util
;
; CALLING SEQUENCE:
;
; n=pg_ptrvalid(parr)
;
; INPUTS:
;
; parr: pointer array
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
; 17-DEC-2003 written
; 
;-

FUNCTION pg_ptrvalid,parr
   
   IF exist(parr) THEN $
       dummy=where(parr NE ptr_new(),n) ELSE $
       n=-1

   RETURN,n

END
