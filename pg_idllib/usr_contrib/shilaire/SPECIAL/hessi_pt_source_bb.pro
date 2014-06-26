
;Number of photons incident upon 1 HESSI detector, given the source 's size on \
; the Sun, it's BB temperature, and an energy range of interest  



FUNCTION spectralphotonflux,nu,T,c,h,k
	res= 2 * nu^2 /c^2 /(exp(h*nu/(k*T))-1)
	RETURN,res
END




;PRO hessi_pt_source_bb

	T= 10.^7	; in K
	alpha = 1/3600. * !dPI/180.	;1 arcsec in radians
	
	Aeff = 10./10000.	;m^2
	
	h=6.626e-34
	c=299972458D
	k=1.38e-23
	
	e1=25.
	e2=50.
	
	nu1=e1 * 1000d *1.6e-19 /h
	nu2=e2 * 1000d *1.6e-19 /h
	
	nbiter=10000d
	nu=DINDGEN(nbiter)*(nu2-nu1)/nbiter + nu1
	
	deltanu=nu(1)-nu(0)
	
	photonrate= alpha^2 * Aeff * TOTAL(spectralphotonflux(nu,T,c,h,k))*deltanu
	
	PRINT,photonrate
END

