;+
; NAME:
;
; PG_FP_MAXW_COEFF
;
; PURPOSE:
;
; computes coefficients that describe the interaction of an arbitrary species
; (a, the "test" particles) with a mawellian species (b, the "field" particles).
;
; **** NOTE: this uses SI units, not CGS ***
;
; CATEGORY:
;
; Plasma kinetics utils
;
; CALLING SEQUENCE:
;
; res=pg_fp_maxw_coeff(v)
;
; INPUTS:
;
; va: the speed of the test particles (in m/sec)
;
; OPTIONAL INPUTS:
;
; ma: mass of the test particles (in units of the electron mass)
; ma: mass of the field particles (in units of the electron mass)
; nb: density of the field particles (part/m^3, default: 10^16 part/m^3)
; ea: charge of the test particle in units of elementary charge (default:1)
; eb: charge of the field particles in units of elementary charge (default:1)
; tb: temperature of field particles in units of 10^6 K=1MK (default: 1MK)
; lnlambda: coulomb logarithm (default:20)
;
; KEYWORD PARAMETERS:
;
;
;
; OUTPUTS:
;
;
;
; OPTIONAL OUTPUTS:
;
;
;
; COMMON BLOCKS:
;
;
;
; SIDE EFFECTS:
;
;
;
; RESTRICTIONS:
;
;
;
; PROCEDURE:
;
; See:
;
;  REF 1: Collisional Transport in Magnetized Plasmas. Helander & Sigmar, CUP 2002
;
; EXAMPLE:
;
;
; AUTHOR:
;
; Paolo Grigis
; pgrigis@cfa.harvard.edu
;
; MODIFICATION HISTORY:
;
; 17-DEC-2008 PG written
;
;-

FUNCTION pg_fp_maxw_coeff,va,ma=ma,nb=nb,ea=ea,eb=eb,tb=tb,mb=mb,lnlambda=lnlambda

IF n_elements(va) LT 1 THEN BEGIN 

   print,'Please input the speed of the test particle distribution va'

ENDIF

;initializations and value checking

pi=3.141592653589793
c=299792458d0;speed of light
ec=1.602176487d-19 ;elementary charge: 1 Coulomb
mu=4*pi*1d-7;magnetic constant, a.k.a. vacuum permeability
eps0=1d0/(mu*c*c);electrical constant, a.k.a. vacuum permittivity
kb=1.3806504d-23;Boltzmann constant

nb=fcheck(nb,1d16);density of field particles/m^3
lnlambda=fcheck(lnlambda,20);Coulomb logarithm

elmass=9.10938215d-31;electron mass in kg
ma=fcheck(ma,1.0)*elmass
mb=fcheck(mb,1.0)*elmass

ea=fcheck(ea,1.0)*ec
eb=fcheck(eb,1.0)*ec
tb=fcheck(tb,1.0)*1d6
vtb=sqrt(2*kb*tb/mb)

;Eq. 3.48 in ref 1
;does not contain Ta because it cancels away
nuab=nb*ea*ea*eb*eb*lnlambda/(4*pi*eps0*eps0*ma*ma)

xb=va/vtb

gx=pg_chandragfunc(xb)

redm=1d0+mb/ma;reduced mass

nupar=2*nuab*gx/va^3;parallel diffusion coefficient
nuslow=nuab*ma*kb*redm*gx/(va*tb);slowing down coefficient
nudiff=nuab*(erf(xb)-gx)/va^3;diffusion coeff

result={va:va,nupar:nupar,nuslow:nuslow,nudiff:nudiff,nuab:nuab,ma:ma,mb:mb,ea:ea,eb:eb,tb:tb,lnlambda:lnlambda}

RETURN,result

END


