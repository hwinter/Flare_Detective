;+
; NAME:
;
;   pg_cyclictrisol
;
; PURPOSE:
;
;   solves a "cyclic tridiagonal system" of size NxN as explained
;   in "numerical recipes in c", section 2.7.
;
; CATEGORY:
;
;   lineare algebra - numerical utilities
;
; CALLING SEQUENCE:
;
;    x=pg_cyclictrisol(subdiagvalues,diagvalues,superdiagvalues,r)
;
; INPUTS:
;
;    subdiagvalues: N values below the diagonal. The first element
;         contains the element which is on row 1, column N
;    diagvalues: N diagonal elements 
;    superdiagvalues: N values above the diagonal. The last element
;         contains the element which is on row N, column 1          
;    r: an N vector with the right hand side of the system
;
;
; OUTPUTS:
;
;    x: the solution of the equation
;
; METHOD: 
;
;    algorithm taken from numerical recipes in c, sect. 2.7
;    calls IDL's own trisol routine
;
; 
;
; AUTHOR:
;
; Paolo Grigis, Institute of Astronomy, ETH Zurich
; pgrigis@astro.phys.ethz.ch
;
; MODIFICATION HISTORY:
;
; 27-MAY-2005 written
; 05-JAN-2007 added complex keyword (for complex arrays)
;
;-

;.comp pg_cyclictrisol

FUNCTION pg_cyclictrisol,subdiagvalues,diagvalues,superdiagvalues,r,complex=complex

;rename inputs such that they won't be modified
a=subdiagvalues 
b=diagvalues
c=superdiagvalues

;size of the matrix should be n by n
n=n_elements(b)

;from now on, just taken from numerical recipes
gamma=-b[0]
;alpha=a[n-1]
;beta=c[0]
alpha=c[n-1]
beta=a[0];c[n-1]

b[0]=b[0]-gamma
b[n-1]=b[n-1]-alpha*beta/gamma

IF NOT keyword_set(complex) THEN BEGIN 
   x=trisol(a,b,c,r,/double)
ENDIF $
ELSE BEGIN 

   dlower = a[1:n-1]
   darray = b  
   dupper = c[0:n-2]  
   LA_TRIDC, dlower, darray, dupper, u2, index  
  
   x = LA_TRISOL(dlower, darray, dupper, u2, index, r,/double)
  
ENDELSE

IF NOT keyword_set(complex) THEN BEGIN 
   u=dblarr(n)
ENDIF $
ELSE BEGIN
   u=complexarr(n)  
ENDELSE
u[0]=gamma
u[n-1]=alpha

IF NOT keyword_set(complex) THEN BEGIN 
   z=trisol(a,b,c,u,/double)
ENDIF $
ELSE BEGIN 
   dlower = a[1:n-1]
   darray = b  
   dupper = c[0:n-2]     
   LA_TRIDC, dlower, darray, dupper, u3, index2  

   z = LA_TRISOL(dlower, darray, dupper, u3, index2, u,/double)
ENDELSE

fact=(x[0]+beta*x[n-1]/gamma)/(1.+z[0]+beta*z[n-1]/gamma)

x=x-fact*z

RETURN,x

END
