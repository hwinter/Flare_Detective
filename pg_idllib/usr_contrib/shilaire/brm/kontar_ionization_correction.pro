; PSH 2003/05/01
;
; See Kontar, Brown, McArthur 2003 and my notes
; This is the correction to be given to a HXR bremsstrahlung spectrum for 
; a unit step ionization at Estar.
;
; INPUT:
; 	epsilon: [keV]
;	delta : injected electron spectral indexd
;	Estar=(2*K'Mstar)^0.5, Mstar is column depth (normalized for ionization) where we go from a fully ionized medium to a partially ionized one.
;	lambda=LAMBDAeH/(LAMBDAee-LAMBDAeH) (default: 0.55)
;
; 
; EXAMPLE:
;	res=kontar_ionization_correction(0.5+DINDGEN(100),4., Estar=40.)
;	plot,0.5+DINDGEN(100),res,/XLOG,/YLOG,xr=[1.,100.],xtit='photon energy [keV]',ytit='correction to the fully-ionized spectrum',tit='Correction to the HXR brems spectra due to step ionization (delta=4, Estar=40 keV)'
;
;------------------------------------------------------------------------------------------------------------------------------------------
FUNCTION kontar_ionization_correction, epsilon, delta, Estar=Estar, lambda=lambda
	IF not keyword_set(Estar) THEN Estar= 40D	;[keV]
	IF not keyword_set(lambda) THEN lambda=0.55D

	j= 1D +  IBETA(/DOUBLE, delta/2.-1, 0.5, 1/(1+(epsilon/Estar)^2))*(delta-2.)/(2*lambda)/(epsilon/Estar)^(2-delta) * BETA(/DOUBLE,delta/2.-1, 0.5)
	RETURN,j
END
;------------------------------------------------------------------------------------------------------------------------------------------



