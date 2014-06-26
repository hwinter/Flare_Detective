; see p.48 of Astrophysical Formulae by Lang.
;
; EXAMPLE:
;	w=FINDGEN(1000)+1	; emitted photon energy
;	PLOT,w,radiative_loss(w,gamma=10)
;

FUNCTION omega_s,gamma
	RETURN,2.6642*gamma^2		;output in keV.
END


FUNCTION radiative_loss,w,gamma=gamma		; output is dErad/dt
	IF NOT KEYWORD_SET(gamma) THEN gamma=10.
	res=DBLARR(N_ELEMENTS(w))
	ws=omega_s(gamma)
	ss=WHERE(w LE ws)
	IF ss[0] NE -1 THEN res[ss]=gamma*5.2565
	ss=WHERE(w GE ws)
	IF ss[0] NE -1 THEN res[ss]=gamma*alog(gamma)
		
	A=1.577*10^(-14)	;KeV/cm, assuming Ni=10^10 cm^-3
	RETURN, res	;A*res
END
