;+
; NAME:
;      pg_efacc_dimless
;
; PROJECT:
;      diffusion & acceleration (plasma physics)
;
; PURPOSE: 
;      returns the value of the "systematic acceleration" Convection term
;      in dimensionless format and as a function of logarithmic energy
;      the acceleration is provided by an external electric field
;
; EXPLICATION:
;      
;
;
; CALLING SEQUENCE:
;     
;
; INPUTS:
;      y:  energy (or energies) of the test particle, in units of log_10(E/mc^2)
;      yt: thermal energy of the field plasma, in units of
;          log_10(ETherm/mc^2)
;      dtime: basic time unit in seconds
;   
; OUTPUTS:
;      
;      
; KEYWORDS:
;
;
; HISTORY:
;       11-JUL-2005 written PG
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;
;-

FUNCTION pg_efacc_dimless,y,dtime,efield=efield

   dtime=fcheck(dtime,2.09d-7)


   ;x=10^(y-yt)
 
   elcharge=4.8032d-10;electron charge
   ;lnlambda=18.;coulomb logarithm
   ;nh=1d10;density of protons in the field plasma
   ;nu_0=4*!DPi*elchrg^4*lnlambda*nh/elmass^2
   c=2.9979246d10;speed of light
   ;mc2=elmass*c*c;factor mc^2

   ;elmass=9.1093826d-28;electron mass
   ;nu_0=1.4508709d29; factor nu_0 in Miller without the v^-3 term
   ;mc2=8.1871048d-7 ; electron mass times c^2

   ;ee=e*mc2;transform e --> ee=e*m*c^2 in ergs

   res=-elcharge*efield*c*sqrt(2)*10^(0.5*y)*dtime

   RETURN,res

END
