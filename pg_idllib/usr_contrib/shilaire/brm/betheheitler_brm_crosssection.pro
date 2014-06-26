; E, epsilon in keV
; OUTPUT is in [cm^2/keV]
; Bethe-Heitler non-relativistic electron-ion bremsstrahlung cross-section for electron of energy E, differential in photon energy epsilon.
; Koch & Mott, 1959 (formula 3BN(a)); Brown J.C., 1971 (formula (1))
;
; Domain of validity: Non-relativistic,...
;
; MODIFICATIONS:
;	2003/06/11: added experimental /SCREENING keyword...
;	2003/06/15: E and/or epsilon can be arrays now. 
;
; EXAMPLES:
;	* Bremsstrahlung photon spectrum of a single 50 keV electron, for Ntarget=10^10 [cm^-3]. (=instantaneous spectrum=thin target spectrum)
;		Eph=1+DINDGEN(100)
;		phSpectrum=DBLARR(100)
;		Nt=1e10	;cm^-3
;		E=50D	;keV
;		ve=sqrt(2*E/510.98D)*3e10
;		FOR i=0L,N_ELEMENTS(Eph)-1 DO phSpectrum[i]=betheheitler_brm_crosssection(50,Eph[i]) * Nt * ve 
;		;FOR i=0L,N_ELEMENTS(Eph)-1 DO BEGIN brm_bremcross,E,Eph[i],1.44,cross & phSpectrum[i]=cross * Nt * ve & ENDFOR
;		PLOT,Eph,phSpectrum,/xlog,/ylog,xtit='Photon energy [keV]',ytit='Emitted photons [ph s!U-1!N keV!U-1!N]'
;		PLOT,Eph,-DERIV(ALOG10(Eph),ALOG10(phSpectrum)),/XLOG
;
;	* Bremsstrahlung photon spectrum for power-law total electron distribution N50.(E/50)^-delta [e- keV^-1], and for Ntarget=10^10 [cm^-3]
;		Eph=1+DINDGEN(100)
;		flux=DBLARR(100)
;		FOR i=0L,N_ELEMENTS(Eph)-1 DO flux[i]=integrate_1d('bh_flux_function_to_integrate',1,100, Eph=Eph[i], Nel50=2.8, delta=4, Ecutoff=10)
;		PLOT,Eph,flux,/xlog,/ylog,xtit='Photon energy [keV]',ytit='Emitted photons [ph s!U-1!N keV!U-1!N]'
;
;




FUNCTION betheheitler_brm_crosssection,E,epsilon, z=z, mb=mb, SCREENING=SCREENING, QUIET=QUIET
	
	Eel=DOUBLE(E)
	Eph=DOUBLE(epsilon)
	IF NOT KEYWORD_SET(z) THEN z=1.2d

	bad_ss=WHERE((E-Eph) LT 0.)
	IF NOT KEYWORD_SET(QUIET) THEN IF bad_ss[0] NE -1 THEN PRINT,'.... Bethe-Heitler bremmstrahlung cross-section put to 0 for Eph > Eel.'
	
	r0=2.818e-13	; classical electron radius [cm]
	alpha=1/137d	; fine structure constant
	mec2= 510.98d	; electron mass	[keV]
	
	K=Z^2*8d/3*alpha*mec2/Eel/Eph	
	IF KEYWORD_SET(mb) THEN K=K*79.41124d ELSE K=K*r0^2.
	;K is now in [cm^2 keV^-1] or [mb keV^-1]
	cross=K*ALOG((1+sqrt(1-Eph/Eel))/(1-sqrt(1-Eph/Eel)))
	IF bad_ss[0] NE -1 THEN cross[bad_ss]=0d
	IF KEYWORD_SET(SCREENING) THEN BEGIN
		m=9.1e-28
		c=29979245800d
		v=c*gamma2beta(1d + E/511d)
		
		Qmax=2*m*v
		Qmin=2*Eph*1.6e-9/v
		Qs=z^(1./3.) *m*c/192d
	
		ratio=ALOG(Qmax/sqrt(Qmin^2. + Qs^2.) - Qs^2. / (2*(Qmin^2. + Qs^2.)) )/ALOG(Qmax/Qmin)
		cross=cross*ratio
	ENDIF
	RETURN,cross
END


