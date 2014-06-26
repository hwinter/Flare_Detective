;+
; PSH 2004/09/09
;
; See ~(1.222) from Lang's Astrophysical Formulae (3rd Ed.)
;
; Gives the optical depth of bremsstrahlung emission. >~1 means we're getting optically thick.
;
; T is temperature of emitting plasma (in K)
; nu is grequency (in Hz).
; Ni_Ne_l is Ni*Ne*l in cm^-5
; Refractive index is assumed unity.
; Z=1.44
;
; EXAMPLE:
;	PRINT,brems_optical_depth(1d7, 1d10, 2d31)	;T=10MK, EM=10^49, cube size=10"
;
;-

FUNCTION brems_optical_depth, T, nu, Ni_Ne_l
	IF T LT 3.16d5 THEN tmp=ALOG(4.954d7*(T^1.5/nu/Z)) ELSE tmp=ALOG(4.7d10*(T/nu))
	RETURN,9.786d-3/nu^2/T^1.5*tmp*Ni_Ne_l
END
