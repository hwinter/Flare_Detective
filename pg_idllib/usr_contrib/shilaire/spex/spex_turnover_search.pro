; If activated from the IDL command-line, after exiting a SPEX session,
; will try to find the low-energy turnover by trying different energies, 
; and comparing with the chi^2 fitting component...
;
; EXAMPLE:
;	spex_turnover_search,/LOUD,/PS
;

PRO spex_turnover_search, Estart=Estart,Eend=Eend, Estep=Estep, g_bco=g_bco, outfil=outfil, fitErng=fitErng, LOUD=LOUD,PS=PS
	IF NOT KEYWORD_SET(Estart) THEN Estart=6
	IF NOT KEYWORD_SET(Eend) THEN Eend=21	
	IF NOT KEYWORD_SET(Estep) THEN Estep=1	;keV
	IF NOT KEYWORD_SET(g_bco) THEN g_bco=1.5;gamma below cutoff	
	spex_proc,/cmode,input='a_cutoff[1]='+strn(g_bco)
	IF KEYWORD_SET(fitErng) THEN spex_proc,/cmode,input='erange,'+strn(fitErng[0])+','+strn(fitErng[1])

	tmp=spex_current('erange')
	Estart= Estart > tmp[0]
	
	Ecur=DOUBLE(Estart)
	e_arr=Ecur
	chi2='bla'
	WHILE Ecur LE Eend DO BEGIN
		spex_proc,/cmode,input='a_cutoff[0]='+strn(Ecur)
		spex_proc,/cmode,input='fitting'
		spex_proc,/cmode,input='fitting'
		spex_proc,/cmode,input='fitting'
		tmp=spex_current('ifirst')
		IF datatype(chi2) EQ 'STR' THEN chi2=spex_current('chi['+strn(tmp)+']') ELSE chi2=[chi2,spex_current('chi['+strn(tmp)+']')]
						
		Ecur=Ecur+Estep
		e_arr=[e_arr,Ecur]
	ENDWHILE

	IF KEYWORD_SET(outfil) THEN mwrfits,{e_arr:e_arr,chi2:chi2},outfil,/CREATE				

	thebest=MIN(chi2,ss)
	spex_proc,/cmode,input='a_cutoff[0]='+strn(e_arr[ss])
	spex_proc,/cmode,input='fitting'
	IF KEYWORD_SET(LOUD) THEN BEGIN
		PRINT,'Best chi^2 of '+strn(thebest)+' at Eph,to='+strn(e_arr[ss])
		PLOT,e_arr,chi2,/XLOG,xr=[1,100],xtit='!7e!3 [keV]',ytit='!7v!3!U2!N'
		IF KEYWORD_SET(PS) THEN BEGIN
			SET_PLOT,'PS'
			PLOT,e_arr,chi2,/XLOG,xr=[1,100],xtit='!7e!3 [keV]',ytit='!7v!3!U2!N'			
			DEVICE,/CLOSE
			X
		ENDIF
	ENDIF
END
