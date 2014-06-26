;
; The Bethe-Bloch formula gives the power loss per unit length due to
; ionization (= collisions ???), from a (heavy) charged particle particle 
; on a cloud of electrons.
;
; Relativistic quantum-mechanical treatment. Should be valid from the lowest energies up to relativistic energies.
; There are corrections for the very highest of energies, where this formula overestimates stuff.
;
; Taken from Longair's "High energy astrphysics" (1992), p.49: formula (2.16)
; 
; Nel is volume density of (not necessarily free) electrons.
; z is atomic number of incident particle
;
; OPTIONAL INPUT:
;	/dt: gives -dE/dt instead of -dE/dx
;
; OUTPUT:
;	keV/cm or keV/s
;
; EXAMPLE:
;	PRINT,bethebloch(0.3,1.,1e10,/dt)
;
;---------------------------------------------------------------------------
FUNCTION bethebloch, beta,z, Nel, I=I, dt=dt
	IF NOT KEYWORD_SET(I) THEN I=13.6
	mec2=510980d	; eV
	c=29979245800d	; cm/s
	
	const=4.08e-31
	gamma=1./sqrt(1-beta^2.)
	res=z^2./ beta^2. * (ALOG(2*gamma^2. * beta^2. * 510980d /I) - beta^2.)

	IF KEYWORD_SET(dt) THEN res=res*beta*c
	RETURN,res*const*Nel/1.6e-9
END
