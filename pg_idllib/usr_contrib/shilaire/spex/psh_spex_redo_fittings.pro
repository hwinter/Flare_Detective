PRO psh_spex_redo_fittings,ifirst,ilast, nb=nb
	IF NOT KEYWORD_SET(nb) THEN nb=1
	
	FOR i=0L,ilast-ifirst DO BEGIN
		
		spex_proc,/cmode, input='ifirst,'+strn(i+ifirst)
		spex_proc,/cmode, input='ilast,'+strn(i+ifirst)
	
		apar=spex_current('apar_arr[*,'+strn(i)+']')
		txt='apar'
		FOR j=0,N_ELEMENTS(apar)-1 DO txt=txt+','+strn(apar[j])
		spex_proc,/cmode, input=txt
		spex_proc,/cmode, input='force_apar'		
		FOR j=0,nb-1 DO spex_proc,/cmode, input='fitting'
	ENDFOR	
END
