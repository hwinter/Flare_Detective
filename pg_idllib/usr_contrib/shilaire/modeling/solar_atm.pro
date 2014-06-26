; This routine returns several parameters of a solar atmosphere.
;
; INPUTS:
; 	None
;
; OUTPUTS:
;	atm structure, containing:
;	h: height above photosphere [km]
;	T: temperature
;	nel: electron density [x10^10 cm^-3]
;	np: proton density [x10^10 cm^-3]
;	nh: hydrogen atom density [x10^10 cm^-3]
;
;	il: ionization level
;
;
;	EXAMPLE:
;		solar_atm, '/global/hercules/data1/rapp_idl/shilaire/data/modelP.ascii',atm
;
;-----------------------------------------------------------------------------------------------------------------------
PRO solar_atm, filename,atm

	atm_h={h:-1d,T:-1d,nel:-1d,np:-1d,nh:-1d,n:-1d,il:-1d,cd:0d,M:0d, Emin:0d}

	lambda=0.55d
	K=4.36e-36

;LOAD FILE...
	tmp=rd_ascii(filename)
	data=tmp[3:N_ELEMENTS(tmp)-2]
	atm=REPLICATE(atm_h,N_ELEMENTS(data))
	FOR i=0L,N_ELEMENTS(data)-1 DO BEGIN
		;get primary data
		res=rsi_strsplit(data[i],/EXTRACT)
		atm_h.h=DOUBLE(res[1])
		atm_h.T=DOUBLE(res[2])
		atm_h.nel=DOUBLE(res[3])
		atm_h.np=DOUBLE(res[4])
		atm_h.nh=DOUBLE(res[5])
		
		;determine secondary data
		
		atm_h.n=DOUBLE(atm_h.np+atm_h.nh)	; density of p+H
		atm_h.il=atm_h.np/(atm_h.np+atm_h.nh)	; ionization level
		IF i GT 0 THEN atm_h.cd=atm[i-1].cd + (atm[i-1].h-atm_h.h)*1e5*atm_h.n			; column density since highest altitude, in cm^-2
		IF i GT 0 THEN atm_h.M=atm[i-1].M + (atm_h.il+lambda)*(atm[i-1].h-atm_h.h)*1e5*atm_h.n	; column density weighted for ionization...
		atm_h.Emin=sqrt(2*K*atm_h.M)/1.6e-9					; min electron energy [keV] needed to reach that level...

		atm[i]=atm_h		
	ENDFOR
END
;-----------------------------------------------------------------------------------------------------------------------
	
	
