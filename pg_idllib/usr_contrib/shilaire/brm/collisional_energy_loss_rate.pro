; PSH 2003/02/25
;
; computes the power lost to collisions with ambiant plasma [kev/s], for an electron of kinetic energy E [keV].
; The inozation level (il) is defaulted to 1. (fully ionized)
;
; Domain of validity: non-relativistic...
; Use keyword /BETHEBLOCH for relativistic case (Bethe-Bloch is actually ALWAYS valid!).
;
;
; Source:
;	Brown 1971, 1972
;	Kontar, Brown, McArthur 2003
;
; EXAMPLE:
;	print, collisional_energy_loss_rate(25)
;	9.7813563	[kev/s]
;	print, collisional_energy_loss_rate(1d5,/BETHE)
;	4.5349475	[kev/s]
;	
; HISTORY:
;	2003/03/17: added keyword T [in keV]
;



FUNCTION collisional_energy_loss_rate, E, il, np=np, _extra=_extra
	
	IF NOT KEYWORD_SET(np) THEN np=1e10 ELSE np=DOUBLE(np)
	IF exist(il) THEN il=DOUBLE(il) ELSE il=1D
	
	Qc=collisional_energy_loss_crosssection(E,il,_extra=_extra)
	c=3d10		;[cm/s]
	mec2=510.98D	;[keV]	
	;ve=sqrt(2*E/mec2)*c
	ve=c*gamma2beta(1d + E/mec2)
	
	RETURN,np*ve*E*Qc	; keV/s
END
