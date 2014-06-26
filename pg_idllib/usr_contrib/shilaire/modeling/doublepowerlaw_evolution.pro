; PURPOSE:
;	This routine computes the evolution of an electron power-law undergoing collisional energy losses,
;	and plots the orginal and final power-laws.
;
; HISTORY:
;	PSH 2003/08/26 written.
;
;
; N is column density (cm^-2). Can be an array of such. A fully-ionized plasma is assumed.
; If keyword /ESTAR is used, then it is assumed that N is actually Estar, 
;	the  minimum energy an electron needs to manage going through that column density.
;
; EXAMPLE:
;	doublepowerlaw_evolution,2e19,4,50,5
;	doublepowerlaw_evolution,20,3,20,5,/ESTAR
;

PRO doublepowerlaw_evolution,N,d1,Ebrk,d2, Eco=Eco, ESTAR=ESTAR, modif=modif, yrng=yrng, LABELS=LABELS
	K=2.6e-18	;cm^2 keV^2		
	Ae=1d	
	IF NOT KEYWORD_SET(Eco) THEN Eco=0.1
	IF NOT KEYWORD_SET(modif) THEN modif=0

	E=0.001+DINDGEN(100000)/1000.
	F0=Ae*bpow(E,[d1,Ebrk,d2,0.1,d1])
	
	IF modif GE 1 THEN BEGIN
		;modifying to have an initial turn-over at Eto keV
		Eto=10d
		ssto=(WHERE(E GE Eto))[0]
		F0[WHERE(E LE Eto)]=F0[ssto]
	ENDIF
	IF modif GE 2 THEN BEGIN
		;further modifying to have a `bump-on-tail'
		F0[WHERE(E LE Eto)]=E[WHERE(E LE Eto)]*F0[ssto]/Eto
	ENDIF
	IF modif GE 3 THEN BEGIN
		;further modifying to have a complete cut-off
		F0[WHERE(E LE Eto)]=0d
	ENDIF
		
;	PLOT,E,F0,/XLOG,/YLOG,xr=[0.1,100],xtit='Electron energy [keV]',ytit='Electron distribution [e!U-!N keV!U-1!N]',yr=yrng
PLOT,E,F0,/XLOG,/YLOG,xr=[1,100],xtit='Electron energy [keV]',ytit='[e!U-!N keV!U-1!N]',yr=yrng,thick=2.0,xmar=[8,2],ymar=[3,1]
	FOR i=0,N_ELEMENTS(N)-1 DO BEGIN
		;energy shift due to column density traversed:
		IF KEYWORD_SET(ESTAR) THEN Est=DOUBLE(N[i]) ELSE Est=sqrt(2*K*N[i])		
		Enew=sqrt(E^2. - Est^2)

		ss=WHERE(Enew GT 0.)
		IF ss[0] EQ -1 THEN  BEGIN
			PRINT,'No electrons left !!!'
			RETURN
		ENDIF
		OPLOT,Enew[ss],F0[ss],linestyle=i+1
		IF KEYWORD_SET(LABELS) THEN BEGIN
			IF LABELS EQ 2 THEN plot_label,/DEV,[0.7,-i-1],'E!D*!N='+strn(Est,format='(f10.1)')+' keV',linestyle=i+1,charsize=0.5 ELSE plot_label,/NOLINE,[0.13,1.5*Ae*Est^(-delta)],'E!D*!N='+strn(Est,format='(f10.1)')+' keV'
		ENDIF
	ENDFOR

	IF N_ELEMENTS(N) EQ 1 THEN BEGIN
		;fraction of beam kinetic energy remaining above Eco:
		ss1=WHERE(E GE Eco)
		ss2=WHERE(Enew GE Eco)
		ratio=INT_TABULATED(Enew[ss2],F0[ss2]*Enew[ss2])/INT_TABULATED(E[ss1],F0[ss1]*E[ss1])
		PRINT,'Remaining fraction of beam kinetic power above '+strn(Eco)+' keV: '+strn(ratio)
	ENDIF
END

