; will do spex fittings from ifirst to ilast, with apar as start parameters...
; to be called from IDL!
;
;
;

PRO spex_do_fittings, ifirst, ilast, apar
	;spex_proc,/cmode, input='select_interval'	
	;iselect=spex_current('iselect')
	
	FOR i=0L,ilast-ifirst DO BEGIN
		
		spex_proc,/cmode, input='ifirst,'+strn(i+ifirst)
		spex_proc,/cmode, input='ilast,'+strn(i+ifirst)
	
		IF exist(apar) THEN BEGIN
			PRINT,'Not implemented yet!'	
		ENDIF ELSE BEGIN
			spex_proc,/cmode, input='force_apar'	;use previous fit as start parameters...
		ENDELSE
		spex_proc,/cmode, input='fitting'
		spex_proc,/cmode, input='fitting'
	ENDFOR	
END
