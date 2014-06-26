;+
; NAME:
; 
;   pg_2dimcorr
;
; PURPOSE:
;
;  computes two dimensional cross correlation as a fucntion of x and y lag
;
; CATEGORY:
;
;  math/statistic util
;
; CALLING SEQUENCE:
;
; corrmat=pg_2dimcorr(mat1,mat2,xlag=xlag,ylag=ylag [,/double] )
;
; INPUTS:
; 
; mat1,mat2: the two matrices to corss correlate
; xlag,ylag: a number specifying the minimum and maximum lag for the cross
;            correlation, which is computed as a matrix of size 2*xlag+1 by 2*ylag+1 
;            corresponding to lag values of
;            -xlag,-xlag+1,...,-1,0,1,...,xlag-1,xlag and
;            -ylag,-ylag+1,...,-1,0,1,...,ylag-1,ylag
;            
; OPTIONAL INPUTS:
;
; 
;
; KEYWORD PARAMETERS:
;
; double: if set, the correlations are computed iobn double precision.
; edge_truncate: inhibits circualr shifting (i.e. pixel shifted away from the
;                top do not reappear at the bottom). If this is set, the image
;                should be larger than the lags.
;
; OUTPUTS:
;
; corrmat: the correlation matrix for the lags explained above
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
; The IDL procedure "correlate" is repeateadly applied to shifted input matrices.
;
; EXAMPLE:
;
;
;
; AUTHOR:
; 
;  Paolo Grigis, pgrigis@cfa.harvard.edu
;
; MODIFICATION HISTORY:
;
;  08-FEB-2008 written PG
;  21-FEB-2008 added /EDGE_TRUNCATE keyword PG
;-


FUNCTION pg_2dimcorr,a1,a2,xlag=xlag,ylag=ylag,double=double,edge_truncate=edge_truncate

  xlag=fcheck(xlag,4)
  ylag=fcheck(ylag,4)
  nx=xlag*2+1
  ny=ylag*2+1
  xlagarray=indgen(nx)-xlag
  ylagarray=indgen(ny)-ylag
  IF keyword_set(double) THEN cmat=dblarr(nx,ny) $
                         ELSE cmat=fltarr(nx,ny)


  IF keyword_set(edge_truncate) THEN BEGIN 

     s=size(a1)
     xtrunk=s[1]
     ytrunk=s[2]

     FOR i=0,nx-1 DO BEGIN 
        FOR j=0,ny-1 DO BEGIN 
           cmat[i,j]=correlate((shift(a1,xlagarray[i],ylagarray[j]))[xlag:xtrunk-1-xlag,ylag:ytrunk-1-ylag], $
                                                                (a2)[xlag:xtrunk-1-xlag,ylag:ytrunk-1-ylag], $
                               double=double)
        ENDFOR
     ENDFOR
     
  ENDIF $
  ELSE BEGIN 

     FOR i=0,nx-1 DO BEGIN 
        FOR j=0,ny-1 DO BEGIN 
           cmat[i,j]=correlate(shift(a1,xlagarray[i],ylagarray[j]),a2,double=double)
        ENDFOR
     ENDFOR
     
  ENDELSE

  RETURN,cmat

END

