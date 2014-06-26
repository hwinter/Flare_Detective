; from LANG, Astrophysical Formulae (1.317)
;
; Input:
;	epsilon: ratio of initial photon energy to rest mass energy of scattering particle (an array).
;	theta: angle between incident wave propagation and direction of observation
;	phi: angle between incident electric field vector and direction of observation. Default is !dPI/4 (<=> natural polarization)
;	D: distance between free scattering particle and observer. Default is 1 A.U.
;
; OUTPUT:
;	ratio of intensity seen by observer to that of incident intensity on scattering particle(s)
;
;
; EXAMPLE:
;	I0=1.0*(FINDGEN(100))^(-3)
;	I=kn__scattering(I0,!dPI)
;
;

FUNCTION kn_scattering, epsilon, theta, phi=phi

	r0= 2.8e-13	;[cm]
	DSE= 499D * 3e10	;[cm]
	
	IF NOT KEYWORD_SET(phi) THEN phi=!dPI/4
	a=DOUBLE(epsilon)
	koverkp=1+a*(1-cos(theta))
	
	res= sin(phi)^2 / koverkp^3 * ( 1+ (a*(1-cos(theta)))^2/(2*sin(phi)^2 * koverkp)  )

	RETURN, res*(r0/DSE)^2
END
