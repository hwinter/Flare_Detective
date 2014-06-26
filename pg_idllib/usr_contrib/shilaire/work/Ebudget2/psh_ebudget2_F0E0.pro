; EXAMPLE:
;	E0=DINDGEN(100)+1
;	PLOT,E0,psh_ebudget2_F0E0(E0, 1, 4, 20, type=1),/XLOG,/YLOG
;

FUNCTION psh_ebudget2_F0E0, E0, Ae, delta, Ex, type=type
	E=DOUBLE(E0)
	A=DOUBLE(Ae)
	d=DOUBLE(delta)
	Exx=DOUBLE(Ex)
	
	F=A*E^(-d)					;ideal power-law all the way
	IF KEYWORD_SET(type) THEN BEGIN
		ss=WHERE(E LT Exx)
		IF ss[0] NE -1 THEN BEGIN
			CASE type OF
				1: F[ss]=A*Exx^(-d)	;turnover
				2: F[ss]=A*Exx^(-d)*E[ss]/Exx	;linear increase below Ex
				ELSE: F[ss]=1d-20	;cutoff
			ENDCASE
		ENDIF
	ENDIF
	RETURN,F
END
