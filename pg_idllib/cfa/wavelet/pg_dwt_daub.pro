;+
; NAME:
;
; pg_dwt_daub
;
; PURPOSE:
;
;
;
; CATEGORY:
;
;
;
; CALLING SEQUENCE:
;
;
;
; INPUTS:
;
;
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
;
;
; EXAMPLE:
;
;
;
; MODIFICATION HISTORY:
;
;-

FUNCTION pg_dwt_daub,xx,sign

c0= 0.4829629131445341d
c1= 0.8365163037378077d
c2= 0.2241438680420134d
c3=-0.1294095225512603d

x=xx
;y=x*0
nx=n_elements(x)
;n=nx
n=nx/2

sign=fcheck(sign,1)

IF sign LT 0 THEN BEGIN 

   n=1
   y=x
   WHILE n LE nx/2 DO BEGIN
      print,n
      y[0]=c0*x[0]+c3*x[n]+c2*x[n-1]+c1*x[2*n-1]
      y[1]=c1*x[0]-c2*x[n]+c3*x[n-1]-c0*x[2*n-1]
     FOR i=1,n/2-1 DO BEGIN
         j=2*i
         y[j]  =c2*x[i]+c1*x[i+n]+c0*x[i+1]+c3*x[i+n+1]
         y[j+1]=c3*x[i]-c0*x[i+n]+c1*x[i+1]-c2*x[i+n+1]
      ENDFOR
      n=n*2
      x=y
   ENDWHILE 

ENDIF $
ELSE BEGIN 
y=0
WHILE n GE 2 DO BEGIN  
   print,n
   FOR i=0,n-2 DO BEGIN
      j=2*i
      print,i,j
      y[i]  =c0*x[j]+c1*x[j+1]+c2*x[j+2]+c3*x[j+3]
      y[i+n]=c3*x[j]-c2*x[j+1]+c1*x[j+2]-c0*x[j+3]
   ENDFOR
   y[n-1]  =c0*x[2*n-2]+c1*x[2*n-1]+c2*x[0]+c3*x[1]
   y[2*n-1]=c3*x[2*n-2]-c2*x[2*n-1]+c1*x[0]-c0*x[1]
   n=n/2
   x=y
ENDWHILE 

ENDELSE




RETURN,x

END


