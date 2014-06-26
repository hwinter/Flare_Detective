; EXAMPLE:
;	sp=brem_spectrum_electron_powerlaw_through_corona( 1, 4, 2d19)
;	sp=8.1d9*sp*1d30
;	PLOT,0.5+DINDGEN(100),sp,/XLOG,/YLOG,ytit='ph cm!U-2!N keV!U-1!N',xtit='Photon energy [keV]'
;						
; Checked again on 2004/10/06: good! (Except for fact than I'm using NRBH....)
;-
FUNCTION brem_spectrum_electron_powerlaw_through_corona, Ae, delta, N

	Eph=0.5+DINDGEN(100)
	E=0.5+DINDGEN(300) & dE=1d
	F0=DOUBLE(Ae)*E^(-DOUBLE(delta))	; electrons keV-1
	sp=DBLARR(N_ELEMENTS(Eph))	
		
	FOR i=0L,N_ELEMENTS(E)-1 DO BEGIN
		PRINT,E[i]
		sp=sp+F0[i]*dE*brem_spectrum_electron_through_corona(E[i], N, Eph=Eph, /EARTH, niter=1000)
	ENDFOR

	RETURN,sp
END

