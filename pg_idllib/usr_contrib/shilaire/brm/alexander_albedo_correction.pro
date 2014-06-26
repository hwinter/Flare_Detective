; PSH 2003/05/01
;
; See Alexander and Brown 2002, and my notes (the correction needs a better determinatioon of gamma...)
; Should be valid between 0 to 300 keV.
;
; INPUT:
; 	epsilon: [keV], can be an array
;	gamma : real photon spectrum (usually delta-1, as an approximation...)
; 
; EXAMPLE:
;	PRINT,alexander_albedo_correction(10,3)
;
;	corr=alexander_albedo_correction(0.5+DINDGEN(100),3)
;	PLOT,0.5+DINDGEN(100),corr,xtit='photon energy [keV]',ytit='albedo correction',tit='Albedo correction to photon spectrum with gamma=3'
;	PLOT,0.5+DINDGEN(100),corr,/XLOG,xr=[1.,100.],xtit='photon energy [keV]',ytit='albedo correction',tit='Albedo correction to photon spectrum with gamma=3'
;
;------------------------------------------------------------------------------
FUNCTION alexander_albedo_correction, epsilon, gamma
	g=DOUBLE(gamma)
	eph=DOUBLE(epsilon)

	A0=0.00105*g+0.00545
	a=-0.061*g+1.648
	b=0.00253*g+0.02615

	res=1D + A0 * eph^a * exp(-b*eph)
	RETURN,res
END
;------------------------------------------------------------------------------
