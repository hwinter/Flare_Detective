;+
;
; NAME:
;        pg_current_time
;
; PURPOSE: 
;        returns the current time in anytim format
;        (seconds elapsed since 1-jan-1979)
;
; CALLING SEQUENCE:
;
;        time=pg_current_time()
;
; INPUTS:
;
;        NONE
;
; OUTPUT:
;
;        
; EXAMPLE:
;
;        
;
; VERSION:
;
;           03-OCT-2005 written PG
;        
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;-
FUNCTION pg_current_time

   RETURN,systime(1)-283996800L

END

