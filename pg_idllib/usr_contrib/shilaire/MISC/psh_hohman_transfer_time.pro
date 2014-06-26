;+
; r in AU.
; Ve in km/s. 
;	Monopropellants (Attitude control): Ve~1 km/s
;	Typical solid fuel rocket: Ve~2.5 km/s	(Apollo:~3 km/s, delta-V: 2.8 km/s)
;	Kerosene/Lox: 3.5km/s
;	Liquid Hydrogen (LH2)/Lox (bipropellant): 4.5km/s (Space Shuttle main engine, Saturn V upper stage, Ariane 4 upper stage?, Ariane 5 all stages?)
;	Bi-propellant: 5 km/s
;	Ion thruster: 50 km/s
;	VASIMR: ~300 km/s
;	[Space Shuttle Orbiter has delta-V of 700 m/s (including de-orbit burn)]
; If mSun nor mEarth are used, then a solar mass is assumed.
; Result in terrestiral days.
; Sources:
;	http://en.wikipedia.org/wiki/Spacecraft_propulsion
;	http://en.wikipedia.org/wiki/Hohmann_transfer_orbit
;
; EX.   ;Hohman orbit transfer time between Earth LEO and Mars:
;	PRINT,psh_hohman_transfer_time(1,1.52)
;	;Between LEO and Moon:
;	PRINT,psh_hohman_transfer_time(6678,384000,/km,mE=1.)
;	;Between LEO and Geostationnary:
;	PRINT,psh_hohman_transfer_time(6678.16,42164.2,/km,mE=1.,ve=3)
;	;Between Earth and Mercury
;	PRINT,psh_hohman_transfer_time(1,0.387)
;	;Between Earth and Pluto
;	PRINT,psh_hohman_transfer_time(1,39.55)
;-
FUNCTION psh_hohman_transfer_time, r1, r2, mEarth=mEarth, mSun=mSun, km=km, DV=DV, Ve=Ve
	G=6.673d-11	; N.m^2.Kg^-2
	mS=1.98d30	; Kg
	mE=5.98d24	; Kg
	rE=499*299792458d ; m
	
	IF KEYWORD_SET(km) THEN D=1000d ELSE D=rE
	IF exist(mSun) THEN m=mS*mSun ELSE m=mS
	IF exist(mEarth) THEN m=mE*mEarth

	IF KEYWORD_SET(Ve) THEN DV=1
	IF KEYWORD_SET(DV) THEN BEGIN
		dVp=sqrt(G*m/r1/D)*(sqrt(2.*r2/(r1+r2))-1)
		dVa=sqrt(G*m/r2/D)*(1-sqrt(2.*r1/(r1+r2)))
		PRINT,"Delta-V at periapsis: "+strn(dVp/1000)+" km/s"
		PRINT,"Delta-V at apoapsis: "+strn(dVa/1000)+" km/s"
		PRINT,'Reaction (propellant) mass/Payload(structural) mass:'+strn(exp((dVp+dVa)/Ve/1000d)-1)
		PRINT,'Energy required, per Kg of propellant (100% efficiency): '+strn(0.5*(Ve*1000d)^2)+' J/Kg'
	ENDIF

	t=!dPI*sqrt((D*(r1+r2))^3/8/G/m)
	RETURN,t/86400d
END
