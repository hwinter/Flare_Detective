;+
;
; NAME:
;        pg_getlineint
;
; PURPOSE: 
;
;        returns the point of intersection of two straight lines in the 2-dim
;        plane, if it exist. The lines are specified by two distinct point in
;        the plane each.
;
; CALLING SEQUENCE:
;
;        int=pg_getlineint(a,b,c,d,parallel=parallel)
;    
; 
; INPUTS:
;
;        a,b,c,d: The coordinates of 4 points in the plane in the form [x,y].
;                 a must not be identical to b 
;                 c must not be identical to d 
;                 The routine will try to convert the inputs to double precision
;                 arrays
;
; KEYWORDS:
;        parallel: is set to 1 if the lines are parallel, to 0 otherwise
;        error: is set to 1 if an error occurred
;                
; OUTPUT:
;        int: coordinates of the point of intersection in the form [x,y]
;             if the lines are parallel, NaN's are returned
;
; CALLS:
;        
;
;       
; HISTORY:
;       
;       24-MAY-2006 written pg
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;       pgrigis@astro.phys.ethz.ch
;
;-


PRO  pg_getlineint_test

a=[1,5]
b=[-2,-1]
c=[2,7]
d=[-5,-14]

res=pg_getlineint(a,b,c,d,parallel=parallel)
print,res
print,parallel

;ok res should be 2, 7

END


FUNCTION pg_getlineint,ain,bin,cin,din,parallel=parallel,error=error

parallel=0
error=0
res=[0d,0]

;convert inputs to double
a=double(ain)
b=double(bin)
c=double(cin)
d=double(din)

;check that points are distinct
IF a[0] EQ b[0] AND a[1] EQ b[1] THEN BEGIN 
   error=1
   print,'a and b are identical points!'
   RETURN,res
ENDIF

IF c[0] EQ d[0] AND c[1] EQ d[1] THEN BEGIN 
   error=1
   print,'c and d are identical points!'
   RETURN,res
ENDIF

;build equation system Mx=y
M=transpose([[b-a],[d-c]])
detm=determ(M,/check)

;check for parallelism
IF detm EQ 0 THEN BEGIN 
   parallel=1
   res=!Values.d_nan*[1,1]
   RETURN,res
ENDIF

;ok, matrix is invertible
lmu=invert(M)##transpose(c-a)

res=a+lmu[0]*(b-a);[a[0]+lmu[0]*(b[0]-a[0]),a[1]+lmu[0]*(b[1]-a[1])]

RETURN,res

END







