FUNCTION psh_ebudget2_coll_evolution, Ae, delta, Ex, E, type=type
	F=Ae*E^(-delta)
	IF KEYWORD_SET(type) THEN BEGIN
		ss=WHERE(E LT Ex)
		IF ss[0] NE -1 THEN BEGIN
			CASE type OF
				1: F[ss]=Ae*Ex^(-delta)
				2: F[ss]=Ae*Ex^(-delta)*E[ss]/Ex
				ELSE: F[ss]=1d-20
			ENDCASE
		ENDIF
	ENDIF
	RETURN,F
END
