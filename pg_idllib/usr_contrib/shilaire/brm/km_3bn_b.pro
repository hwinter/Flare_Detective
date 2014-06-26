;Koch & Mott (1959) formula 3BN(b) for electron bremsstrahlung differential cross-section (Born approximation, ultra-relativistic limit, without screening effects).
;
;
; Ee is initial electron energy, Eph is emitted photon energy, both in keV.
;


FUNCTION km_3bn_b, Ee, Eph, z=z, mb=mb
	IF NOT KEYWORD_SET(z) THEN z=1.2	
	IF KEYWORD_SET(mb) THEN alpha4r2=2.3104 ELSE alpha4r2=2.3104e-27	;cm^2
	mc2=510.98d ;keV

	gi=1d + DOUBLE(Ee)/mc2
	k=DOUBLE(Eph)/mc2
	gf=gi-k

	res=(1 + (gf/gi)^2 - 2/3*gf/gi) * (ALOG(2*gi*gf/k) - 0.5) / k
	ss=WHERE(Ee LT Eph)
	IF ss[0] NE -1 THEN res[ss]=0d
	RETURN, alpha4r2 * z^2 *res/mc2
END

