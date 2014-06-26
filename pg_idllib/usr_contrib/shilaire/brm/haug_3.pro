;Haug (1997) formula (3): extreme-relativistic limit of the Bethe-Heitler formula... (so he says...)
;
;
; Ee is initial electron energy, Eph is emitted photon energy, both in keV.
;


FUNCTION haug_3, Ee, Eph, z=z, mb=mb
	IF NOT KEYWORD_SET(z) THEN z=1.2	
	IF KEYWORD_SET(mb) THEN alpha4r2=1.1552 ELSE alpha4r2=1.1552e-27	;cm^2
	mc2=510.98d ;keV

	e1=1d + DOUBLE(Ee)/mc2
	k=DOUBLE(Eph)/mc2
	e2=e1-k

	res=(4*e1*e2/3 + k^2) * (2*ALOG(2*e1*e2/k) - 1) / k / (e1-1)
	ss=WHERE(Ee LT Eph)
	IF ss[0] NE -1 THEN res[ss]=0d
	RETURN, alpha4r2 * z^2 *res/mc2
END

