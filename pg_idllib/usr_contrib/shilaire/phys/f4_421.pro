;=====================================================================
; From "Astrophysical Formulae" by Kenneth R. Lang, 3rd Ed., Springer
;=====================================================================

; Electron energy loss by synchroton radiation
;
;	Bfield : in gauss
;	gamma : lorentz factor
;
;	Result is d(gamma)/dt
;

FUNCTION f4_421,Bfield,gamma
	res=-1.6216e-9*DOUBLE(Bfield)^2*DOUBLE(gamma)^2
	RETURN,res
END


; Some comments:
; e-folding time is about 16/(B^2 * gamma) in years.
;
