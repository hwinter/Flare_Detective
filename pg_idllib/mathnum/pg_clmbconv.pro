;+
; NAME:
;      pg_clmbconv
;
; PROJECT:
;      diffusion & acceleration (plasma physics)
;
; PURPOSE: 
;      returns the value of the Coulomb Convection term
;      as used by Miller in Miller 1996
;
; EXPLICATION:
;      
;
;
; CALLING SEQUENCE:
;     
;
; INPUTS:
;      e: energy (or energies) of the test particle, in units of mc^2
;      t: thermal energy of the field plasma, in units of mc^2
;   
; OUTPUTS:
;      
;      
; KEYWORDS:
;
;
; HISTORY:
;       17-JUN-2005 written PG
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;
;-

FUNCTION pg_clmbconv,e,t


   x=e/t
 
   ;elchrg=4.8032d-10;electron charge
   ;lnlambda=18.;coulomb logarithm
   ;nh=1d10;density of protons in the field plasma
   ;nu_0=4*!DPi*elchrg^4*lnlambda*nh/elmass^2
   ;c=2.9979246d10;speed of light
   ;mc2=elmass*c*c;factor mc^2

   elmass=9.1093826d-28;electron mass
   nu_0=1.4508709d29; factor nu_0 in Miller without the v^-3 term
   mc2=8.1871048d-7 ; electron mass times c^2

   ee=e*mc2;transform e --> ee=e*m*c^2 in ergs

   res=-2*nu_0*2^(-1.5)*elmass^(1.5)*ee^(-0.5)*(pg_hubapsi(x)-pg_hubadiffpsi(x))

   RETURN,res

END
