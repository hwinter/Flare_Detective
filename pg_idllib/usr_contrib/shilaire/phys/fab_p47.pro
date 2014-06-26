; these formulae were taken from Arnold Benz's book: "Plasma Astrophysics", Kluwer ed,.1993

;
; returns the collision times in seconds for NON_RELATIVISTIC test particles with
; vT >>vtF in a hydrogen plasma with primordial helium abundance and using cgs units.
; The values must be corrected by the factor 20/ln(OMEGA), being usually of the order of unity.
;
;INPUTS:
;	Time= 'd'eflection (default), 'e'nergyloss, 's'lowingDownTime (=momemtum loss time)
;
;	test='e' or 'p' default is 'e'
;	field='e' or 'i' default is 'e'
;
;	vTest	= v of test particle		[units of c]		; default is 0.1 c
;	vthe	= electron thermal velocity	[units of c]		; default is 0.03c (2MK plasma)
;	vthp	= proton thermal velocity	[units of c]		; default is 225 km/s (2MK plasma)
;	Nions	= ion density			[cm^-3]			; default is 10^10 cm^-3
;	Nelec	= electron density		[cm^-3]			; default is 10^10 cm^-3
;	
;	QUIET=QUIET

FUNCTION fab_p47,time=time,test=test,field=field,vTest=vTest,vthe=vthe,vthp=vthp,Nions=Nions,Nelec=Nelec,QUIET=QUIET
		
	IF NOT KEYWORD_SET(time) then time='d'
	IF NOT KEYWORD_SET(test) then test='e'
	IF NOT KEYWORD_SET(field) then field='e'
	IF NOT KEYWORD_SET(vTest) then vTest=0.33
	IF NOT KEYWORD_SET(vthe) then vthe=0.03
	IF NOT KEYWORD_SET(vthp) then vthp=0.00075
	IF NOT KEYWORD_SET(Nions) then Nions=10^10
	IF NOT KEYWORD_SET(Nelec) then Nelec=10^10
	
	vT=DOUBLE(vTest)
	vte=DOUBLE(vthe)
	vtp=DOUBLE(vthp)
	Ni=DOUBLE(Nions/10^10)
	Nel=DOUBLE(Nelec/10^10)
	
	res=1e-20
	IF ((time EQ 'd') AND (test EQ 'e') AND (field EQ 'e')) THEN res= 83.7 * vT^3/Nel
	IF ((time EQ 'e') AND (test EQ 'e') AND (field EQ 'e')) THEN res= 21.016 * vT^5/Nel/vte^2
	IF ((time EQ 's') AND (test EQ 'e') AND (field EQ 'e')) THEN res= 83.7 * vT^3/Nel
	
	IF ((time EQ 'd') AND (test EQ 'e') AND (field EQ 'i')) THEN res= 83.7 * vT^3/Ni
	IF ((time EQ 'e') AND (test EQ 'e') AND (field EQ 'i')) THEN res= 21.016 * vT^5/Ni/vtp^2
	IF ((time EQ 's') AND (test EQ 'e') AND (field EQ 'i')) THEN res= 134.72 * vT^3/Ni
	
	IF ((time EQ 'd') AND (test EQ 'p') AND (field EQ 'e')) THEN res= 2.6944e8 * vT^3/Nel
	IF ((time EQ 'e') AND (test EQ 'p') AND (field EQ 'e')) THEN res= 7.0054e7 * vT^5/Nel/vte^2
	IF ((time EQ 's') AND (test EQ 'p') AND (field EQ 'e')) THEN res= 2.9638e5 * vT^3/Nel
	
	IF ((time EQ 'd') AND (test EQ 'p') AND (field EQ 'i')) THEN res= 2.2633e8 * vT^3/Ni
	IF ((time EQ 'e') AND (test EQ 'p') AND (field EQ 'i')) THEN res= 7.0054e7 * vT^5/Ni/vte^2
	IF ((time EQ 's') AND (test EQ 'p') AND (field EQ 'i')) THEN res= 2.5058e8 * vT^3/Ni
	
	PRINT,'Time:'+time+'    Test:'+test+'   Field:'+field
RETURN,res
END
