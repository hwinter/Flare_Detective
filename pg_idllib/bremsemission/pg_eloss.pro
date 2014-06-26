;+
; NAME:
;      pg_eloss
;
; PURPOSE: 
;      return the electron energy loss cross section (for collisions
;      with other electrons). Two versions: 1) non relativistic
;      2) relativistic by using Bethe-Bloch
;      The quantity returned is sigma*E=(dE/dt)/(n_traget*v(E))=(dE/dx)/n_target 
;
; INPUTS:
;      ele: electron energy in keV, can be an array
;      coulomblog: the coulomb logarithm
;
; KEYWORDS:
;      
;
; OUTPUT:
;      cross section differential in electron energy in cm^2
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
;       11-NOV-2005 written PG
;       
; AUTHOR:
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;-

FUNCTION pg_eloss,ele,coulomblog=coulomblog,relativistic=relativistic

coulomblog=fcheck(coulomblog,20)

;elcharge=4.8032044d-10;electron charge in statcoulombs/esu (1C=2.998*10^9 statc)
;kev=1.60217653d-9;value of 1 kev in ergs
;C=2*!Dpi*elcharge^4/kev^2
C=1.30282d-19

IF NOT keyword_set(relativistic) THEN BEGIN 
   sigma=C*coulomblog/ele
ENDIF ELSE BEGIN 
   mc2   = 510.998918d ;rest mass of the electron, in keV
   gamma=1d +ele/mc2
   betasq=1d - 1d /(gamma*gamma)
   sigma=C*(coulomblog+alog(gamma*gamma)-betasq)/(betasq*mc2*0.5)
ENDELSE


RETURN,sigma

END
