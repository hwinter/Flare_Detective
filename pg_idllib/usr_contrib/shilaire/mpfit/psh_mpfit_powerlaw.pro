; EXAMPLE:
;	Eph=FINDGEN(100)+1
;	sp=Eph^(-3)
;	PRINT, psh_mpfit_powerlaw(Eph,sp,/LOUD)
;
;-------------------------------------------------------------------------------
;FUNCTION psh_mpfit_powerlaw_model1, ALOG10_Eph, params
;	
;	Eph=10^ALOG10_Eph
;	;params	=[EphTO, gamma, F50]
;	F=params[2]*(Eph/50d)^(-params[1])
;	ss=WHERE(Eph LE params[0])
;	IF ss[0] NE -1 THEN F[ss]=params[2]*(params[0]/50d)^(-params[1]) * (Eph[ss]/params[0])^(-1.5)
;	RETURN,ALOG10(F)
;END
;-------------------------------------------------------------------------------
FUNCTION psh_mpfit_powerlaw, X, Y, LOUD=LOUD, start_params=start_params

	IF KEYWORD_SET(LOUD) THEN PLOT,X,Y,/XLOG,/YLOG,xtit='photon energy [keV]',ytit='[photons s!U-1!N cm!U-2!N keV!U-1!N]',xr=[1,100],yr=[.1,1e4]
	IF NOT KEYWORD_SET(start_params) THEN start_params=[12,3,2.12]
	params = MPFITFUN('psh_mpfit_powerlaw_model1', ALOG10(X), ALOG10(Y), ERR,/WEIGHT, start_params, YFIT=YFIT)
	IF KEYWORD_SET(LOUD) THEN OPLOT,X,10^YFIT,linestyle=2,thick=3
	RETURN,	params
END
;-------------------------------------------------------------------------------
FUNCTION psh_mpfit_powerlaw_make_database
	d=2.5+0.5*DINDGEN(12)
	ratioCO=DBLARR(N_ELEMENTS(d))
	ratioTO=ratioCO
	FOR i=0L,N_ELEMENTS(d)-1 DO BEGIN
		IF d[i] LT 3.4 THEN E0max=1e8 ELSE E0max=1e4
		sp=forward_spectrum_thick(/EARTH,Eph=Eph,/LOUD,el={Eto:20,delta:d[i]},E0max=E0max)
		params = MPFITFUN('psh_mpfit_powerlaw_model1', ALOG10(Eph), ALOG10(sp), ERR,/WEIGHT, [12,d[i]-1,3], YFIT=YFIT)
		ratioTO[i]=params[0]/20.
		sp=forward_spectrum_thick(/EARTH,Eph=Eph,/LOUD,el={Eco:20,delta:d[i]},E0max=E0max)
		params = MPFITFUN('psh_mpfit_powerlaw_model1', ALOG10(Eph), ALOG10(sp), ERR,/WEIGHT, [12,d[i]-1,3], YFIT=YFIT)
		ratioCO[i]=params[0]/20.		
	ENDFOR	
	RETURN,{delta:d,ratioCO:ratioCO,ratioTO:ratioTO}
END
;-------------------------------------------------------------------------------

