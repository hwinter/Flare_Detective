;+
; NAME:
;      pg_fit_maxwellian
;
; PROJECT:
;      diffusion & acceleration (plasma physics)
;
; PURPOSE: 
;      fit a temperature & flux data set to a maxwellian
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
;      y: particle flux, in units of particles cm^-3 (mc^2)^-1
;   
; OUTPUTS:
;      par: an array of [integrated particle density,temperature]
;      
; KEYWORDS:
;
;
; HISTORY:
;       22-NOV-2005 written PG
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;       pgrigis@astro.phys.ethz.ch
;-

FUNCTION pg_maxw_fitfun,x,par

   RETURN,pg_maxwellian(x,par[0])*par[1]

END



FUNCTION pg_fit_maxwellian,e,y

   parinfo=...

   mpfitfun...

   RETURN... .


END
