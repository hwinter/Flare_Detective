FUNCTION rk4function,X,Y

	gamma=DOUBLE(Y)
	t=DOUBLE(X)

	Bfield=10	;Gauss
	phi=!dPI/2	
	Nelectron=10^12	; cm^-3
	
	RETURN,f4_387(Bfield,DOUBLE(gamma),N=Nelectron,phi=phi) 		; gyrosynchroton with corona
	;RETURN,f4_421(Bfield,DOUBLE(gamma))					; synchroton
END
;================================================================================================
FUNCTION myrk4,X0,Y0,H,Niter,taxis=taxis

	; usually, X0=0 (time)	
	X=DOUBLE(X0)
	Y=DOUBLE(Y0)
	H=DOUBLE(H)
	
	FOR i=0L,Niter-1 DO BEGIN
		NEWY=RK4(Y[N_ELEMENTS(Y)-1], rk4function(X+i*H,Y[N_ELEMENTS(Y)-1]), X+i*H, H, 'rk4function',/DOUBLE)
		Y=[Y,NEWY]
	ENDFOR

	taxis=X+DINDGEN(Niter+1)*H
RETURN,Y
END
;================================================================================================



;;;; synchroton: gamma=myrk4(0.,100.,0.1,1000,taxis=taxis)
;;;; gyrosynchroton:	

;;;;plot,taxis,gamma
;;;;oplot,abs(deriv(taxis,gamma)) : radiated power (must be multiplied by rest mass energy)

;;CONCLUSIONS: gyrosynchroton and synchroton behave a lot alike (within factor 2, for 100 and 1000 G fields)
