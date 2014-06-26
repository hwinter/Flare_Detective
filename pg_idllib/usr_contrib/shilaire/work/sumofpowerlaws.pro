
;EXAMPLE:
;	g=[5.,4.,3.,2.,3.,4.,5.]
;	F50=[1.,1,1,1,1,1,1]
;	sumofpowerlaws,g,F50
;

PRO sumofpowerlaws,g,F50
	npl=N_ELEMENTS(g)
	E=0.5+DINDGEN(100)
	powerlaw=DBLARR(100)	
	FOR j=0,npl-1 DO powerlaw=powerlaw+F50[j]*(E/50.)^(-g[j])
	PLOT,E,powerlaw,/XLOG,/YLOG,xr=[1,100]
	gamma=-(LINFIT(ALOG10(E[10:35]),ALOG10(powerlaw[10:35])))[1] & PRINT,gamma
	F50f=50^(-gamma)*10^((LINFIT(ALOG10(E[10:35]),ALOG10(powerlaw[10:35])))[0])/npl & PRINT,F50f
END
