;+
; NAME:
;      pg_vect_proj
;
; PURPOSE: 
;      returns the components of a vector along a certain direction
;
; CALLING SEQUENCE:
;
;      pg_vect_proj,x=x,y=y,lx=lx,ly=ly,par=par,perp=perp
;
;
; INPUTS:
;      
;      x,y: an array of x and y component of vectors
;      lx,ly: directional vector
;  
; OUTPUTS:
;      par,perp: parallel and perpendicualr component of the vector      
;      
; KEYWORDS:
;      
;
; HISTORY:
;
;      15-DEC-2004 written
;      
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;
;-

PRO pg_vect_proj,x=x,y=y,lx=lx,ly=ly,par=par,perp=perp,signum=signum


IF (lx EQ 0.) AND (ly EQ 0.) THEN BEGIN
   print,'Invalid input: lx,ly should not be both equal 0'
   RETURN
ENDIF

ld=sqrt(lx*lx+ly*ly);norm of vector l
lex=lx/ld
ley=ly/ld

par=x*lex+y*ley;scalar product 
perp=sqrt(x*x+y*y-par*par);pythagora's theorem

IF keyword_set(signum) THEN BEGIN

   
   angle1=180.-180.*atan(y,-x)/!DPi
   angle2=180.-180.*atan(ly,-lx)/!DPi

   delta=angle1-angle2

   parsignum=intarr(n_elements(x))
   perpsignum=intarr(n_elements(x))

   anglesignum=2*(0.5-(delta EQ delta*delta))

   ind=where((abs(delta) LE 90.),count)
   IF count GT 0 THEN BEGIN
      parsignum[ind]=anglesignum[ind]
      perpsignum[ind]=anglesignum[ind]
   ENDIF

   ind=where((abs(delta) GT 90.) AND (abs(delta) LE 180.),count)
   IF count GT 0 THEN BEGIN
      parsignum[ind]=-anglesignum[ind]
      perpsignum[ind]=anglesignum[ind]
   ENDIF

   ind=where((abs(delta) GT 180.) AND (abs(delta) LE 270.),count)
   IF count GT 0 THEN BEGIN
      parsignum[ind]=-anglesignum[ind]
      perpsignum[ind]=-anglesignum[ind]
   ENDIF

   ind=where((abs(delta) GT 270.) AND (abs(delta) LE 360.),count)
   IF count GT 0 THEN BEGIN
      parsignum[ind]=-anglesignum[ind]
      perpsignum[ind]=-anglesignum[ind]
   ENDIF

   par=par*parsignum
   perp=perp*perpsignum

ENDIF



END
