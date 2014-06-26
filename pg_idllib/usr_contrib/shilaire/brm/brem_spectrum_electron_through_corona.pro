; Computes the total radiated photon spectrum of an electron (initial energy E0, in keV) going through a column density N (cm^-2)(loosing energy in it...)
; Output is ph keV^-1, or ph cm^-2 keV^-1 if /EARTH is set.
; /EARTH: as seen on Earth.
;
; EXAMPLE:
;	sp=brem_spectrum_electron_through_corona(50, 2d19, Eph=Eph, /EARTH, /LOUD)
;	PLOT,Eph,sp,/XLOG,/YLOG,ytit='photons cm!U-2!N keV!U-1!N'
;
; Rechecked on 2004/10/06: good! (Except for fact than I'm using NRBH....)
;
;-
FUNCTION  brem_spectrum_electron_through_corona, E0, Nmax, Eph=Eph, EARTH=EARTH, niter=niter, LOUD=LOUD
	IF NOT KEYWORD_SET(niter) THEN niter=1000
	IF NOT KEYWORD_SET(Eph) THEN Eph=0.5+DINDGEN(100)	
	sp=DBLARR(N_ELEMENTS(Eph))
	D=1.497d13 ;cm
	K=2.6d-18	;cm^2 keV^2
	
	n=0d
	dn=DOUBLE(Nmax)/niter
	E=DOUBLE(E0)	
	goon=1
	WHILE goon DO BEGIN
		FOR i=0L,N_ELEMENTS(Eph)-1 DO sp[i]=sp[i]+dn*betheheitler_brm_crosssection(E,Eph[i],/QUIET)		
		dn=(E^2)/(2*K)/niter > 0.5d17 ;Estar=0.5 keV
		E=E-K*dn/E
		IF KEYWORD_SET(LOUD) THEN PRINT,'After dN='+strn(dn,format='(e10.1)')+' cm^-2, electron energy left: '+strn(E)
		IF E LE 0 THEN BEGIN
			goon=0
			IF KEYWORD_SET(LOUD) THEN PRINT,'Electron lost all its energy in this last dN !!!!'
		ENDIF
		n=n+dn
		IF n GT Nmax THEN goon=0
	ENDWHILE
	IF KEYWORD_SET(EARTH) THEN sp=sp/(4*!dPI*D^2)
	RETURN,sp
END
