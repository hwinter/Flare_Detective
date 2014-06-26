; Yields the rate of electrons [e-/s] that precipitated... (thick-target model),
; in units of 1e36 e-/s. Uses the Tandberg-Hanssen & Emslie (1988) formula, i.e. 
; assumes NR BH and NR limit of B-B hold...
;
; EXAMPLE:
;	PRINT, nonthermal_electrons(3,2.8,10)
;

FUNCTION nonthermal_electrons, gamma, F50, Ek, TURNOVER=TURNOVER
	g=DOUBLE(gamma)
	Aph=F50/50^(-g)
	IF KEYWORD_SET(TURNOVER) THEN ADDFRAC=1.0 ELSE ADDFRAC=0.	

	Ae=6.622e-3 * g*(g-1)/BETA(g-1,0.5) * Aph
	
	RETURN,Ae*DOUBLE(Ek)^(-g)*(ADDFRAC+1/g)
END
