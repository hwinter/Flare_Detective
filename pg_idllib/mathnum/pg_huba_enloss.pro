;+
; NAME:
;      pg_huba_enloss
;
; PROJECT:
;      diffusion & acceleration (plasma physics)
;
; PURPOSE: 
;      returns the value of the energy loss term
;      as given by Huba (NRL plasma formulary)
;
; EXPLICATION:
;      
;
;
; CALLING SEQUENCE:
;     
;
; INPUTS:
;      v: energy (or energies) of the test particle(s), in units
;         of mc^2
;      t: thermal energy of the field plasma, in units of mc^2
;   
; OUTPUTS:
;      
;      
; KEYWORDS:
;
;
; HISTORY:
;       05-JUL-2005 written PG
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;
;-

FUNCTION pg_huba_enloss,e,t

   x=e/t
 
   ;elchrg=4.8032d-10;electron charge
   ;lnlambda=18.;coulomb logarithm
   ;nh=1d10;density of protons in the field plasma
   ;nu_0=4*!DPi*elchrg^4*lnlambda*nh/elmass^2
   ;c=2.9979246d10;speed of light
   ;mc2=elmass*c*c;factor mc^2

;   elmass=9.1093826d-28;electron mass
   nu_0=1.4508709d29; factor nu_0 in Miller without the v^-3 term
;   mc2=8.1871048d-7 ; electron mass times c^2
   c=3d10;light speed in cm/s

   res=-nu_0*(pg_hubapsi(x)-pg_hubadiffpsi(x))*1/(sqrt(e)*c^3*sqrt(2))

   RETURN,res

END
