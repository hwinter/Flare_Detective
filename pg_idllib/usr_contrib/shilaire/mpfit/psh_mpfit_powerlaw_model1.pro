; broken power-law, with spectral index=1.5 before break.
; params=[EphTO, gamma, F50]
;

FUNCTION psh_mpfit_powerlaw_model1, ALOG10_Eph, params
	
	Eph=10^ALOG10_Eph
	F=params[2]*(Eph/50d)^(-params[1])
	ss=WHERE(Eph LE params[0])
	IF ss[0] NE -1 THEN F[ss]=params[2]*(params[0]/50d)^(-params[1]) * (Eph[ss]/params[0])^(-1.5)
	RETURN,ALOG10(F)
END
