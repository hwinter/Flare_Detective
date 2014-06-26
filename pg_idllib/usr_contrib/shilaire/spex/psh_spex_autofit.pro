; This routine must be called once SPEX has been properly setup and exited from.
; It will make automatic fitting, of all time intervals. If some resulting fitting
; parameters are not within acceptable limits, will change them and redo them...
;
; User should have run 'psh_gospex.pro', done proper background subtraction and selection of fitting intervals,
; then exit SPEX, and run psh_spex_autofit.pro.
;

PRO psh_spex_autofit, aparmin, aparmax, apardef, MANUAL=MANUAL, DEFSTART=DEFSTART

	nloops_max=3.
	COMMON SPEX_PROC_COM,  cosine, det_id,  ut, flux, eflux, ltime, rate, area, $
 		 datamode, title, count_2_flux, uflux, erate, handles, last_plot, $
 		 back, eback, wback, tb, def_tb, xselect, iselect, wint, wuse, edges, $
		 delta_light, edg_units, e_in, eff, drm, obsi, convi, eobsi, backi, ebacki, $
		 live, start_time_data, end_time_data, iegroup,  range, apar, apar_arr, $
		 apar_last, apar_sigma, chi,  batse_burst, erange, flare, spex_debug, spex_obj

	nfit=N_ELEMENTS((spex_current('iselect'))[0,*])	
	
	FOR i=0L,nfit-1 DO BEGIN
		spex_proc,/cmode, input='ifirst='+strn(i)
		spex_proc,/cmode, input='ilast='+strn(i)		

		IF KEYWORD_SET(MANUAL) THEN BEGIN
			spex_proc,/cmode, input='fit'
			ans='N'		
			WHILE ans EQ 'N' DO BEGIN
				ask,' Is this OK ?', ans
				IF ans EQ 'N' THEN spex_proc,/cmode, input='phot'
			ENDWHILE
		ENDIF ELSE BEGIN
			IF i GE 1 THEN apar_arr[*,i]=apar_arr[*,i-1] $	;start fit with previous fitting parameters			
			ELSE IF KEYWORD_SET(DEFSDSTART) THEN BEGIN
				apar=apardef
				apar_last[0,i]=apardef
				apar_arr[0,i]=apardef
				spex_proc,/cmode, input='phot,no'
			ENDIF
			ok=0
			nloops=0
			WHILE NOT ok DO BEGIN			
				ok=1
				nloops=nloops+1
				spex_proc,/cmode, input='fit'
				; check problems...				
				FOR j=0,N_ELEMENTS(apar)-1 DO BEGIN
					IF apar[j] LE aparmin[j] THEN BEGIN apar_arr[j,i]=nloops*apardef[j] & ok=0 & ENDIF
					IF apar[j] GE aparmax[j] THEN BEGIN apar_arr[j,i]=nloops*apardef[j] & ok=0 & ENDIF
				ENDFOR
				IF nloops GT nloops_max THEN BEGIN
					ok=1
					PRINT,'Number of loops bigger than nloops_max='+strn(nloops_max)+'... Aborting... and putting the whole thing to 0.'
					apar_arr[*,i]=0
				ENDIF
			ENDWHILE
			
		ENDELSE
	ENDFOR
	;spex_proc
END
