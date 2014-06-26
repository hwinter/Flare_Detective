;
; From Lang's "Astrophysical Formulae", vol. 1, 3rd Ed. Formula 4.409
; Itself from Longair's "High Energy Astrophysics", vol. 1, 2nd Ed. Formula 3.1
;
;
; PURPOSE:
;	Yields the linear energy loss for an incident electron. by ionization (=collisions ???)
;	Returns -dE/dx in keV/cm, ro -dE/dt in keV/s
;
; Nel: (free or not) electron density of target. (=NZ)
;
; OPTIONAL INPUT:
;	/dt: if set, will return -dE/dt instead of -dE/dx
;
; EXAMPLE:
;	PRINT,electron_ionization_loss(0.3,1e10)
;-------------------------------------------------------------
FUNCTION electron_ionization_loss, beta, Nel, I=I, dt=dt
	IF NOT KEYWORD_SET(I) THEN I=13.6
	
	mec2=510980d	;eV
	c=29979245800d	;cm/s

	gamma=1./sqrt(1-beta^2.)
	Tmax=gamma^2. * mec2 * beta^2. / (1.+gamma)
	
	const=4.08e-31
	res=(ALOG((gamma^2. * mec2 * beta^2. * Tmax)/(2.*I^2.)) - (2./gamma - 1./gamma^2.)*ALOG(2) + 1./gamma^2. +(1.-1./gamma)^2. /8.  )/beta^2.	
	
	IF KEYWORD_SET(dt) THEN res=res*beta*c
	RETURN,res*const*Nel/1.6e-9
END
