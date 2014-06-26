; This calculates thick-target non-thermal power of electron beam from observed photon power-law spectrum,
; assuming the B-H NR brm cross-section.
;
; from H.S. HUDSON, 1978
;
; Default is CUTOFF electron distribution, not TURNOVER
; Default is to use the Tandberg-Hanssen & Emslie (1988) formula, not the Hudson, 1978.
;
; Eto in keV. (turn-over, or cut-off energy...)
;
; RESULT is in [erg/s]


FUNCTION nonthermal_power, gamma, F50, Eto, TURNOVER=TURNOVER, HUDSON=HUDSON
	g_obs=DOUBLE(gamma)
	Aph_obs=F50/50^(-g_obs)
	Ek=DOUBLE(Eto)
	IF KEYWORD_SET(TURNOVER) THEN ADDFRAC=0.5 ELSE ADDFRAC=0.	
	IF KEYWORD_SET(HUDSON) THEN RETURN, 1.6e-9*3.28e33*g_obs^2. * (g_obs-1.)^2. * BETA(g_obs-0.5,1.5) * Aph_obs * Ek^(-g_obs+1.) * (ADDFRAC + 1./(g_obs-1.)) ELSE BEGIN
			;const=4*!dPI*D^2 * Aph * K/Kbh /Z^2 
			;K=2*!dPI*e^4*lambda
			;lambda=20d for fully-ionized plasma
			;Kbh=8/3/137*r0^2*me*c^2	;the constant in the NR B-H brm cross-section of Koch&Mott (1959) 3BN(a)
			;Z^2=1.4
		const=6.62e33
			;Ae=const*Aph_obs*g_obs*(g_obs-1)/BETA(g_obs-1,0.5)
			;P=Ae*Ek^(1-g_obs)/(g_obs-1)
		P=const*Aph_obs*g_obs*(g_obs-1)/BETA(g_obs-1,0.5)*Ek^(1-g_obs)*(ADDFRAC+ 1./(g_obs-1))
		RETURN,1.6e-9*P		; converts from keV/s to erg/s		
	ENDELSE
END

