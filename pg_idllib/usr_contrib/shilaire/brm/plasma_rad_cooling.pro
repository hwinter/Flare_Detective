; Computes and plots the plasma temperature as a function of time, assuming ONLY radiative cooling is taking place.
; The density is by default 10^11 cm^-3
;
; EXAMPLE:
;	plasma_rad_cooling
;


PRO plasma_rad_cooling, density=density
	IF NOT KEYWORD_SET(density) THEN density=1e11	;cm^-3
	Temperatures=REVERSE(1e6*(1.+DINDGEN(100)))	;from 100 to 1 MK (as below 1MK CHIANTI and SPEX start to really disagree...)
	;Temperatures=REVERSE(1e6*(1.+DINDGEN(2000)/100.))	;from 100 to 1 MK (as below 1MK CHIANTI and SPEX start to really disagree...)
	;Temperatures=REVERSE(1e4*(1.+DINDGEN(500)))

	rad_loss,Temp,lr,dens=density	

	nbins=N_ELEMENTS(Temperatures)-1
	Times=DBLARR(nbins)
	Times[0]=plasma_rad_cooling_time(Temperatures[0],Temperatures[1],temp=temp,lr=lr,density=density )
	FOR i=1L,nbins-1 DO Times[i]=Times[i-1]+plasma_rad_cooling_time(Temperatures[i],Temperatures[i+1],temp=temp,lr=lr,density=density)

	PLOT,Times,(Temperatures/1e6)-0.5,tit='Temperature decay of a '+strn(density,format='(e20.1)')+' cm!U-3!N by radiation.',xtit='Elapsed time [s]',ytit='Temperature [MK]'
	;PLOT,Times,(Temperatures/1e6)-0.5,xtit='Elapsed time [s]',ytit='Temperature [MK]'
STOP
END
