; Will compute the photon spectrum of an electron of initial energy E0
; going through N=2e19 cm^-2 of fully-ionized plasma, before emitting thick-target emission,
; every ms step of the way.
;
; EXAMPLE:
;	voyage_of_an_electron, 50, movie
;

PRO voyage_of_an_electron, E0, movie
	Nstar=2e19	;E*=10 keV
	n=1e10	;cm^-3
	lmax=Nstar/n
	Eend=1d
	dt=0.01d		
	Eph=0.05+DINDGEN(1000)/10.
	
		
	K=2.6e-18 ;cm^2 keV^2 for fully-ionized
	Kprime=K/20.*12.9 ;cm^2 keV^2 
	D=1.497e13 ; cm
	sp=DBLARR(N_ELEMENTS(Eph))
	E=DOUBLE(E0)
	l=0d	;Mm
	t=0d
	goon=1
	movie=-1
	ytit='Emitted photons observed at Earth [ph s!U-1!N cm!U-2!N keV!U-1!N]'
;coronal part:
	WHILE goon DO BEGIN
		FOR i=0L,N_ELEMENTS(Eph)-1 DO sp[i]=betheheitler_brm_crosssection(E0,Eph[i],z=z,/QUIET) * N
		sp=sp/(4*!dPI*D^2)
		PLOT,Eph,sp,/xlog,/ylog,xtit='Photon energy [keV]',ytit=ytit,tit='Corona...  t= '+strn(t,format='(f10.3)')+' s     E='+strn(E,format='(f10.3)')+' keV   l='+strn(l)
		img=TVRD()
		IF N_ELEMENTS(movie) LT 2 THEN movie=img ELSE movie=[[[movie]],[[img]]]
					
		dl=sqrt(2*E/510.98D)*3e10*dt
		l=l+dl
		t=t+dt
		Estar2=2*K*n*dl
		IF Estar2 LT E^2 THEN E=sqrt(E^2-Estar2) ELSE BEGIN
			E=0d
			goon=0
		ENDELSE		
		IF l GT lmax THEN goon=0
	ENDWHILE

IF E LE 0 THEN BEGIN 
	PRINT,'Electron has not reached denser layers!!'
	RETURN
ENDIF
;transitional/chromospheric part
solar_atm, '/global/hercules/data1/rapp_idl/shilaire/data/modelP.ascii',atm
atm_h=REVERSE(atm[N_ELEMENTS(atm)-1].h+DINDGEN(1000)/1000*(atm[0].h-atm[N_ELEMENTS(atm)-1].h))	;in km
dh=abs(atm_h[0]-atm_h[1])*1e5	;in cm
atm_n=INTERPOL(atm.n,atm.h,atm_h)
atm_m=INTERPOL(atm[1:N_ELEMENTS(atm)-1].m,atm[1:N_ELEMENTS(atm)-1].h,atm_h)

i=0L
WHILE E GT 0 DO BEGIN
	IF i GE N_ELEMENTS(atm_h) THEN BEGIN
		PRINT,'Electron still has energy !!'
		RETURN
	ENDIF

	t=t+dh/(sqrt(2*E/510.98D)*3e10)
	Estar2=2*Kprime*atm_m[i]
	IF Estar2 LT E^2 THEN E=sqrt(E^2-Estar2) ELSE RETURN
	
	FOR j=0L,N_ELEMENTS(Eph)-1 DO sp[j]=betheheitler_brm_crosssection(E0,Eph[j],z=z,/QUIET) * atm_n[i]
	sp=sp/(4*!dPI*D^2)
	PLOT,Eph,sp,/xlog,/ylog,xtit='Photon energy [keV]',ytit=ytit,tit='TR/Chrom...  t= '+strn(t)+' s    E='+strn(E,format='(f10.3)')+' keV  h='+strn(atm_h[i])+'  n!Dp+H!N='+strn(atm_n[i])
	img=TVRD()
	IF N_ELEMENTS(movie) LT 2 THEN movie=img ELSE movie=[[[movie]],[[img]]]

	i=i+1
ENDWHILE
END
	
