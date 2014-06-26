

PRO powerlaw_e2v

	mc2=510.98d	; electron rest mass [keV]
	E=0.5+DINDGEN(100000)
	delta=4d
	Ae=1d
	
	!P.MULTI=[0,1,2]

	FE=Ae*E^(-delta)	;electrons keV^-1
	PLOT,E,FE,/XLOG,/YLOG,xtit='Electron kinetic energy [keV]',ytit='F(E)   [e!U-!N keV!U-1!N]'

	v=gamma2beta(E/mc2 +1)	;in units of c (i.e. = beta)
	Fv=FE*mc2*v/(1-v^2)^1.5		;electrons (beta)^-1
	PLOT,v,Fv,/YLOG,xtit='Electron velocity [c]',ytit='F(!7b!3)   [e!U-!N !7b!3!U-1!N]'
END
