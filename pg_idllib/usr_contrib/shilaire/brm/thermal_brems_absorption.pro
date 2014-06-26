; This routine the linear absorption of a plasma emitting thermal bremsstrahlung.
; Optical depth is absorption times path length.
;
; This formula should be valid from radio to the X-ray range, and any temperature.
;
; INPUT:
;	nu : frequency, in GHz, or in keV if /keV keyword is used)
;	T  : plasma temperature, in MK.	
;	
; OPTIONAL INPUT:
;	Nions: ion density, in m^-3	(default: 1e16)
;	Nelectrons: electron density, in m^-3	(default: 1e16)
;	gauntfactor: default is 1.2
;	z: default is 1.2
;
; OUTPUT:
;	linear absorption (attenuation), in units of [m^-1]	(yes! SI units!)
;
; EXAMPLE:
;	print,thermal_brems_absorption(1,1)
;	3.0240000e-07
;	print,thermal_brems_absorption(1,1,/kev)
;	4.4703091e-25
;
; RESTRICTIONS:
;	 Assumes no background source.
;

FUNCTION thermal_brems_absorption, GHz, MK, keV=keV, Nions=Nions, Nelectrons=Nelectrons, gauntfactor=gauntfactor, zee=zee

	nu=DOUBLE(GHz)
	IF KEYWORD_SET(keV) THEN nu=nu/4.14e-9
	T=DOUBLE(MK)
	IF KEYWORD_SET(Nions) THEN Ni=DOUBLE(Nions) ELSE Ni=1e16
	IF KEYWORD_SET(Nelectrons) THEN Nel=DOUBLE(Nelectrons) ELSE Nel=1e16
	IF KEYWORD_SET(gauntfactor) THEN g=DOUBLE(gauntfactor) ELSE g=1.2
	IF KEYWORD_SET(zee) THEN z=DOUBLE(zee) ELSE z=1.2	

	absorption = 6.3 * (nu)^(-3) * (z/1.2)^2 * (Ni * Nel/1e32) * (g/1.2) *(1 - exp(-4.8e-8 * nu/T))

	RETURN,absorption
END



