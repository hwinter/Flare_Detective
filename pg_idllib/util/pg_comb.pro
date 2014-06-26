;+
; NAME:
;
; pg_comb
;
; PURPOSE:
;
; lists all combination of j elements chosen from n
;
; CATEGORY:
;
; combinatorial math
;
; CALLING SEQUENCE:
;
; ans=pg_comb(n,j)
;
; INPUTS:
;
; n: number of objects to choose from
; j: number of objects in each combination
;
; OPTIONAL INPUTS:
;
; 
; KEYWORD PARAMETERS:
;
;
; OUTPUT:
;
; a list of all combinations
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
; 2005 written P.G.
; 
;
;-

FUNCTION pg_comb,n,j

;;number of combinations of j elements chosen from n
nelres=long(factorial(n)/(factorial(j)*factorial(n-j)))

res=intarr(j,nelres);array for the result 
res[*,0]=indgen(j);initialize first combination

FOR i=1L,nelres-1 DO BEGIN;go over all combinations
   res[*,i]=res[*,i-1];initialize with previous value 

   FOR k=1L,j DO BEGIN;scan numbers from right to left

    IF res[j-k,i] LT n-k THEN BEGIN;check if number can be increased 

       res[j-k,i]=res[j-k,i-1]+1;do so 

       ;if number has been increased, set all numbers to its right
       ;as low as possible
       IF k GT 1 THEN res[j-k+1:j-1,i]=indgen(k-1)+res[j-k,i]+1
 
       BREAK;we can skip to the next combination

      ENDIF 

   ENDFOR 

ENDFOR

RETURN,res

END




