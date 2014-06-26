;+
;NAME:
; 	brm_deconvolve.pro
;
;PROJECT:
;	HESSI
;
;CATEGORY:
; 
;PURPOSE:
;	To deconvolve a photon spectrum into its source electron spectrum, assuming thin-target emission, 
;	using the Johns & Lin (1992) method (both recursive and matrix versions).
;
;CALLING SEQUENCE:
; 	brm_deconvolve, Eph, ph_flux, ph_eflux=ph_eflux, Eel, el_flux, el_eflux, EXTEND=EXTEND, MATRIX=MATRIX, EDGES_Eel=EDGES_Eel, PTS=PTS, NO_NORMALIZATION=NO_NORMALIZATION
;
;INPUT:
; 	Eph:	a 1-D array of photon energies. If the number of elements of Eph is different (i.e. one more)
;		 than ph_flux, then it is assumed that those are energy EDGES rather than values AT.
;
;	ph_flux:   a 1-D array with photon fluxes [photons s^-1 cm^-2 keV^-1]
;
;OPTIONAL KEYWORD INPUT:	
;
;	ph_eflux: a 1-D array with the errors associated with the photon flux.
;
;	/EDGES_Eel: if set, Eel will be returned as EDGES, not value AT.
;
;	/MATRIX: if set, uses matrix formulation (usually slower), otherwise uses the recursion relation.
;
;	/EXTEND: if set, will extend the photon spectrum by ten bins, assuming a power-law shape.
;
;	/NO_NORMALIZATION: if set, will return the electron fluxes with same (computationnaly advantageous) units
;			as in original fortran code.
;
;	NPTS:   If not set, cross-sections integrations are done using the very accurate, but also very slow QROMO.PRO routine.
;		If set, the integration is done via the INT_TABULATED.PRO routine: much faster, but a bit less accurate, where 
;		NPTS is the number of points used per integration interval.
;		Some comparisons were done on the electron fluxes obtained from a gamma=3 photon power-law between QROMO.pro and INT_TABULATED.pro:
;		IF NPTS=10, the speed is increased by a factor ~20 , but the accuracy is ~1% (as bad as ~2% at low energies, ~5% at high-energies)
;		IF NPTS=100, the speed is increased by a factor ~10 , but the accuracy is ~0.01% (~0.1% at low energies, ~0.4% at high-energies)
;		IF NPTS=1000, the speed is about the same, the accuracy is ~0.001% (~0.01% at low energies, ~0.04% at high-energies)
;
;OUTPUT:
; 	
;	Eel	: electron energy array (bin center, or edges if /EDGES_Eel is set).
;
;	el_flux : electron fluxes, in units of (nV).[electrons s^-1 cm^-2 keV^-1] (unless keyword /NO_NORMALIZATION is set).
;
;	el_eflux: errors on electron fluxes (only if keyword ph_eflux was used), same units as el_flux.
;
;
;EXAMPLE:
;	Eph=DINDGEN(100)+0.5
;	ph_flux=Eph^(-3.)
;	brm_deconvolve, Eph, ph_flux, Eel, el_flux,/EXTEND,NPTS=100
;	PLOT,Eel,el_flux,/XLOG,/YLOG,xtit='Electron energy [keV]',xr=[1,100],ytit='nVF [electrons s!U-1!N cm!U-2!N keV!U-1!N]'
;
;	ph_eflux=ph_flux*Eph/100.	; just a quick example...
;	brm_deconvolve,Eph, ph_flux, ph_eflux=ph_eflux, Eel, el_flux,el_eflux,/EXTEND,/MATRIX,NPTS=100,/NO_NORM
;	ploterr,Eel,el_flux,DBLARR(N_ELEMENTS(Eel)),el_eflux,/XLOG,/YLOG,/NOHAT,xtit='Electron energy [keV]'
;
;HISTORY:
;	Done after original Fortran code from C.M. Johns-Krull,
;		by Pascal Saint-Hilaire (Saint-Hilaire@astro.phys.ethz.ch), June 2003
;
;-
;--------------------------------------------------------------------------------------------------------------------
FUNCTION brm_deconvolve_cross_integrand,E
	COMMON BRM_DECONVOLVE_COMMON,INFO_PARAMS	
	brm_bremcross, E, INFO_PARAMS.curEph, INFO_PARAMS.Z, cross
;	ss=WHERE(FINITE(cross) NE 1) & IF ss[0] NE -1 THEN cross[ss]=0d
	RETURN,cross*1e27/510.98	; give result in mb/keV, not cm^2/(unit photon energy, normalized to electron rest mass)
END
;--------------------------------------------------------------------------------------------------------------------
FUNCTION brm_deconvolve_cross,Eph,E1,E2
	;this part takes energies for the photon being produced by electrons
	;between the second and third energies. All energies should be in keV.
	;The program returns the integrated cross section in mb.	

	COMMON BRM_DECONVOLVE_COMMON,INFO_PARAMS
	IF INFO_PARAMS.NPTS EQ 0 THEN BEGIN
		INFO_PARAMS.curEph=Eph
		RETURN,QROMO('brm_deconvolve_cross_integrand',E1,E2,/DOUBLE)	
	ENDIF ELSE BEGIN
		; the following is faster than QROMO, but less acurate.
		npts=INFO_PARAMS.NPTS
		ebins=(E2-E1)*(DINDGEN(npts)+0.5)/npts + E1
		brm_bremcross,ebins,Eph,INFO_PARAMS.Z,cross
		RETURN,INT_TABULATED(ebins,cross*1e27/510.98,/DOUBLE)*(npts+1.)/npts	
	ENDELSE
END
;--------------------------------------------------------------------------------------------------------------------
PRO brm_deconvolve_extend,e1,e2,e3,f1,f2,en,fl
;       Here we make up some photon values to extend the end of the photon
;       spectra to higher energies to make the electron spectra well behaved
;       in the range we can observe.
	
	mo=(ALOG10(f1)-ALOG10(f2))/(ALOG10(e1)-ALOG10(e2))
	loga=ALOG10(f1)-mo*ALOG10(e1)
	a=10.^(loga)
	dife=5.0*(e1-e2)
	en=e3
	fl=a*(e3^mo)
	FOR i=1,9 DO BEGIN
		en=[en,e3+DOUBLE(i)*dife]
		fl=[fl,a*(en[i]^mo)]
	ENDFOR
END
;--------------------------------------------------------------------------------------------------------------------
PRO brm_deconvolve, Eph_in, ph_flux_in, ph_eflux_in=ph_eflux_in, EDGES_Eel=EDGES_Eel, EXTEND=EXTEND, MATRIX=MATRIX, NO_NORMALIZATION=NO_NORMALIZATION, NPTS=NPTS,  	$	;INPUT
	Eel,el_flux, el_eflux																		;OUTPUT

	COMMON BRM_DECONVOLVE_COMMON,INFO_PARAMS
	INFO_PARAMS={NPTS:0L, curEph:-1d, Z:1.2d}
	
	Eph=Eph_in ; this ensures that the input Eph array is not changed by the routine (as IDL passes variables by reference...)
	ph_flux=ph_flux_in
	IF N_ELEMENTS(Eph) EQ N_ELEMENTS(ph_flux_in) THEN phEDGES=0 ELSE phEDGES=1
	IF KEYWORD_SET(ph_eflux_in) THEN ph_eflux=ph_eflux_in
	IF KEYWORD_SET(NPTS) THEN INFO_PARAMS.NPTS=NPTS
	
	; set the number of data points:
	IF phEDGES EQ 0 THEN ndim=N_ELEMENTS(Eph) $
	ELSE BEGIN
		ndim=N_ELEMENTS(Eph)-1
		tempe=Eph[ndim-1]
		tempe2=Eph[ndim]
		;must create the energy scale that the measurements are AT.
		k=DBLARR(ndim)
		FOR j=0,ndim-1 DO k[j]=10.^((ALOG10(Eph[j])+ALOG10(Eph[j+1]))/2.)
		;now we put these back to the proper name
		Eph=k
	ENDELSE

	;we must create a last data point energy value to be the upper limit of our electron energy values.
	Eph=[Eph,10.^(2.*ALOG10(Eph[ndim-1])-ALOG10(Eph[ndim-2]))]

	ndim2=ndim

	IF KEYWORD_SET(EXTEND) THEN BEGIN
		brm_deconvolve_extend,Eph[ndim-1],Eph[ndim-2],Eph[ndim],ph_flux[ndim-1],ph_flux[ndim-2],newe,newf
		Eph=[Eph[0:N_ELEMENTS(Eph)-2],newe]
		ph_flux=[ph_flux,newf]
		IF KEYWORD_SET(ph_eflux_in) THEN ph_eflux=[ph_eflux,DBLARR(10)]
		ndim=ndim+10

		;we must create a last data point energy value to be the upper limit of our electron energy values.
		Eph=[Eph,10d^(2.0*ALOG10(Eph[ndim-1])-ALOG10(Eph[ndim-2]))]
	ENDIF

	;now we will make the energy scale the electron values are AT.
	k=Eph
        FOR j=0,ndim-1 DO k[j]=10.^((ALOG10(Eph[j])+ALOG10(Eph[j+1]))/2)
		
	el_flux=DBLARR(ndim)
	el_eflux=DBLARR(ndim)

        IF NOT KEYWORD_SET(MATRIX) THEN BEGIN
		;now we begin the actual deconvolution using the recursion relationship derived in the Johns & Lin paper (1992),  eq. (5).
		el_flux[ndim-1]=ph_flux[ndim-1]/brm_deconvolve_cross(Eph[ndim-1],Eph[ndim-1],Eph[ndim])
		FOR i=ndim-2,0,-1 DO BEGIN
			sum=0d
			FOR j=i+1,ndim-1 DO sum=sum+el_flux[j]*brm_deconvolve_cross(Eph[i],Eph[j],Eph[j+1])
			el_flux[i]=(ph_flux[i]-sum)/brm_deconvolve_cross(Eph[i],Eph[i],Eph[i+1])
		ENDFOR

		;now we calculate the errors if they are provided.
		IF KEYWORD_SET(ph_eflux_in) THEN BEGIN
			el_eflux[ndim-1]=ph_eflux[ndim-1]/brm_deconvolve_cross(Eph[ndim-1],Eph[ndim-1],Eph[ndim])
			FOR i=ndim-2,0,-1 DO BEGIN
				sum=0d
				FOR j=i+1,ndim-1 DO sum=sum+(el_eflux[j]*brm_deconvolve_cross(Eph[i],Eph[j],Eph[j+1]))^2.
				sum=sum+(ph_eflux[i])^2.
				el_eflux[i]=sqrt(sum)/brm_deconvolve_cross(Eph[i],Eph[i],Eph[i+1])
			ENDFOR
		ENDIF
	ENDIF ELSE BEGIN
		;now we will build the a matrix from the Johns & Lin 1992 paper and then deconvolve the spectra by the matrix equation.
		a=DBLARR(ndim,ndim)
		FOR j=0, ndim-1 DO a[j,j]=1/brm_deconvolve_cross(Eph[j],Eph[j],Eph[j+1])	
		FOR j=ndim-1,1,-1 DO BEGIN
			FOR i=j-1,0,-1 DO BEGIN
				sum=0d
				FOR l=i+1,j DO sum=sum+brm_deconvolve_cross(Eph[i],Eph[l],Eph[l+1])*a[l,j]/brm_deconvolve_cross(Eph[i],Eph[i],Eph[i+1])
				a[i,j]=-sum
			ENDFOR
		ENDFOR	
		FOR i=0,ndim-1 DO BEGIN
			sum=0d
			sum2=0d
			FOR j=0,ndim-1 DO BEGIN
				sum=sum+a[i,j]*ph_flux[j]
				IF KEYWORD_SET(ph_eflux_in) THEN sum2=sum2 + a[i,j]^2. * ph_eflux[j]^2.
			ENDFOR
			el_flux[i]=sum
			IF KEYWORD_SET(ph_eflux_in) THEN el_eflux[i]=sqrt(sum2)
		ENDFOR
	ENDELSE
	
	;now we just take the resultant electron spectra.
	IF KEYWORD_SET(EDGES_Eel) THEN Eel=Eph[0:ndim2] ELSE Eel=k[0:ndim2-1]
	el_flux=el_flux[0:ndim2-1]
	IF KEYWORD_SET(ph_eflux_in) THEN el_eflux=el_eflux[0:ndim2-1]

	IF NOT KEYWORD_SET(NO_NORMALIZATION) THEN BEGIN
		;some conversion of units... (nV)/(4*dPI*R^2) [electrons s^-1 mb^-1 keV^-1]  to (nV)*[electrons s^-1 cm^-2 keV^-1]
		D=499d*29979245800d
		el_flux=el_flux*1e27*4*!dPI*D^2
		IF KEYWORD_SET(ph_eflux_in) THEN el_eflux=el_eflux*1e27*4*!dPI*D^2
	ENDIF
END
;--------------------------------------------------------------------------------------------------------------------


