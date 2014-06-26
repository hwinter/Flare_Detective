;+
; NAME:
;
; pg_interleave_array
;
; PURPOSE:
;
; input two array x,y, returns two arrays x2,y2 such that y2[i] is the least
; element in y gt x2[i] and x2[i] is the largest element in x LT y2[i]. Not sure
; if this definition makes sense.
;
;
; CATEGORY:
;
; sorting utils
;
; CALLING SEQUENCE:
;
; pg_interleave_array,x,y,x2=x2,y2=y2
;
; INPUTS:
;
; x,y: two numerical 1D arrays (may have different length) 
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
; x2,y2: arrays such that y2[i] is the least element in y gt x2[i] and x2[i] is the largest element in x LT y2[i]
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
; NONE KNOWN
;
; PROCEDURE:
;
; TBE
;
; EXAMPLE:
;
; TBD
;
; AUTHOR:
;
; Paolo Grigis
; pgrigis@cfa.harvard.edu
;
; MODIFICATION HISTORY:
;
; 11-DEC-2009 PG improved documentation
;-

PRO pg_interleave_array,inx,iny,x2=x2,y2=y2

nx=n_elements(inx)
ny=n_elements(iny)

x=inx;protect inputs
y=iny


ind=cmset_op(inx,'AND',iny,/index)
IF n_elements(ind) GT 0 AND ind[0] GE 0 THEN BEGIN 
   x[ind]=(x[ind])+1
ENDIF


onearr=replicate(1,nx)
twoarr=replicate(2,nx)
inparr=[x,y]
srtind=bsort(inparr)
allarr=([onearr,twoarr])[srtind]
diff=allarr-shift(allarr,-1)

ind1=where(diff EQ -1,count1)
;ind2=where(diff EQ  1,count2)

IF count1 GT 0 THEN BEGIN 

   x2=inparr[srtind[ind1]]
   y2=inparr[srtind[ind1+1]]

ENDIF $ 
ELSE BEGIN 

   x2=-1
   y2=-1

ENDELSE




END



