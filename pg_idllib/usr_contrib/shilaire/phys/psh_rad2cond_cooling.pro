; returns the ratio of heat conductivity to radiative cooling in a loop of length L ("), temperature T (electrons!, in keV), average density n [cm^-3], filling factor q.

FUNCTION psh_rad2cond_cooling, T, n, L, q=q, CL=CL
	;filling factor:
	IF NOT KEYWORD_SET(q) THEN q=1d
	;Coulomb log:
	IF NOT KEYWORD_SET(CL) THEN CL=20d
	;Spitzer heat conductivity (along B field)
	Kq=1.72e-5 * (T*11.594*1e6)^2.5 / ALOG(CL)

	res=q*Kq*(T*11.594e6)/n^2/(L*725e5)^2/psh_radloss(T)
	IF N_ELEMENTS(T) EQ 1 THEN BEGIN
		PRINT,'Radiative lifetime Eth/(dE/dt)  [s]: '+strn(sqrt(q)*3*T/n/psh_radloss(T)*1.6e-9)		
		Ti=T[0]*11.594*1e6
		Tf=2e6
		T_arr=Tf*(Ti/Tf)^(FINDGEN(101)/100.)
		lr_arr=psh_radloss(T_arr/11.594e6)
		PRINT,'Time to reach 2MK by radiative cooling only: '+strn(plasma_rad_cooling_time(Ti, Tf, temp_arr=T_arr, lr_arr=lr_arr, density=n))
	ENDIF

	RETURN,res
END
