; these formulae were taken from Arnold Benz's book: "Plasma Astrophysics", Kluwer ed,.1993

; returns the thermal self-collision time. It is also the characteristic time after which the bulk of a plasma
; regains thermal equilibrium after a disturbance.

;	Temp in MK
;	Na in cm^-3
;	ma in units of me (electron mass)
;	Za
;
;	result in seconds
;

FUNCTION fab_2_6_26,Temp=Temp,Za=Za,Na=Na,ma=ma

	IF NOT KEYWORD_SET(Temp) THEN Temp=2
	IF NOT KEYWORD_SET(Za) THEN Za=1
	IF NOT KEYWORD_SET(Na) THEN Na=10^10
	IF NOT KEYWORD_SET(ma) THEN ma=1
	IF NOT KEYWORD_SET(Za) THEN Za=1

	T=DOUBLE(Temp)
	Z=DOUBLE(Za)
	n=DOUBLE(Na/10^10)
	m=DOUBLE(ma)
	
	res=1.34e-3 * T^1.5 / Z^4 / n * m^0.5
	
	RETURN,res
END


