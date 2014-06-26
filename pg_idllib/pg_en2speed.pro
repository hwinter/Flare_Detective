;+
; NAME:
;      pg_en2speed
;
; PURPOSE: 
;      convert kinetic energy of particle into speed
;
; CALLING SEQUENCE:
;      res=pg_en2speed(energy)
;
; INPUTS:
;     
;      energy:energy of particle (in keV)
; 
;  
; OUTPUTS:
;      s: speed in varoious units
;      
; KEYWORDS:
;      /electron: if set, electron are used as particles
;      /ion: if set to 1, proton are used. If set to a number n, ions are taken
;      with mass m=n*proton mass
;
; HISTORY:
;       09-OCT-2006 written PG
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;       pgrigis@astro.phys.ethz.ch
;
;
;-

FUNCTION pg_en2speed,e,electron=electron,ion=ion

IF keyword_set(ion) THEN mc2=938272d*ion ELSE mc2=511d

gamma=1d + e/mc2
;beta=sqrt(gamma^2-1d)/gamma
beta=sqrt(1d -1d / (gamma*gamma))

return,beta*3d8


END

