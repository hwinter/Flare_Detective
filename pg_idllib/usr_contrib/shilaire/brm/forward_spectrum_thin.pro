; PSH 2003/06/15 -- v1
;
;EXAMPLE:
;	
;	d=4d & NA=1d & eps=10d
;	sp=forward_spectrum_thin(/EARTH,Eph=Eph,/LOUD,powerlawbeam=[NA,d])
;	PLOT,Eph,sp,/XLOG,/YLOG,xtit='photon energy [keV]',ytit='F(!7e!3)  [photons s!U-1!N cm!U-2!N keV!U-1!N]',xr=[1,100]
;	;compare with NR theory and G. Holman's, at 10 keV:
;	PRINT,4.0452d-52 * BETA(d,0.5)/d*eps^(-d-1)	;--> looks pretty good!
;	Eco=5d & PRINT,f_vth_thin(eps,[0,0.1,Eco^(-d+1)/(d-1)*1d-55,d,10000,d,Eco,10000]) ;--> also pretty good!
;
;	sp=forward_spectrum_thin(/EARTH,Eph=Eph,/LOUD,powerlawbeam=[1,4],Eco=20)
;	PLOT,Eph,-DERIV(ALOG10(Eph),ALOG10(sp))
;
;COMMENTS:
;	The binning thingy needs to be further improved...!!!
;
;--------------------------------------------------------------------------------------------
;---------------------------------------------------------------------------------------------------
FUNCTION forward_spectrum_thin__electron_injection, E0		; F(E0) in [electrons.s^-1.cm^-2.keV^-1]
	COMMON FSTHIN_COMMON, FSTHIN_PARAMS
	res=0	
	IF FSTHIN_PARAMS.powerlawbeam[0] GT 0 THEN BEGIN
		res=res+FSTHIN_PARAMS.powerlawbeam[0]*E0^(-FSTHIN_PARAMS.powerlawbeam[1])	;power-law
		IF FSTHIN_PARAMS.Eto GT -1 THEN BEGIN
			ss=WHERE(E0 LT FSTHIN_PARAMS.Eto)
			IF ss[0] NE -1 THEN res[ss]=FSTHIN_PARAMS.powerlawbeam[0]*FSTHIN_PARAMS.Eto^(-FSTHIN_PARAMS.powerlawbeam[1])
		ENDIF
		IF FSTHIN_PARAMS.Eco GT -1 THEN BEGIN
			ss=WHERE(E0 LT FSTHIN_PARAMS.Eco)
			IF ss[0] NE -1 THEN res[ss]=0
		ENDIF
	ENDIF
		; For a Feb 26,2002 beam going through n=10^10 cm^-3 over 20000 km (-> N=2e19 cm^-2), one should take FSTHIN_PARAMS.powerlawbeam[0]=Ae*N*S=Ae*n*V=2e19*8.1e39=1.62d59 [e s^-1 cm^-2 keV-1]
	;IF FSTHIN_PARAMS.thermalbeam[0] GT 0 THEN res=res+FSTHIN_PARAMS.thermalbeam[0]*exp(-E0/FSTHIN_PARAMS.thermalbeam[1]); Emslie 1988 thermal distrib.
	IF FSTHIN_PARAMS.thermalbeam[0] GT 0 THEN res=res+FSTHIN_PARAMS.thermalbeam[0]*E0*exp(-E0/FSTHIN_PARAMS.thermalbeam[1]); PSH's more proper thermal distrib. for a flux...
	RETURN,res
END
;----------------------------------------------------------------------------------------------------
FUNCTION forward_spectrum_thin__integrand, E
	COMMON FSTHIN_COMMON, FSTHIN_PARAMS
	RETURN, forward_spectrum_thin__electron_injection(E)*betheheitler_brm_crosssection(E,FSTHIN_PARAMS.curEph)
END
;---------------------------------------------------------------------------------------------------
;---------------------------------------------------------------------------------------------------
FUNCTION forward_spectrum_thin,EARTH=EARTH,LOUD=LOUD, powerlawbeam=powerlawbeam, Eph=Eph, E0max=E0max, thermalbeam=thermalbeam, Eco=Eco, Eto=Eto

	COMMON FSTHIN_COMMON, FSTHIN_PARAMS
	FSTHIN_PARAMS={FSTHIN_PARAMS, LOUD:0, il:-1d, targetT:-1d, E0max:-1d, curEph:-1d, SCREENING:0, thermalbeam:[-1d,-1d], powerlawbeam:[-1d,-1d], Eco:-1d, Eto:-1d}

	IF KEYWORD_SET(LOUD) THEN FSTHIN_PARAMS.LOUD=LOUD ELSE FSTHIN_PARAMS.LOUD=0
	IF KEYWORD_SET(powerlawbeam) THEN FSTHIN_PARAMS.powerlawbeam=DOUBLE(powerlawbeam)
	IF KEYWORD_SET(thermalbeam) THEN FSTHIN_PARAMS.thermalbeam=DOUBLE(thermalbeam)
	IF KEYWORD_SET(Eco) THEN FSTHIN_PARAMS.Eco=DOUBLE(Eco)
	IF KEYWORD_SET(Eto) THEN FSTHIN_PARAMS.Eto=DOUBLE(Eto)
	IF KEYWORD_SET(E0max) THEN FSTHIN_PARAMS.E0max=DOUBLE(E0max) ELSE FSTHIN_PARAMS.E0max=3000d
	IF NOT EXIST(Eph) THEN Eph=DINDGEN(100)+0.5

	nbins=N_ELEMENTS(Eph)
	sp=DBLARR(nbins)
	FOR i=0L,nbins-2 DO BEGIN
		IF KEYWORD_SET(LOUD) THEN PRINT,'Doing Eph= '+strn(Eph[i])+' keV'
		FSTHIN_PARAMS.curEph=Eph[i]
		;sp[i]=QROMB('forward_spectrum_thin__integrand',Eph[i],FSTHIN_PARAMS.E0max,/DOUBLE)
			ebins=DINDGEN(FIX(FSTHIN_PARAMS.E0max-Eph[i]))+Eph[i]
			sp[i]=INT_TABULATED(ebins, forward_spectrum_thin__electron_injection(ebins)*betheheitler_brm_crosssection(ebins,Eph[i]) ,/DOUBLE)
	ENDFOR	
	
	; sp currently in [photons s^-1 kev^-1] times 1/(nV)
	D=499D * 29979245800D	;[cm] Sun-Earth distance
	IF KEYWORD_SET(EARTH) THEN sp=sp/(4*!dPI*D^2)	; sp now in [photons s^-1 cm^-2 kev^-1] times 1/(nV)
	RETURN,sp
END
;--------------------------------------------------------------------------------------------


