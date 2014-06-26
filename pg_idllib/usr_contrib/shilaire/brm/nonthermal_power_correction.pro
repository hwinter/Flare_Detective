; This routine yields the factor by which one must correct the nonthermal power obtained via the standard BROWN, 1971 
;	or  Tannberg-Hanssen & EMSLIE, 1988 formulae, because of other effects...(first order effects...)
;
; Assumes photon energy turnover is below the other stuff...
; First output is for cutoff, second for turnover
; USAGE:
;	corr=nonthermal_power_correction(delta,EphTO,Eobs,/STD,/TOGETHER)
;	delta and EphTO can be arrays (of the same dimensions!)
;
; EXAMPLE:
;	PRINT, nonthermal_power_correction(4,10,[10,35],/STD,/TOGETHER)
;	PRINT, nonthermal_power_correction(4,10,[10,35],/TOGETHER,NONUNIFORM=25,/LOUD)
;
; It is strongly advised not to use the /FAST keyword for electron spectral indices below ~3.4 (where it is accurate to about ~5% for Eto=10 and Eobs=[10,35])!
;
; IF KEYWORD /TOGETHER is set, then will be a lot ...faster AND accurate (unless /FAST is also set...)
;
;
;-----------------------------------------------------------------------------------------------------
FUNCTION nonthermal_power_correction__photonturnover, delta, Ephto
	; apply this correction if the observed cutoff is the photon turnover energy, which needs to be translated to an electron CUTOFF energy...
	
	;load my small dbase...
	data=mrdfits('~/rapp_idl/shilaire/data/ratio_Eph_Ecto2.fits',1)
	ratioTO=INTERPOL(data.ratioTO,data.delta,delta) 
	ratioCO=INTERPOL(data.ratioCO,data.delta,delta)
	ratio=[ratioCO,ratioTO]
	factor=ratio^(-delta+2.)
PRINT,'Ratio EphTO/Eco,to:'
PRINT,ratio			
PRINT,'Effects of EphTO/Eco,to:'
PRINT,factor			
	RETURN,factor
END
;-----------------------------------------------------------------------------------------------------
FUNCTION nonthermal_power_correction__high_e_cutoff, d, Eto, Eobs, Ehco,FAST=FAST
	Ae=1d
	delta=DOUBLE(d)
	Eph=Eobs	
	IF KEYWORD_SET(FAST) THEN boundaries=[0.1,1000] ELSE boundaries=[0.1,1,10,1e2,1e3,1e4,1e5,1e6,1e7,1e8]
	sp=forward_spectrum_thick(/EARTH,Eph=Eph,el={delta:delta,A:Ae},E0max=DOUBLE(Ehco),boundaries=boundaries)
		
	res=LINFIT(ALOG10(Eph),ALOG10(sp))	
	dp=-res[1]+1
	Aep=10^res[0] * (dp-1)*(dp-2)/BETA(dp-2,.5)/1.547e-34
	
	factorCO=Aep/Ae * (delta-2)/(dp-2) * Eto^(-dp+delta)
	factorTO=factorCO*(0.5 +1/(dp-2))/(0.5 +1/(delta-2))
	factor=[factorCO,factorTO]
PRINT,'High-E cutoff:'
PRINT,factor
	RETURN,factor
END
;-----------------------------------------------------------------------------------------------------
FUNCTION nonthermal_power_correction__haug, d, Eto, Eobs,FAST=FAST
	Ae=1d
	delta=DOUBLE(d)
	Eph=Eobs	
	IF KEYWORD_SET(FAST) THEN boundaries=[0.1,1000] ELSE boundaries=[0.1,1,10,1e2,1e3,1e4,1e5,1e6,1e7,1e8]
	sp=forward_spectrum_thick(/EARTH,Eph=Eph,el={delta:delta,A:Ae},E0max=1e8,boundaries=boundaries,/HAUG)
		
	res=LINFIT(ALOG10(Eph),ALOG10(sp))	
	dp=-res[1]+1
	Aep=10^res[0] * (dp-1)*(dp-2)/BETA(dp-2,.5)/1.547e-34
	
	factorCO=Aep/Ae * (delta-2)/(dp-2) * Eto^(-dp+delta)
	factorTO=factorCO*(0.5 +1/(dp-2))/(0.5 +1/(delta-2))
	factor=[factorCO,factorTO]
PRINT,'Haug:'
PRINT,factor
	RETURN,factor
END
;-----------------------------------------------------------------------------------------------------
FUNCTION nonthermal_power_correction__bethebloch, d, Eto, Eobs,FAST=FAST
	Ae=1d
	delta=DOUBLE(d)
	Eph=Eobs	
	IF KEYWORD_SET(FAST) THEN boundaries=[0.1,1000] ELSE boundaries=[0.1,1,10,1e2,1e3,1e4,1e5,1e6,1e7,1e8]
	sp=forward_spectrum_thick(/EARTH,Eph=Eph,el={delta:delta,A:Ae},E0max=1e8,boundaries=boundaries,/BETHEBLOCH)
		
	res=LINFIT(ALOG10(Eph),ALOG10(sp))	
	dp=-res[1]+1
	Aep=10^res[0] * (dp-1)*(dp-2)/BETA(dp-2,.5)/1.547e-34
	
	factorCO=Aep/Ae * (delta-2)/(dp-2) * Eto^(-dp+delta)
	factorTO=factorCO*(0.5 +1/(dp-2))/(0.5 +1/(delta-2))
	factor=[factorCO,factorTO]
PRINT,'Bethe-Bloch:'
PRINT,factor
	RETURN,factor
END
;-----------------------------------------------------------------------------------------------------
FUNCTION nonthermal_power_correction__albedo, d, Eto, Eobs
	Ae=1d
	delta=DOUBLE(d)
	Eph=Eobs	
	;;sp=forward_spectrum_thick(/EARTH,Eph=Eph,/LOUD,el={delta:delta,A:Ae},E0max=1e8,boundaries=[0.1,1,10,1e2,1e3,1e4,1e5,1e6,1e7,1e8],Estar=Estar)
	;;faster way:
	sp=1.547e-34*BETA(delta-2,.5)/(delta-1)/(delta-2)*Ae*Eph^(-delta+1)*alexander_albedo_correction(Eph, delta-1.)		
		
	res=LINFIT(ALOG10(Eph),ALOG10(sp))	
	dp=-res[1]+1
	Aep=10^res[0] * (dp-1)*(dp-2)/BETA(dp-2,.5)/1.547e-34
	
	factorCO=Aep/Ae * (delta-2)/(dp-2) * Eto^(-dp+delta)
	factorTO=factorCO*(0.5 +1/(dp-2))/(0.5 +1/(delta-2))
	factor=[factorCO,factorTO]
PRINT,'Albedo:'
PRINT,factor
	RETURN,factor
END
;-----------------------------------------------------------------------------------------------------
FUNCTION nonthermal_power_correction__nonuniform, d, Eto, Eobs, Estar
	Ae=1d
	delta=DOUBLE(d)
	Eph=Eobs	
	;;sp=forward_spectrum_thick(/EARTH,Eph=Eph,/LOUD,el={delta:delta,A:Ae},E0max=1e8,boundaries=[0.1,1,10,1e2,1e3,1e4,1e5,1e6,1e7,1e8],Estar=Estar)
	;;faster way:
	sp=1.547e-34*BETA(delta-2,.5)/(delta-1)/(delta-2)*Ae*Eph^(-delta+1)*kontar_ionization_correction(Eph, delta, Estar=DOUBLE(Estar))		
		
	res=LINFIT(ALOG10(Eph),ALOG10(sp))	
	dp=-res[1]+1
	Aep=10^res[0] * (dp-1)*(dp-2)/BETA(dp-2,.5)/1.547e-34
	
	factorCO=Aep/Ae * (delta-2)/(dp-2) * Eto^(-dp+delta)
	factorTO=factorCO*(0.5 +1/(dp-2))/(0.5 +1/(delta-2))
	factor=[factorCO,factorTO]
PRINT,'Nonuniform:'
PRINT,factor
	RETURN,factor
END
;-----------------------------------------------------------------------------------------------------
FUNCTION nonthermal_power_correction__together, d, Eto, Eobs,ALBEDO=ALBEDO,HIGH_E_CUTOFF=HIGH_E_CUTOFF, HAUG=HAUG, BETHEBLOCH=BETHEBLOCH, Estar=Estar, LOUD=LOUD
	Ae=1d
	delta=DOUBLE(d)
	Eph=Eobs	
	IF KEYWORD_SET(FAST) THEN boundaries=[0.1,1000] ELSE boundaries=[0.1,1,10,1e2,1e3,1e4,1e5,1e6,1e7,1e8]
	IF KEYWORD_SET(HIGH_E_CUTOFF) THEN E0max=DOUBLE(HIGH_E_CUTOFF) ELSE BEGIN
		IF delta LT 3.4 THEN E0max=1e8 ELSE E0max=1e4
	ENDELSE
	IF KEYWORD_SET(LOUD) THEN BEGIN
		sp0=forward_spectrum_thick(/EARTH,Eph=Eph,el={delta:delta,A:Ae},boundaries=boundaries)
		!P.MULTI=[0,1,2]
		PLOT,Eph,sp0,/XLOG,/YLOG
	ENDIF
	sp=forward_spectrum_thick(/EARTH,Eph=Eph,el={delta:delta,A:Ae},boundaries=boundaries,	$
		ALBEDO=ALBEDO, E0max=E0max, HAUG=HAUG, BETHEBLOCH=BETHEBLOCH, Estar=Estar)
	IF KEYWORD_SET(LOUD) THEN BEGIN
		OPLOT,Eph,sp,linestyle=2,thick=2
		PLOT,Eph,sp/sp0,/XLOG
	ENDIF
	res=LINFIT(ALOG10(Eph),ALOG10(sp))	
	dp=-res[1]+1
	Aep=10^res[0] * (dp-1)*(dp-2)/BETA(dp-2,.5)/1.547e-34
	
	factorCO=Aep/Ae * (delta-2)/(dp-2) * Eto^(-dp+delta)
	factorTO=factorCO*(0.5 +1/(dp-2))/(0.5 +1/(delta-2))
	factor=[factorCO,factorTO]
PRINT,'Together:'
PRINT,factor
	RETURN,factor
END
;-----------------------------------------------------------------------------------------------------
FUNCTION nonthermal_power_correction, d, Eturnover, E_intv, n_pts=n_pts,	$
		STD=STD,			$
		PHOTONTURNOVER=PHOTONTURNOVER,	$
		HIGH_E_CUTOFF=HIGH_E_CUTOFF,	$
		HAUG=HAUG,			$
		BETHEBLOCH=BETHEBLOCH,		$
		ALBEDO=ALBEDO,			$
		NONUNIFORM=NONUNIFORM,		$
		FAST=FAST,			$
		TOGETHER=TOGETHER,		$
		LOUD=LOUD
		
				
	IF NOT KEYWORD_SET(n_pts) THEN n_pts=30
	IF KEYWORD_SET(STD) THEN BEGIN
		PHOTONTURNOVER=1
		HIGH_E_CUTOFF=0
		HAUG=1
		BETHEBLOCH=1
		ALBEDO=1
		NONUNIFORM=0
	ENDIF
	
	nbr=N_ELEMENTS(d)
	delta=DOUBLE(d)
	nbr=N_ELEMENTS(delta)
	Eto=DOUBLE(Eturnover)
	Eobs=E_intv[0]+ (E_intv[1]-E_intv[0])*DINDGEN(n_pts)/(n_pts-1)

	;first, compute all the corrections on the nonthermal energy due to the various effects
	;those are first-order corrections...
	
	factor=DBLARR(2,nbr)
	
FOR i=0L,nbr-1 DO BEGIN	
	factor[*,i]=[1d,1d]
	IF KEYWORD_SET(PHOTONTURNOVER) THEN factor[*,i]=factor[*,i]*nonthermal_power_correction__photonturnover(delta[i],Eto[i])
	
	IF KEYWORD_SET(TOGETHER) THEN BEGIN
		IF KEYWORD_SET(NONUNIFORM) THEN Estar=DOUBLE(NONUNIFORM)
		factor[*,i]=factor[*,i]*nonthermal_power_correction__together(delta[i], Eto[i], Eobs,ALBEDO=ALBEDO,HIGH_E_CUTOFF=HIGH_E_CUTOFF, HAUG=HAUG, BETHEBLOCH=BETHEBLOCH, Estar=Estar,LOUD=LOUD)
	ENDIF ELSE BEGIN	
		IF KEYWORD_SET(HIGH_E_CUTOFF) THEN factor[*,i]=factor[*,i]*nonthermal_power_correction__high_e_cutoff(delta[i],Eto[i],Eobs,HIGH_E_CUTOFF,FAST=FAST)
		IF KEYWORD_SET(HAUG) THEN factor[*,i]=factor[*,i]*nonthermal_power_correction__haug(delta[i],Eto[i],Eobs,FAST=FAST)
		IF KEYWORD_SET(BETHEBLOCH) THEN factor[*,i]=factor[*,i]*nonthermal_power_correction__bethebloch(delta[i],Eto[i],Eobs,FAST=FAST)
		IF KEYWORD_SET(ALBEDO) THEN factor[*,i]=factor[*,i]*nonthermal_power_correction__albedo(delta[i],Eto[i],Eobs)
		IF KEYWORD_SET(NONUNIFORM) THEN factor[*,i]=factor[*,i]*nonthermal_power_correction__nonuniform(delta[i],Eto[i],Eobs,DOUBLE(NONUNIFORM))	
	ENDELSE
	PRINT,'......... % complete: '+strn(100.*(i+1)/nbr,format='(f10.1)')
ENDFOR

RETURN,1/factor
END
;-----------------------------------------------------------------------------------------------------
