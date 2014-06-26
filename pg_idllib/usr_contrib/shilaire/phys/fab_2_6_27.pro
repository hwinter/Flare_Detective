; these formulae were taken from Arnold Benz's book: "Plasma Astrophysics", Kluwer ed,.1993

; returns the thermal electron-ion collision time. Waves tha tinclude oscillating electrons are damped by
; collisional randomization of electron momentum on ions.

;	Temp in MK
;	Na in cm^-3
;	ma in units of me (electron mass)
;	Za
;
;	result in seconds
;

FUNCTION fab_2_6_27,Temp=Temp,Za=Za,Na=Na,ma=ma

	IF NOT KEYWORD_SET(Temp) THEN Temp=2
	IF NOT KEYWORD_SET(Na) THEN Na=10^10

	T=DOUBLE(Temp)
	n=DOUBLE(Na/10^10)
	
	res=1.65e-3 * T^1.5 / n 
	
	RETURN,res
END


