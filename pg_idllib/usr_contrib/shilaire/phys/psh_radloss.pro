;INPUT: T, in kev, may be an array
;OUTPUT: dE/dt, in erg.s^-1.cm^3

FUNCTION psh_radloss, T
	Temp=T*11.594*1e6
	
	datafil=GETENV('RAPP_IDL_ROOT')+'/shilaire/data/chianti_radloss__ca_arro.fits'
	bla=mrdfits(datafil,1,/SILENT)
	
	RETURN,INTERPOL(bla.dedt,bla.T,Temp,/SPLINE)
END
