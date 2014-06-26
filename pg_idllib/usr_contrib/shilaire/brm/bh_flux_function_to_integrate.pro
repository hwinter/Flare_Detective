; PSH 2003/02/25
; see betheheitler_brm_crosssection.pro for usage.
;


FUNCTION bh_flux_function_to_integrate, Eel, Eph=Eph, Nel50=Nel50, Nt=Nt, delta=delta, Ecutoff=Ecutoff
	E=DOUBLE(Eel)
	IF KEYWORD_SET(Eph) THEN epsilon=DOUBLE(Eph) ELSE epsilon=50D		;in [keV]
	IF KEYWORD_SET(Nel50) THEN N50=DOUBLE(Nel50) ELSE N50=1D		;in [e- keV^-1]
	IF KEYWORD_SET(delta) THEN delta=DOUBLE(delta) ELSE delta=4D		;spectral index
	IF KEYWORD_SET(Nt) THEN Nt=DOUBLE(Nt) ELSE Nt=1e10			;target density [cm^-3]
	
	;cross-section: 
	q=betheheitler_brm_crosssection(E,epsilon)	;[cm^2 keV^-1]
	
	;electron number spectrum (whole source):
	Fe=N50*(E/50)^(-delta)		; [e- keV^-1]
	IF KEYWORD_SET(Ecutoff) THEN IF E LT Ecutoff THEN Fe=0D
	
	;electron spectral flux:
	ve=sqrt(2*E/510.98)*3e10	; [cm/s]
	je=ve*Fe*nt			;[e- s^-1 cm^-2 kev^-1]

	RETURN,	q*je
END
