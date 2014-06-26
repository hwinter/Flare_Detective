;+
; NAME:
;   pg_findislands
;
;
; PURPOSE:
;  given a monotonically increasing series of integers, find the set of all
;  "islands", that is, maximal subgroups of integers in the original series with
;  the property of being in direct succession (i.e. their difference is only 1)
;  Example: given 2 4 5 6 9 11 15 16 23 24 25 26 27 33, the "islands" are
;                 "4 5 6", "15 16", "23 24 25 26 27"
;
;
; CATEGORY:
;
; general programming/math util
;
; CALLING SEQUENCE:
;
; ind=pg_findislands(x)
;
; INPUTS:
;
; x: a monotonically increasing series of integers
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
; ind: an array 2 by number of islands with the start and end index of ecah
; island, or -1 if no island is found
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
;   Paolo Grigis, pgrigis@cfa.haravrd.edu
; 
; MODIFICATION HISTORY:
;
;   written 29-JAN-2008 PG
;
;-

PRO pg_findislands_test

  x=[2, 4, 5, 6, 9, 11, 15, 16, 23, 24, 25, 26, 27, 33]

  res=pg_findislands(x)

  print,[x[res[0,*]],x[res[1,*]]]

  ;.comp  pg_findislands

END

FUNCTION pg_findislands,x

  nx=n_elements(x)

  IF nx LT 2 THEN RETURN,-1

  dx=shift(x,-1)-x
  dx[nx-1]=2
;  ddx=shift(dx,-1)-dx
  
  indstart=where(dx EQ 1 AND shift(dx,1) GT 1,countstart)
  indend=where(dx EQ 1 AND shift(dx,-1) GT 1,countend)+1
  
  IF countstart EQ 0 THEN return,-1

  return,transpose([[indstart],[indend]])  

END 


