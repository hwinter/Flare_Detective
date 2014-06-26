;+
; NAME:
;      pg_collnu_d
;
; PROJECT:
;      Coulomb collisions
;
; PURPOSE: 
;      returns the value of the  collision frequencies 
;      (from Helander & Sigmar, page 38)
;      Here, the "D" (deflection) frequency is returned
;
;      This assumes particles with speed v and mass m_a, charge q_a streaming
;      through a medium filled with particles of mass m_b, charge q_b with given
;      temperature and density.
;
;
; CALLING SEQUENCE:
;      y=pg_collnu_d(v,coulomblog=coulomblog,dens=dens,temp=temp
;                   ,massa=massa,massb=massb,charga=charga,chargb=chargb)
;
; INPUTS:
;      x: an array of speeds
;      dens: ambient density (particles b)
;      temp: ambient temperature (particles b)
;      massa,massb: mass of the two species
;      charga,chargb: charge of the two species
;      coulomblog: the coulomb logarithm of the plasma
;   
; OUTPUTS:
;      y: an array of values for the collision frequencies
;      
; KEYWORDS:
;
;
; HISTORY:
;       21-DEC-2006 written PG
;
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;
;-

;.comp pg_collnu_d

FUNCTION pg_collnu_d,v,logfactor=logfactor,dens=dens,temp=temp $
                    ,massa=massa,massb=massb,charga=charga,chargb=chargb

coulomblog=fcheck(coulomblog,1.)
dens=fcheck(dens,1.)
temp=fcheck(temp,1.)

massa=fcheck(massa,1)
massb=fcheck(massb,1)
charga=fcheck(charga,1)
chargb=fcheck(chargb,1)

eps_0=1.;to be changed later to eps nought true value

nuab=dens*charga^2*chargb^2*coulomblog/(4*!Dpi*eps_0^2*massa^2)

xb=v/sqrt(2*temp/massb)

return,nuab*(erf(xb)-pg_chandrag(xb))/v^3


END
