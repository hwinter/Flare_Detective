;+
; NAME:
;      pg_brem_genbh
;
; PURPOSE: 
;      returns the full bremsstralung cross section 3BN from Koch &
;      Motz (Rev. Mod. Phys. 31,4,920 (1959)), that is, the
;      relativistic Bethe-Heitler formula from Bethe & Heitler,
;      Proc. Roy. Soc. A146, 83 (1934) with the Elwert correction
;      factor (Elwert, Ann. Phys. 34, 178 (1039). 
;      This is ok for low Z elements, shown by Pratt & Tseng
;      Phys. Rev. A11,1797 (1975) [numerical solution of the
;      Dirac equation]. The cross section returned is differential
;      in photon energy and has the units cm^-2 keV^-1   
;
; CALLING SEQUENCE:
;      cross_sec=f_brem_genbh(phe,ele,z)
;
; INPUTS:
;      phe: photon energy in keV, only one value allowed
;           (if array is put in, then the 0th element is taken)
;      ele: electron energy in keV, can be an array
;      z: average atomic number in target (default: 1.)
;
; KEYWORDS:
;      nonrelativistic: if set, computes the nonrelativistic 
;      approximation (formula 3BN(a)) from Koch & Motz
;      ultrarelativistic: if set, computes the ultrarelativistic approximation (
;      formula 3BN(b)) from K&M
;
;      justborn: if set, does not use the Elwert correction
;      factor (that is, just the born approx is used)
;
; OUTPUT:
;      cross section differential in photon energy in cm^2
;       
;
; COMMENT:
;      see also Haug, A&A 326,417 (1997)
;
; EXAMPLE   
;
;
;
; VERSION:
;       20-OCT-2005 written PG
;       11-SEP-2006 added ultrarel. keyword PG
;       
; AUTHOR:
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;       pgrigis@astro.phys.ethz.ch
;-

FUNCTION pg_brem_genbh,phe,ele,z,nonrelativistic=nonrelativistic $
                      ,justborn=justborn,brownapprox=brownapprox $
                      ,ultrarelativistic=ultrarelativistic

z=fcheck(z,1d); default mean atomic number: 1

mc2   = 510.998918d ;rest mass of the electron, in keV
alpha = 7.297352568d-3 ;fine structure constant, dimensionless

;elrad = 2.817940325e-13; classical electron radius, in cm
elrad2 = 7.9407879d-26; classical electron radius squared, in cm^2

ans=0d *ele
ind=where(ele GT phe[0],count)

IF count GT 0 THEN BEGIN 

   ekel=ele[ind]/mc2 ;electron kinetic energy ekel
   k=phe[0]/mc2      ;photon energy k, just one value

   E0	= 1d + ekel             ; total electron energy before the collision, in mc^2 units
   p0	= sqrt(E0*E0-1d)         ; electron momentum before, in mc units
   E1	= E0 - k                ; total electron energy after the collision
   p1	= sqrt(E1*E1-1d)         ; electron momentum after

   IF keyword_set(brownapprox) THEN BEGIN

      ;non relativistic approx as used by Brown (1971)
      ;it is not identical to K&M 3BN(a) in order (E/mc^2)^2
      ;but since this is the non-relativistic approximation anyway
      ;this is fine, however here we distinguish between the two
      cross=1/ekel/k*8./3.*alog((1+sqrt(1-phe[0]/ele[ind]))/(1-sqrt(1-phe[0]/ele[ind])))

   ENDIF ELSE BEGIN  

      IF keyword_set(ultrarelativistic) THEN BEGIN

         E1ovE0=E1/E0

         ;K&M 3BN(a), non-relativistic approximation
         cross=4d/k*(1+E1ovE0*E1ovE0-2./3.*E1ovE0)*(alog(2*E0*E1/k)-0.5d)

      ENDIF ELSE BEGIN  

      IF NOT keyword_set(nonrelativistic) THEN BEGIN 

         ;full K&M 3BN (relativistic Bethe-Heitler)

         ;numerical factors
         a1=4d /3
         a2=8d /3

         ;often used products & quotients
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

         cross=cross*p1/(p0*k)

      ENDIF ELSE BEGIN 
         
         ;K&M 3BN(a), non-relativistic approximation
         cross=(16d /3)/(k*p0*p0)* alog((p0+p1)/(p0-p1))

      ENDELSE
      ENDELSE 

   ENDELSE


   ;elwert factor computation
   ;if used, makes born approximation ok for the limit of
   ;scattered electron energy --> 0
   IF NOT keyword_set(justborn) THEN BEGIN

      elwert=(E1*p0)/(E0*p1)*(1-exp(-Z*alpha*2*!DPi*E0/p0))/(1-exp(-Z*alpha*2*!DPi*E1/p1))

   ENDIF ELSE BEGIN 

      elwert=1d

   ENDELSE

   ;final division by mc2 needed in order to get the cross
   ;section in units of cm ^-2 keV^-1 instead of cm^2
   ans[ind]=cross*elwert*z*z*alpha*elrad2/mc2

ENDIF

RETURN,ans

END
