; PSH 2003/02/25
; Computes the energy loss cross section due to collisional effects.
;
; Range of validity: NR electrons.
;
; INPUT: 
;	E : electron energy [keV]	; can be 1-D array
;	il: ionization level (default is 1., fully ionized)
;	T: target temperature, in keV. Default is not used. (Emslie, 2003, "Death to low-E cut-off")
;
; KEYWORD INPUT:
;	/mb: if set, returned result will be in mb instead of cm^2
;	/RELATIVISTIC: if set, will use relativistic formulation (BenzBook). 
;	/BETHEBLOCH: if set, will use the Bethe-Bloch formula (quantum relativistic treatment), valid for all energy ranges.
;	/HOLMAN: if set, will use the G. Holman's eloss used in his thick-target model in the SSW.
;	B2_n: (B.sin(psi))^2/n , in {Gauss^2.cm^3]: adds magnetobremsstrahlung losses (cyclotron to synchroton losses).
;
; OUTPUT
;	Qc: energy loss cross-section in [cm^2]
;		(Gc=E*Qc is the energy loss per unit column density, in [kev.(cm^-2)^-1])
;
;
; EXAMPLE:
;	PRINT,collisional_energy_loss_crosssection(100)
;	E=0.5+DINDGEN(100000) & PLOT,E,collisional_energy_loss_crosssection(E,/BETHE),/XLOG,/YLOG,xr=[1,100000]
;
; HISTORY:
;	2003/03/17: added keyword T
;	2003/06/26: added keyword /mb
;	2003/09/09: added keyword /RELATIVISTIC
;	2003/09/14: added keyword /BETHEBLOCH  ;!!! I assume ionization level effects act the same on the coulomb log in this case! (In any case, the il=1 case is OK.)
;	2003/10/17: added keyword /HOLMAN
;	2004/04/05: added keyword B2_n
;
;------------------------------------------------------------------------------------------------------------------------------------------------------------
FUNCTION collisional_energy_loss_crosssection__gth, E, T
	;this is the ratio between collisional energy loss in a hot target to that in a cold target.
	
	gth=ERRORF(sqrt(E/T)) - 2*sqrt(E/T)*exp(-E/T)*2/sqrt(!dPI)
	;ss=WHERE(E LE 0.98*T)
	;IF ss[0] NE -1 THEN gth[ss]=0D
	RETURN,gth
END
;------------------------------------------------------------------------------------------------------------------------------------------------------------
FUNCTION collisional_energy_loss_crosssection, Ee, il, T=T, mb=mb, RELATIVISTIC=RELATIVISTIC, BETHEBLOCH=BETHEBLOCH, HOLMAN=HOLMAN, B2_n=B2_n

	IF N_PARAMS() LT 2 THEN il=1.
	formula=1
	IF KEYWORD_SET(RELATIVISTIC) THEN formula=2
	IF KEYWORD_SET(BETHEBLOCH) THEN formula=3
	IF KEYWORD_SET(HOLMAN) THEN formula=4

	Qe=4.803206e-10	; esu	
	CoulombLog_ee=20D
	CoulombLog_eH=7.1D
	CoulombLog=CoulombLog_ee-CoulombLog_eH
	lambda=CoulombLog_eH/CoulombLog

	E=DOUBLE(Ee)
	x=DOUBLE(il) 
		
	;Energy_loss_cross_section for electrons incident on free an hydrogen-bound electrons.
	CASE formula OF
		2: Energy_loss_cross_section=2.0964e-20/E/gamma2beta(1+E/510.98)
		3: BEGIN
			gamma=1d + E/510.98
			beta=gamma2beta(gamma)
			Energy_loss_cross_section=4*!dPI*Qe^4*((x+lambda)*CoulombLog+ALOG(gamma^2)-beta^2)/(E*1.6e-9)/(510.98*1.6e-9)/beta^2
		END
		4: BEGIN
			gamma=1d + E/510.98
			beta=gamma2beta(gamma)			
			Energy_loss_cross_section=4*!dPI*Qe^4*(x+lambda)/(1+lambda)*ALOG(6.9447d+09*E)/(E*1.6e-9)/(510.98*1.6e-9)/beta^2
		END
		ELSE: Energy_loss_cross_section=2*!dPI*Qe^4*(x+lambda)*CoulombLog/(E*1.6e-9)^2	;this is in [cm^2] ;NR formula
	ENDCASE
	
	IF KEYWORD_SET(B2_n) THEN BEGIN
		;from formula 1.155 of Astrophysical Formulae (should be valid from NR to UR regimes...)
		g=1d + E/510.98
		Qm=3.3d-17 * B2_n * g^2 * gamma2beta(g) /E
		Energy_loss_cross_section=Energy_loss_cross_section + Qm
	ENDIF
	IF KEYWORD_SET(mb) THEN Energy_loss_cross_section=Energy_loss_cross_section*1e27
	IF KEYWORD_SET(T) THEN IF T GT 0. THEN Energy_loss_cross_section=Energy_loss_cross_section*collisional_energy_loss_crosssection__gth(E,T)
	RETURN,Energy_loss_cross_section	;[cm^2]
END
;------------------------------------------------------------------------------------------------------------------------------------------------------------
