;+
; NAME:
;
; pg_fillinterp_nan
;
; PURPOSE:
;
; fill the nan values in a numerical array with linear interpolates
;
; CATEGORY:
;
; various utilities
;
; CALLING SEQUENCE:
;
; res=pg_fillinterp_nan(x)
;
; INPUTS:
;
; x: the input array
;
; OPTIONAL INPUTS:
;
; 
; KEYWORD PARAMETERS:
;
;
;
;
; OUTPUT:
;
;
; OPTIONAL OUTPUTS:
;
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
; 03-FEB-2005 written PG
;
;-

FUNCTION pg_fillinterp_nan,x

n=n_elements(x)
ind=where(finite(x) NE 1,count);index of NAN occurrence (if any)

IF count EQ 0 THEN return,x;no nan found, return original data
IF count EQ n THEN return,replicate(0.,n);only nan there, return array of 0's

res=x;output array


;here a list of the size of clumps of consecutive nan's is produced
noe=1
numel=-1

FOR i=1,n_elements(ind)-1 DO BEGIN
   IF (ind[i]-ind[i-1]) EQ 1 THEN BEGIN 
      noe=noe+1
   ENDIF ELSE BEGIN 
      numel=[numel,noe]
      noe=1
   ENDELSE
ENDFOR
numel=[numel,noe]
numel=numel[1:n_elements(numel)-1]
numcum=total(numel,/cumulative)
;
;numel elencate the numbers of elements in each clump
;numcum can be used to access the firs/lat element in each clump


;both for loops could be combined in just one
;but it is simpler to understand the code keeping
;the stages separated

;do the interpolation, k is the clump index
k=0
FOR i=0,n_elements(numel)-1 DO BEGIN
   bsize=numel[i];size of this clump of nan's
   ind0=ind[k]   ;index of first element in clump
   ind1=ind[k+bsize-1] ;index of last element in clump
   k=k+bsize 

   IF ind0 EQ 0 THEN BEGIN
      v1=x[ind1+1]
      res[ind0:ind1]=v1
   ENDIF ELSE $ 
      IF ind1 EQ n-1 THEN BEGIN
         v0=x[ind0-1]
         res[ind0:ind1]=v0
      ENDIF ELSE BEGIN 

         v1=x[ind1+1];extreme values to be used for the interpolation
         v0=x[ind0-1];

         ;actual interpolation is done here
         res[ind0:ind1]=(findgen(bsize+2)/(bsize+1)*(v1-v0)+v0)[1:bsize]
      ENDELSE

   
ENDFOR

RETURN,res
   
END
