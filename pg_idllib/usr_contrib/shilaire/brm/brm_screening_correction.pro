;This plots the ratio of screened/unscreened bremsstrahlung crosssection,
;using Jackson sect. 15.3 -- formula (15.43)
;
; EXAMPLE:
;	brm_screening_correction,/LOUD
;

PRO brm_screening_correction, epsilon=epsilon, z=z, LOUD=LOUD, $
		E,ratio

	IF NOT KEYWORD_SET(epsilon) THEN epsilon=3.	;keV. Lower RHESSI range, where effects are the worst!	
	IF NOT KEYWORD_SET(z) THEN z=1.2d
	E=DINDGEN(501.-epsilon)+epsilon
	
	
	m=9.1e-28
	c=29979245800d
	v=c*gamma2beta(1d + E/511d)
	
	Qmax=2*m*v
	Qmin=2*epsilon*1.6e-9/v
	Qs=z^(1./3.) *m*c/192d

	nom=ALOG(Qmax/sqrt(Qmin^2. + Qs^2.) - Qs^2. / (2*(Qmin^2. + Qs^2.)) )
	denom=ALOG(Qmax/Qmin)
	ratio=nom/denom

	IF KEYWORD_SET(LOUD) THEN PLOT, E, ratio,/XLOG,yr=[0.98,1.],xr=[1.,1000.],xtit='Electron energy [keV]',ytit='Correction to the bremsstrahlung cross-section at !7e!3 ='+strn(epsilon,format='(f10.1)')+' keV',tit='Correction due to screening effects'
END
