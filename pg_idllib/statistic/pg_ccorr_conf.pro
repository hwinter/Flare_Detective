;+
; NAME:
;
; pg_ccorr_conf
;
; PURPOSE:
;
; calculates cross correlation coefficents + confidence interval,
; removing NaN from the data
;
; CATEGORY:
;
; statistics util
;
; CALLING SEQUENCE:
;
; res=pg_ccorr_conf(x,y,sig=sig)
;
; INPUTS:
;
; x,y: array to be cross correlated (must have same number of points)
;
; OPTIONAL INPUTS:
;
; sig: significance level (default:0.95)
;
; KEYWORD PARAMETERS:
;
;
;
; OUTPUTS:
;
; a structure contining:
;       r: the cross correlation coefficient
;       sig: the input  significance level of the range in r
;       rmin,rmax: r extreme values for sig confdence level
;       t: student's t for the correlation
;       tt: student's t which give a probablity of sig
;       z: Fisher's Z
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
; taken from Erwin Kreyszig, "Statistiche Methoden und ihre
; Anwendungen", Vandenhoeck & Ruprecht, 1975
;
; EXAMPLE:
;
; x=[1,3,4,6,8]
; y=[2,4,1,2,5]
; res=pg_ccorr_conf(x,y,sig=0.99)
;
; AUTHOR:
; 
; Paolo Grigis, Institute of Astronomy, ETH Zurich
; pgrigis@astro.phys.ethz.ch
;
; MODIFICATION HISTORY:
;
; written 22-MAR-2004 PG
;         12-APR-2007 corrected bug for the case where NAN's are present PG
;
;-

;.comp  pg_ccorr_conf

FUNCTION pg_ccorr_conf,x,y,sig=sig

sig=fcheck(sig,0.95)

nx=n_elements(x)
ny=n_elements(y)

IF nx NE ny THEN BEGIN
   print,'Aborting, returning -1'
   print,'x and y should have the same number of elements'
   RETURN,-2
ENDIF 

;removes nan
xnum_ind=where(finite(x+y),count_xnum)

IF count_xnum GT 0 THEN BEGIN
   x=x[xnum_ind]
   y=y[xnum_ind]
ENDIF ELSE BEGIN
   print,'Aborting, only NANs found in the input arrays'
   return,-1
   ;x2=x
   ;y2=y
ENDELSE
;ynum_ind=where(finite(y) EQ 0,count_ynum)
;IF count_ynum GT 0 THEN BEGIN
;   x2=x2[xnum_ind]
;   y2=y2[xnum_ind]
;ENDIF 

nx=n_elements(x)
ny=n_elements(y)
nf=nx-2

avx=total(x)/nx
avy=total(y)/ny

sigxx=total((x-avx)^2)
sigyy=total((y-avy)^2)
sigxy=total((x-avx)*(y-avy))

;these should be equal
r_1=sigxy/sqrt(sigxx*sigyy)
r_0=c_correlate(x,y,0)

r=r_1

;significance
;with t test
t=r*sqrt((nf)/(1-r*r))
tt=t_cvf(1-sig,nf)

;tsignif=1-ibeta(0.5*nf,0.5,nf/(nf+t*t),/double)
;significance --> is different from 0???

;confidence interval
z=0.5*alog((1+r)/(1-r))

c=gauss_cvf((1-sig)/2.)
a=c/sqrt(nx-3)

rr1=tanh(z-a)
rr2=tanh(z+a)

;tt=t_cvf(sig,nf)
;prob=ibeta(0.5*nf,0.5,nf/(nf+t*t),/double)

RETURN,{r:r,sig:sig,rmin:rr1,rmax:rr2,t:t,tt:tt,z:z};,tsignif:tsignif}

END

