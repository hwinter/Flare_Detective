; this routine shows how at which altitude the energy a single electron of initial energy E0 is deposited.
;
;
; targetT: target temperature, in keV
;
;
; EXAMPLE:
;	E0=100
;	edep=energy_deposition(E0,atm)
;	PLOT,atm.h/1000.,edep,xtit='Altitude [Mm]',ytit='Energy deposited [keV]',psym=10,tit='Initial electron energy: '+strn(E0)+' keV.'
;
;--------------------------------------------------------------------------------------------------------------------
FUNCTION energy_deposition, E0, atm, targetT=targetT, QUIET=QUIET, BB=BB

	nb=N_ELEMENTS(atm)
	eloss=DBLARR(nb)
	i=0
	E=DOUBLE(E0)
	t=0d
	WHILE E GT 0 DO BEGIN			
		; energy loss per unit column density..
		Gc=E*collisional_energy_loss_crosssection(E, atm[i].il, T=targetT, BETHE=BB)
		Eloss[i]=Gc*atm[i].M
		IF Eloss[i] GT E THEN BEGIN 
			Eloss[i]=E
			E=0
		ENDIF ELSE E=E-Eloss[i]
		IF KEYWORD_SET(targetT) THEN IF E LT targetT THEN BEGIN
			Eloss[i]=Eloss[i]+E
			E=0
		ENDIF
		
		IF E GT 1 THEN t=t + (atm[i].h-atm[i+1].h)/18752d/sqrt(sqrt(E*(E+Eloss[i])))

		i=i+1
		IF i GE nb-1 THEN BEGIN
			PRINT,".............WARNING: electron still has "+strn(E)+" keV of energy!!"
			BREAK
		ENDIF
	ENDWHILE
	IF NOT KEYWORD_SET(QUIET) THEN PRINT,'Approx. time taken: '+strn(t)+' [s].'		
	RETURN,eloss	
END
;--------------------------------------------------------------------------------------------------------------------


