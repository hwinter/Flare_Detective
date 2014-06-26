;+
; NAME:
;
; pg_coalesece_indices
;
; PURPOSE:
;
; Input a series of indices, finds all islands of adjacent values and replaces
; them with the median value. Example: input 3 5 9 10 11 15 22 23 24 25 26 28 30
; output: 3 5 10 15 24 28 30
;
; CATEGORY:
;
; various utils for data manipulation
;
; CALLING SEQUENCE:
;
; res=pg_coalesce_indices(x)
;
; INPUTS:
;
; x: a monotonically increasing array of integer type
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
; an integer array with not more elements than x
;
; OPTIONAL OUTPUTS:
;
; NONE
;
; COMMON BLOCKS:
;
; NONE
;
; SIDE EFFECTS:
;
; NONE
;
; RESTRICTIONS:
;
; Use integer input for best results.
;
; PROCEDURE:
;
; Easy, but not very efficient algorithm, compute the difference between
; elements and scans the array for differences equal 1. If found, scan until
; the end of the "island" of differences eq 1, keep track of the length of the
; "island", return the median value and go back to main scan loop.
;
; EXAMPLE:
;
;
; AUTHOR:
;
; Paolo Grigis, pgrigis@cfa.harvard.edu
;
; MODIFICATION HISTORY:
;
; 4-JUN-2008 written PG
;
;-

FUNCTION pg_coalesce_indices,x

n=n_elements(x)
dx=[(x-shift(x,1))[1:*],2]

thiselement=0
xout=-1

WHILE thiselement LT n_elements(dx) DO BEGIN 
   IF dx[thiselement] LE 1 THEN BEGIN
      counter=1
      WHILE dx[thiselement+counter] LE 1 DO BEGIN 
         counter++
      ENDWHILE
      xout=[xout,x[thiselement+counter/2]]
      thiselement=thiselement+counter+1
   ENDIF ELSE BEGIN 
      xout=[xout,x[thiselement]]
      thiselement++
   ENDELSE
ENDWHILE

xout=xout[1:*]

RETURN,xout

END


