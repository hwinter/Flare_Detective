;+
; PSH 2004/09/16
;
;-
PRO psh_read_sc21refw, w,f, lin,k,c
	fil='/ftp/pub/hedc/fs/data3/rapp_idl/shilaire/data/SunSpectrum/sc21refw.dat'
	data=rd_ascii(fil)
	w=DBLARR(N_ELEMENTS(data))	;Wavelength in A
	f=DBLARR(N_ELEMENTS(data))	;in 10^10 photons/s/m^2
	lin=STRARR(N_ELEMENTS(data))	;line name
	k=BYTARR(N_ELEMENTS(data))	;Coefficient: 1 or 2, depending on line type
	c=DBLARR(N_ELEMENTS(data))	;Coefficient
		
	FOR i=0L,N_ELEMENTS(data)-1 DO BEGIN
		w[i]=DOUBLE(STRMID(data[i],1,7))
		f[i]=DOUBLE(STRMID(data[i],8,8))
		lin[i]=STRING(STRMID(data[i],16,10))
		k[i]=FIX(STRMID(data[i],26,1))
		c[i]=DOUBLE(STRMID(data[i],29,8))
	ENDFOR
END
