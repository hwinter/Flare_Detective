

Eph=[3.,5.,10.,30.]

brm_screening_correction,epsilon=Eph[0],E,ratio
PLOT,E,ratio,/XLOG,xr=[1,1000],yr=[0.98,1.],xtit='Electron energy [keV]',ytit='Correction at different photon energies',tit='Correction to the bremsstrahlung cross-section due to screening effects'
FOR i=1,N_ELEMENTS(Eph)-1 DO BEGIN
	brm_screening_correction,epsilon=Eph[i],E,ratio
	OPLOT,E,ratio,linestyle=i
ENDFOR

XYOUTS,/NORM,0.83,0.4,'!7e!3 = 3 keV'
XYOUTS,/NORM,0.83,0.63,'!7e!3 = 5 keV'
XYOUTS,/NORM,0.83,0.84,'!7e!3 = 10 keV'
XYOUTS,/NORM,0.83,0.92,'!7e!3 = 30 keV'

END
