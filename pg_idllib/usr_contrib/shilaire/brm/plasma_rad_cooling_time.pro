;
; This function takes as input the initial and final temperatures of a plasma of CONSTANT density n (default: 10^10 cm^-3), and returns the time taken by (optically thin) radiative cooling.
; The radiative loss rate is computed from CHIANTI (agreeing within factor 2 with SPEX above 2MK, and only within factor 3 below 1 MK (CHIANTI has lower loss rate than SPEX))
; The density is the TRUE density of the emitting regions (not the average over an observed region).
;
;	EXAMPLE:
;		density=1.e11	; in cm^-3
;		rad_loss,Temp,lr,dens=density	
;		print, plasma_rad_cooling_time(1e7,2e6,temp_arr=temp_arr,lr_arr=lr_arr,density=density)
;	OR:
;		plasma_rad_cooling
;		with Tstart, Tend in [K]
;
;-----------------------------------------------------------------------
FUNCTION plasma_rad_cooling_time__integrand, T
	COMMON RAD_LOSS, Temp,lr
	RETURN,INTERPOL(1/lr,temp,T,/SPLINE)
END
;-----------------------------------------------------------------------
FUNCTION plasma_rad_cooling_time,Tstart,Tend, temp_arr=temp_arr, lr_arr=lr_arr,density=density

	COMMON RAD_LOSS,Temp,lr	
	IF NOT KEYWORD_SET(density) THEN density=1.e10	;cm^-3
	IF NOT KEYWORD_SET(temp_arr) THEN rad_loss,temp_arr,lr_arr,dens=density
	Temp=temp_arr
	lr=lr_arr
	kB=1.38065e-16	; Boltzmann's constant, in [erg/K].
	
	RETURN, -2*kB/density*QROMB( 'plasma_rad_cooling_time__integrand', Tstart, Tend, /DOUBLE)
END	
;-----------------------------------------------------------------------
	
	
	
	
	
	
