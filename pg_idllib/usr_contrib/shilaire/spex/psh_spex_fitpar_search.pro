;+
; This routine will plot a chi2 vs. fitpar plot. Of course, the fitpar must be FREE!
;
; EXAMPLE:
;	SPEX> free,1,1,1,1,0	
;	SPEX> EXIT
;	IDL> x=10+FINDGEN(30)/2
;	IDL> chi2=psh_spex_fitpar_search(4, x, nfit=1)
;	IDL> WDEF,0 & PLOT,x,chi2,xtit='Eco',ytit='!7v!3!U2!N',tit=anytim(spex_current('ut[0,iselect[0]]'),/time,/ECS)+'-'+anytim(spex_current('ut[1,iselect[0]]'),/time,/ECS)
;-

FUNCTION psh_spex_fitpar_search, p, pval, nfit=nfit
	apar=spex_current('apar')
	IF NOT KEYWORD_SET(nfit) THEN nfit=3
	FOR i=0L,N_ELEMENTS(pval)-1 DO BEGIN
		FOR j=0,N_ELEMENTS(apar)-1 DO spex_proc,/cmode,input='apar['+strn(j)+']='+strn(apar[j])		
		spex_proc,/cmode,input='apar['+strn(p)+']='+strn(pval[i])
		spex_proc,/cmode,input='force_apar'
		FOR j=0,nfit-1 DO spex_proc,/cmode,input='fitting'
		IF i EQ 0 THEN chi2=spex_current('chi')	ELSE chi2=[chi2,spex_current('chi')]
	ENDFOR
	
	PRINT,'Finished... Reinitializing to original parameters...'
	FOR j=0,N_ELEMENTS(apar)-1 DO spex_proc,/cmode,input='apar['+strn(j)+']='+strn(apar[j])	
	spex_proc,/cmode,input='force_apar'
	spex_proc,/cmode,input='fitting'
	RETURN,chi2
END
