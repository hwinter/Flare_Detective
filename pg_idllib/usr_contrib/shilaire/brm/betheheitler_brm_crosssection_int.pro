; E, epsilon in keV
; OUTPUT is in [cm^2/keV]
; Bethe-Heitler non-relativistic electron-ion bremsstrahlung cross-section for electron of energy E, differential in photon energy epsilon.
; Koch & Mott, 1959 (formula 3BN(a)); Brown J.C., 1971 (formula (1))
;
; Domain of validity: Non-relativistic,...
;
; MODIFICATIONS:
;	2003/06/11: added experimental /SCREENING keyword...
;	2003/06/15: E and/or epsilon can be arrays now. 
;
;
FUNCTION betheheitler_brm_crosssection_int,E,Ephoton=Ephoton, z=z, mb=mb, QUIET=QUIET
	
	Eel=DOUBLE(E)
	IF KEYWORD_SET(Ephoton) THEN Eph=DOUBLE(Ephoton) ELSE Eph=10d
	IF NOT KEYWORD_SET(z) THEN z=1.2d

	bad_ss=WHERE((Eel-Eph) LT 0.)
	IF NOT KEYWORD_SET(QUIET) THEN IF bad_ss[0] NE -1 THEN PRINT,'.... Bethe-Heitler bremmstrahlung cross-section put to 0 for Eph > Eel.'
	
	r0=2.818e-13	; classical electron radius [cm]
	alpha=1/137d	; fine structure constant
	mec2= 510.98d	; electron mass	[keV]
	
	K=Z^2*8d/3*alpha*mec2/Eel/Eph	
	IF KEYWORD_SET(mb) THEN K=K*79.41124d ELSE K=K*r0^2.
	;K is now in [cm^2 keV^-1] or [mb keV^-1]
	cross=K*ALOG((1+sqrt(1-Eph/Eel))/(1-sqrt(1-Eph/Eel)))
	IF bad_ss[0] NE -1 THEN cross[bad_ss]=0d
	RETURN,cross
END


