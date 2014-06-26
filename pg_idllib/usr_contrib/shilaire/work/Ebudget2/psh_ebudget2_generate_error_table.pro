; EXAMPLE:
;	bla=psh_ebudget2_generate_error_table(4,10,[10,35],/HAUG,/BETHEBLOCH)
;

FUNCTION psh_ebudget2_generate_error_table, d, Eto, Eobs,ALBEDO=ALBEDO,HIGH_E_CUTOFF=HIGH_E_CUTOFF, HAUG=HAUG, BETHEBLOCH=BETHEBLOCH, Estar=Estar
	Ae=1d
	delta=DOUBLE(d)
	Eph=Eobs[0]+FINDGEN(Eobs[1]-Eobs[0]+1)
	boundaries=[0.1,1,10,1e2,1e3,1e4,1e5,1e6,1e7,1e8]
	IF KEYWORD_SET(HIGH_E_CUTOFF) THEN E0max=DOUBLE(HIGH_E_CUTOFF) ELSE BEGIN
		IF delta LT 3.4 THEN E0max=1e8 ELSE E0max=1e4
	ENDELSE
	sp=forward_spectrum_thick(/EARTH,Eph=Eph,el={delta:delta,A:Ae},	$
		ALBEDO=ALBEDO, E0max=E0max, HAUG=HAUG, BETHEBLOCH=BETHEBLOCH, Estar=Estar)

	res=LINFIT(ALOG10(Eph),ALOG10(sp))	
	dp=-res[1]+1
	Aep=10^res[0] * (dp-1)*(dp-2)/BETA(dp-2,.5)/1.547e-34
F50=50^(-delta+1)*1.5475e-34*BETA(delta-2,0.5)/(delta-1)/(delta-2)
PRINT,'gOBS-gBROWN= '+strn(-res[1]-(delta-1))+'    F50OBS/F50BROWN= '+strn(10^res[0]*50^(res[1])/F50)
	
	factorCO=Aep/Ae * (delta-2)/(dp-2) * Eto^(-dp+delta)
	factorTO=factorCO*(0.5 +1/(dp-2))/(0.5 +1/(delta-2))
	factor=[factorCO,factorTO]
PRINT,'Corrective factor: CO/TO: '
PRINT,factor
	RETURN,factor
END
