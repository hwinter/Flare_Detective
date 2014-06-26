;+
; NAME:
;
;  pg_bestdistance
;
; PURPOSE:
;
;  Given a set of N>2 points and N*(N-1)/2 measures of one-dimensional distances
;  (with sign!) between them, find the best set of N coordinates
;  describing the position of the points. "best" means that the sum of the
;  squares of the difference between each measured and model distance is minimized.
;
; CATEGORY:
;
; least square problem solvers
;
; CALLING SEQUENCE:
;
; modelcoor=pg_bestdistance(measurdist)
;
; INPUTS:
;
; measurdist: an NxN upper triangular matrix. Its i,j (i>j) element represents the measured
;             one-dimensional distance between point i and point j. That is, d_ij=x_j-x_i
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
; modelcoor: the one-dimensional best coordinates for each point, shifted such
;            that their average is 0.
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
; Paolo Grigis, CfA
; pgrigis@cfa.harvard.edu
;
; MODIFICATION HISTORY:
;
; 25-MAR-2008 written
;
;-


FUNCTION pg_bestdistance_minf,model_dist,observed_dist=observed_dist,verbose=verbose

  s=size(observed_dist)
  n=s[1]

  themodel_dist=[0.,model_dist]
  model_dist_arr=dblarr(n,n)
  FOR j=0,n-1 DO BEGIN 
     FOR i=j+1,n-1 DO BEGIN 
        model_dist_arr[i,j]=themodel_dist[i]-themodel_dist[j]
     ENDFOR
  ENDFOR

  IF keyword_set(verbose) THEN print,model_dist_arr

  return,total((model_dist_arr-observed_dist)^2)

END



FUNCTION pg_bestdistance,m_in

  s=size(m_in)

  IF s[0] NE 2 THEN BEGIN 
     print,'ERROR: Invalid input. Please input a two dimensional array.'
     RETURN,-1
  ENDIF

  IF s[1] NE s[2] THEN BEGIN 
     print,'ERROR: Invalid input. Please input a quadratic array.'
     RETURN,-1
  ENDIF

  np=s[1];number of points

  IF np EQ 2 THEN BEGIN 
     RETURN,m[0,1]
  ENDIF
  
  ;set element on the diagonal and below to zero

  m=m_in
  FOR i=0,np-1 DO BEGIN 
     FOR j=i,np-1 DO BEGIN 
        m[i,j]=0
     ENDFOR
  ENDFOR


  ;start algorithm here

  model_dist_start_guess=m[1:np-1,0]

  res=tnmin('pg_bestdistance_minf',model_dist_start_guess, $
            functargs={observed_dist:m},status=status,/autoderivative)

  print,'STATUS IS '+strtrim(status,2)

  RETURN,[0.,res]-mean([0.,res],/double)

END


