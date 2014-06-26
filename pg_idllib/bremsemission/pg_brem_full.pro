;+
; NAME:
;      pg_brem_full
;
; PURPOSE: 
;      returns the full bremsstralung cross section 3BN from Koch & Motz
;
; CALLING SEQUENCE:
;      f_brem_full,phe,ele
;
; INPUTS:
;      phe: photon energy, only one value allowed
;           (if array is put in, then the 0th element is taken)
;      ele: electron energy, can be an array
;
; KEYWORDS:
;      nonrelativistic: if set, computes the nonrelativistic version
;
; OUTPUT:
;      cross section
;       
;
; COMMENT:
;
;
; EXAMPLE   
;
;
;
; VERSION:
;       18-OCT-2005 written PG, based on routine sigma by K. Arzner
;       
; AUTHOR:
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;-

PRO pg_brem_full_test
   
N=1000

ele=10^(dindgen(N)/(N-1)*10-5)
phe=50.;/511.

plot,phe/ele,pg_brem_full(phe,ele,/elwert),xrange=[0.1,1],yrange=[0,100],psym=-6;,/xlog
;oplot,phe/ele,pg_brem_full(phe,ele,/nonrel),color=12
;oplot,phe/ele,pg_brem_full(phe,ele,/elwert),color=2

twoar02 = 1.15893512d-27

brm_bremcross,ele,phe, 1., cross

oplot,phe/ele,cross/twoar02*ele*phe*1.8d-5,color=12,psym=-4;,/xlog,xrange[0.01,1]


brm_bremcross,100.,20., 1., c

print,pg_brem_full(20.,100.,/elwert)
print,c/twoar02/511.


END


FUNCTION pg_brem_bh_core,e0,p0,e1,p1,k

;numerical factors
a1=4d /3
a2=8d /3

;often used products
e0e1   = e0*e1
p0p1   = p0*p1
p0p1inv= 1d/p0p1
p1p1   = p1*p1
p0p0   = p0*p0
p03inv = 1d /(p0p0*p0)
p13inv = 1d /(p1p1*p1)
p4inv  = p0p1inv*p0p1inv

eps0=alog((e0+p0)/(e0-p0))
eps1=alog((e1+p1)/(e1-p1))

fact2=eps0*p03inv*(e0e1+p0p0)-eps1*p13inv*(e0e1+p1p1)+2d *k*e0e1*p4inv
fact1=a2*e0e1*p0p1inv+k*k*(e0e1*e0e1+p0p0*p1p1)*p03inv*p13inv+0.5d *k*p0p1inv*fact2

L=2d *alog((e0e1+p0p1-1d)/k)

cross=a1-2*e0e1*(p0p0+p1p1)*p4inv+eps0*e1*p03inv+eps1*e0*p13inv-eps0*eps1*p0p1inv+L*fact1

return,cross*p1/(p0*k)*p0p0*k

END


FUNCTION pg_brem_full,phe,ele,nonrelativistic=nonrelativistic $
                     ,warning=warning,elwert=elwert


res=ele*0.
ind=where(ele GE phe[0],count)

Z=1.

IF count GT 0 THEN BEGIN 

   ekel=ele[ind]/511.;electron kinetic energy ekel
   k=phe[0]/511.     ;photon energy k, just one value

   E0	= 1d + ekel             ; total in electron energy, in mc^2
   p0	= sqrt(E0^2-1d)         ; in electron momentum
   E1	= E0 - k                ; total out electron energy
   p1	= sqrt(E1^2-1d)         ; out electron momentum		

IF keyword_set(warning) THEN BEGIN
   beta0=p0/E0
   beta1=p1/E1
   ind1=where(2*!PI*Z/(beta0*137) GE 0.2,count1)
   ind2=where(2*!PI*Z/(beta1*137) GE 0.2,count2)
   IF count1 GT 0 OR count2 GT 0 THEN BEGIN 
     print,'Warning! Born approximation does not hold!!!'
     print,ekel[max(ind1)]*511.
     print,ekel[max(ind2)]*511.
  ENDIF
ENDIF


   IF NOT keyword_set(nonrelativistic) THEN BEGIN 
      L	= 2*alog((E0*E1+p0*p1-1)/k)
      eps0	= alog((E0+p0)/(E0-p0))
      eps1	= alog((E1+p1)/(E1-p1))
      a1	= - 2*E0*E1*(p1^2+p0^2)/(p0^2*p1^2) + eps0*E1/p0^3 + eps1*E0/p1^3 - eps1*eps0/(p0*p1)
      b1	= (E0*E1+p0^2)/p0^3*eps0 - (E0*E1+p1^2)/p1^3*eps1 + 2*k*E0*E1/(p0^2*p1^2)
      a2	= 8*E0*E1/(3*p0*p1) + k^2*(E0^2*E1^2+p0^2*p1^2)/(p0^3*p1^3) + k/(2*p0*p1)*b1
      Q	= p0*p0*k* (p1/(p0*k)*(4./3. + a1 + L*a2)) ;factor at the beginning because
                                ;of def of q vs. Q (see Brown 2004)

   ENDIF ELSE BEGIN 
      Q=16d / 3 * alog((p0+p1)/(p0-p1))
   ENDELSE

   IF keyword_set(elwert) THEN BEGIN
      elwert=(E1*p0)/(E0*p1)*(1-exp(-Z*2*!Pi*E0/p0/137))/(1-exp(-Z*2*!Pi*E1/p1/137))
   ENDIF ELSE BEGIN 
      elwert=1
   ENDELSE


   res[ind]=Q*elwert

ENDIF


RETURN,res

END
