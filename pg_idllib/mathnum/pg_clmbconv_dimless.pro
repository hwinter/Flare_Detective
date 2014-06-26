;+
; NAME:
;      pg_clmbconv_dimless
;
; PROJECT:
;      diffusion & acceleration (plasma physics)
;
; PURPOSE: 
;      returns the value of the Coulomb Convection term
;      as used by Miller in Miller 1996 in dimensionless format
;      and as a function of logarithmic energy
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
;      density: density of the field particles [=target density]
;   
; OUTPUTS:
;      
;      
; KEYWORDS:
;
;
; HISTORY:
;       20-JUN-2005 written PG
;       21-NOV-2005 added density keyword (formerly assumed to be 1d10)
;       29-NOV-2005 added scale factor (careful with this: 1 means no
;       scaling [is set by default], a different value makes
;       collisions stronger/weaker, may lead to unphysical results) PG 
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;       pgrigis@astro.phys.ethz.ch
;
;-

FUNCTION pg_clmbconv_dimless,y,yt,dtime,density=density,clmblog=clmblog $
                            ,scale_factor=scale_factor

   scale_factor=fcheck(scale_factor,1d)

   dtime=fcheck(dtime,2.09d-7)
   density=fcheck(density,1d10)
   clmblog=fcheck(clmblog,18d)


   x=10^(y-yt)
 
   ;elchrg=4.8032d-10;electron charge
   ;lnlambda=18.;coulomb logarithm
   ;nh=1d10;density of protons in the field plasma
   ;nu_0=4*!DPi*elchrg^4*lnlambda*nh/elmass^2
   ;c=2.9979246d10;speed of light
   ;mc2=elmass*c*c;factor mc^2

   elmass=9.1093826d-28;electron mass
   nu_0=8.0604d17*density*clmblog ; factor nu_0 in Miller without the v^-3 term
   mc2=8.1871048d-7 ; electron mass times c^2

   ;ee=e*mc2;transform e --> ee=e*m*c^2 in ergs

   res=-scale_factor*2*nu_0*2^(-1.5)*elmass^(1.5)*mc2^(-1.5)*10^(-0.5*y) $
         *(pg_hubapsi(x)-pg_hubadiffpsi(x))*dtime

   RETURN,res

END
