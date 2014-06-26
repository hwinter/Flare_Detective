;
;	power_law_energy_deposition,[Ae,delta],atm	
;
;EXAMPLE:
;	solar_atm, '/global/hercules/data1/rapp_idl/shilaire/data/modelP.ascii',atm
;	power_law_energy_deposition,[1.,4],atm
;

PRO power_law_energy_deposition,params,atm, KINK=KINK, lowE=lowE, highE=highE, BB=BB, OVER=OVER, ERG=ERG, psym=psym
	IF NOT KEYWORD_SET(psym) THEN psym=10

	Eel=DINDGEN(1000)+1
	nbins=N_ELEMENTS(Eel)		

	Ae=DOUBLE(params[0])
	delta=DOUBLE(params[1])
	
	edep=0d
	FOR i=0L,nbins-1 DO BEGIN
		E=Eel[i]
		elf=Ae*E^(-delta)	;assumes ebibns are 1-keV thick.
		IF KEYWORD_SET(lowE) THEN BEGIN
			IF E LT lowE THEN BEGIN
				IF KEYWORD_SET(KINK) THEN elf=Ae*DOUBLE(lowE)^(-delta) ELSE elf=0d
			ENDIF
			
		ENDIF
		IF KEYWORD_SET(highE) THEN BEGIN
			IF E GT highE THEN elf=0d
		ENDIF
		
		edep_inc=energy_deposition(E,atm,/QUIET,BB=BB)*elf
		edep=edep+edep_inc
	ENDFOR
	IF KEYWORD_SET(ERG) THEN BEGIN
		edep=edep*1.6d-9
		titunits='[ergs]'
	ENDIF ELSE titunits='[keV]'
	IF KEYWORD_SET(OVER) THEN OPLOT,atm.h/1000.,edep,psym=psym,linestyle=OVER $
	ELSE PLOT,atm.h/1000.,edep,xtit='Altitude [Mm]',ytit='Energy deposited '+titunits,psym=psym,/ylog,yr=[1d16,1d32],ystyle=1	;,tit='Collisional energy deposition by an electron power-law with !7d!3='+strn(delta,format='(f10.1)')


	;calculate the column density [cm^-2] and EM [cm^-5] where 99% of energy is lost...
		edep_tot=TOTAL(edep)
		edep_tmp=0
		i=1
		EM=0d
		N=0d
		WHILE edep_tmp LE 0.99*edep_tot DO BEGIN
			edep_tmp=edep_tmp+edep[i]
			N=N+(atm[i-1].h-atm[i].h)*1e5*atm[i].n
			EM=EM+(atm[i-1].h-atm[i].h)*1e5*atm[i].n^2
			i=i+1
		ENDWHILE
		PRINT,'Distance over which 99% of energy was deposited: '+strn((atm[0].h-atm[i].h)/1000.)+' Mm.'
		PRINT,'Column density of region where 99% of energy was deposited: '+strn(N)+' cm^-2.'
		PRINT,'EM of region where 99% of energy was deposited: '+strn(EM)+' cm^-5.'
		PRINT,'...in a flare area 1.2e17 cm^2 (2.7" radius), this corresponds to EM: '+strn(EM*1.2e17)+' cm^-3.'
		
		
END

