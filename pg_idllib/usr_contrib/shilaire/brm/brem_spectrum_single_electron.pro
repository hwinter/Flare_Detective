; Computes the bremsstrahlung spectrum of a single electron of energy E0 [keV], going through a density n(p+H) [cm^-3], observed at Earth
; If /EARTH, output is in ph/s/cm^2/keV, otherwise in ph/s/keV.
;
; EXAMPLE:
;	sp=brem_spectrum_single_electron(50, 1e10, Eph=Eph, /EARTH,/LOUD)
;

FUNCTION brem_spectrum_single_electron, E0, n, z=z, Eph=Eph, LOUD=LOUD, EARTH=EARTH	;, HAUG=HAUG

	D=1.497e13	; 1 A.U.
	
	IF NOT exist(Eph) THEN Eph=0.005+DINDGEN(10000)/100.
	phSpectrum=DBLARR(N_ELEMENTS(Eph))
	
	FOR i=0L,N_ELEMENTS(Eph)-1 DO phSpectrum[i]=betheheitler_brm_crosssection(E0,Eph[i],z=z,/QUIET) * n * sqrt(2*E0/510.98D)*3e10 
	
	IF KEYWORD_SET(EARTH) THEN BEGIN 
		phSpectrum=phSpectrum/(4*!dPI*D^2)
		ytit='Emitted photons observed at Earth [ph s!U-1!N cm!U-2!N keV!U-1!N]'
	ENDIF ELSE ytit='Emitted photons [ph s!U-1!N keV!U-1!N]'
	IF KEYWORD_SET(LOUD) THEN PLOT,Eph,phSpectrum,/xlog,/ylog,xtit='Photon energy [keV]',ytit=ytit
	
	RETURN,phSpectrum
END

