;+
; NAME:
;
; pg_tabint
;
; PURPOSE:
;
; Returns the integral of a tabulated function y of the independent
; variable x. This is not as fancy as IDL's own int_tabulated, but
; works for more general intervals subdivisions, especially logarithmic.
; It also has the capability of returning the integral as another
; array z where z[i]=int_x[i]^x[N-1] y*dy (set cumulative keyword)
; This routine, while not too accurate, should be reasonably fast,
; and does uses all the values in the input array.
;
; CATEGORY:
;
; numerical integration
;
; CALLING SEQUENCE:
;
; ???
;
; INPUTS:
;
; x: array of N values for the independent variable
; y: array of N function values 
;
; 
; OPTIONAL INPUTS:
;
; 
; KEYWORD PARAMETERS:
; cumulative: if set, the cumulative integral is returned
;
; OUTPUT:
; a number, the integral
; optionally, z contains the cumulative integral
; 
; PROCEDURE:
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
; 07-NOV-2005 written P.G.
;
;-

FUNCTION pg_tabint,x,y,z=z,err=err,cumulative=cumulative

n=n_elements(x)
err=0

IF n_elements(y) NE n THEN BEGIN 
   err=1
   print,'ERROR in pg_tabint!'
   print,'x & y must have the same number of elements!'
   RETURN,-1
ENDIF

;avgx=0.5*(shift(x,-1)+x)
;dx=avgx-shift(avgx,1)
;dx[0]=avgx[0]-x[0]
;dx[n-1]=x[n-1]-avgx[n-2]

dx=0.5*(shift(x,-1)-shift(x,1))
dx[0]=0.5*(x[1]-x[0])
dx[n-1]=0.5*(x[n-1]-x[n-2])

IF keyword_set(cumulative) THEN BEGIN 
   z=reverse(total(reverse(y*dx),/cumulative))
   z[1:n-2]=z-0.5*y[1:n-2]*dx[1:n-2]
   z[n-1]=0.
ENDIF $
ELSE $
   z=total(y*dx)

RETURN,z[0]
   
END
