;computes the photon spectrum observed at Earth [ph/s/cm^2/keV] from a single electron going into a thick target.
;I integrated analytically using the Brown 1971 NR cross-sections.
;
; Eph=1+DINDGEN(100)
; sp= brm_thick_mono(Eph, 50)
; PLOT,Eph,sp,/XLOG,/YLOG
; PLOT,-DERIV(ALOG10(Eph),ALOG10(sp)),/XLOG,xr=[1,10]
; 

FUNCTION brm_thick_mono, Eph, E0
	constant=1.556d-34	; =1/(4!piD^2) * Z^2 * K_BH/K	
	x=Eph/E0
	y=sqrt(1-x)
	tmp=(ALOG((1+y)/(1-y))-y)/x + 0.5*ALOG(x/(-x+2*(1+y)))	
	RETURN, constant*tmp
	;RETURN, tmp
END


