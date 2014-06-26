;+
; NAME:
;      pg_maxwellian
;
; PROJECT:
;      diffusion & acceleration (plasma physics)
;
; PURPOSE: 
;      returns a maxwellian distribution
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
;       21-JUN-2005 written PG
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;
;-

FUNCTION pg_maxwellian,e,t;,n0

;   n0=fcehck(n0,1.)

   x=double(e/t)

   ;elmass=9.1093826d-28         ;electron mass
 

   ;nu_0=1.4508709d29; factor nu_0 in Miller without the v^-3 term
 ;  mc2=8.1871048d-7 ; electron mass times c^2

   maxw=2d/sqrt(!DPi)*sqrt(x)/(t)*exp((-x) > (-708.))

   ;ee=e*mc2;transform e --> ee=e*m*c^2 in ergs

   ;res=4*nu_0*sqrt(ee)*2^(-1.5)*elmass^(1.5)*(pg_hubapsi(x))/x

   RETURN,maxw

END
