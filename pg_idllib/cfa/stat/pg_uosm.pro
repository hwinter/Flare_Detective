;+
; NAME:
;
; pg_uosm
;
; PURPOSE:
;
; compute the uniform order statistic medians
;
; CATEGORY:
;
; statistic utilities
;
; CALLING SEQUENCE:
;
; m=pg_uosm(i,n)
;
; INPUTS:
;
; i: argument
; n: total number of points
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
; from NIST statistic handbook
;
; EXAMPLE:
;
;
;
; AUTHOR:
;
; Paolo Grigis
; pgrigis@cfa.harvard.edu
;
; MODIFICATION HISTORY:
;
; 27-AUG-2008 written PG
;
;-
FUNCTION pg_uosm,i,n

ind1=where(i EQ 1,count1)
ind2=where(i EQ n,count2)

result=((i>1<n)-0.3175d)/((n>1)+0.365d)
IF count1 GT 0 THEN result[ind1]=1d -0.5d^(1d/n)
IF count2 GT 0 THEN result[ind2]=0.5d^(1d/n)

RETURN,result


END



