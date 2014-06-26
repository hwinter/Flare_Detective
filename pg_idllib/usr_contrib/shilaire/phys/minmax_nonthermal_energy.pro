;Calculates the nonthermal energy of a power-law spectrum, observed/fitted between [Estart,Eend].
;I assume I use unaided line fitting. If a human is there to see that we REALLY have a straight line all the way,
;than my errors are overestimated!... I have to review this, and try to use that info somewhere...
; Results are returned in 10^28 ergs (ev. erg/s).
;
; If /CUTOFF keyword is set, this mean that the energy is supposed coming from a cutoff, not a flat distribution before Ek.
;
; EXAMPLE: 
;	minmax_nonthermal_energy, 3d,187500d, [20,50], 10d
;
;	


PRO minmax_nonthermal_energy, g_obs, Aph_obs, Eintv, Ek, QUIET=QUIET, Estar_arr=Estar_arr, CUTOFF=CUTOFF,	$
	min_power=min_power, max_power=max_power, gmean_power=gmean_power, hudson_power=hudson_power,mean_power=mean_power
	

IF KEYWORD_SET(CUTOFF) THEN ADDFRAC=0. ELSE ADDFRAC=0.5

;E^-(g+1) photon power law, seen corrected for ionization @ Estar and for albedo.
Eph=0.5+DINDGEN(100)
Aph=1d
IF NOT KEYWORD_SET(Estar_arr) THEN Estar_arr=[5.,10.,15.,20.,25.,30.,35.,40.,45.,50.,60.,75.,100.,125.,150.]
;Estar_arr=[25.]
nEstar=N_ELEMENTS(Estar_arr)
g_arr=FINDGEN(13)/2.+2.
ng=N_ELEMENTS(g_arr)

;1) for every possible values of Estar, and gamma, calculate gfit-g, after ionization and albedo corrections: this will get us a better MEAN(gfit-g) and STDDEV(gfit-g) then if also looking at all possible intervals [Estart, Eend]...
dg=DBLARR(nEstar,ng)
FOR i=0,nEstar-1 DO BEGIN
	FOR j=0,ng-1 DO BEGIN
		sp0=Aph*Eph^(-g_arr[j])	; basic ideal synthetic spectrum above kink/cutoff
		sp=sp0*kontar_ionization_correction(Eph, g_arr[j]+1., Estar=Estar_arr[i])	; ideal synthetic spectrum corrected for ionization
		res=LINFIT(alog10(Eph),alog10(sp))
		sp=sp*alexander_albedo_correction(Eph,-res[1])	;now, corrected for albedo
		res=LINFIT(alog10(Eph[Eintv[0]:Eintv[1]]),alog10(sp[Eintv[0]:Eintv[1]]))
		gfit=-res[1]
		;Aph_fit=10.^res[0]
	
		dg[i,j]=gfit-g_arr[j]
	ENDFOR
ENDFOR

;2) now, find MIN/MAX/MEAN/STDDEV of dg for this energy interval:
min_dg=MIN(dg)
max_dg=MAX(dg)
IF NOT KEYWORD_SET(QUIET) THEN PRINT,'...gfit-g:'
IF NOT KEYWORD_SET(QUIET) THEN PRINT,'......MIN:'+strn(min_dg)+'  MAX:'+strn(max_dg)+'  MEAN:'+strn(MEAN(dg))+'  STDDEV:'+strn(STDDEV(dg))

;3) this leads to the following values for g=g_obs-dg:
g_min=g_obs-max_dg
g_max=g_obs-min_dg

;4) Now, calculate the correction factor alpha, searching parameter space limited from g_min to g_max
; new g_arr:
ng=10
g_arr=g_min+FINDGEN(10)*(g_max-g_min)/(ng-1d)
alpha=DBLARR(NEstar,ng)
FOR i=0,nEstar-1 DO BEGIN
	FOR j=0,ng-1 DO BEGIN
		sp0=Aph*Eph^(-g_arr[j])	; basic ideal synthetic spectrum above kink/cutoff
		sp=sp0*kontar_ionization_correction(Eph, g_arr[j]+1., Estar=Estar_arr[i])	; ideal synthetic spectrum corrected for ionization
		res=LINFIT(alog10(Eph),alog10(sp))
		sp=sp*alexander_albedo_correction(Eph,-res[1])	;now, corrected for albedo
		res=LINFIT(alog10(Eph[Eintv[0]:Eintv[1]]),alog10(sp[Eintv[0]:Eintv[1]]))
		gfit=-res[1]
		Aph_fit=10.^res[0]
	
		alpha[i,j]=g_obs^2. *(g_obs-1)^2 * BETA(g_obs-0.5,1.5)/ g_arr[j]^2. / (g_arr[j]-1.)^2. /BETA(g_arr[j]-0.5,1.5) * Aph_fit/Aph *(ADDFRAC + 1./(g_obs-1.))/(ADDFRAC + 1./(g_arr[j]-1.))
	ENDFOR
ENDFOR
;IF NOT KEYWORD_SET(QUIET) THEN BEGIN
;	PRINT,'......alpha min:'+strn(MIN(alpha))
;	PRINT,'......alpha max:'+strn(MAX(alpha))
;	PRINT,'......alpha mean:'+strn(MEAN(alpha))
;	PRINT,'......alpha stddev/mean:'+strn(STDDEV(alpha)/MEAN(alpha))
;ENDIF

;5) Now, compute the true power (in ergs/s)... for every possible Estar and g...
P_arr=DBLARR(nEstar,ng)
FOR i=0,nEstar-1 DO BEGIN
	FOR j=0,ng-1 DO BEGIN
		P_arr[i,j]=g_arr[j]^2. * (g_arr[j]-1.)^2. * BETA(g_arr[j]-0.5,1.5) * (ADDFRAC + 1./(g_obs-1.))/alpha[i,j]*Ek^(-g_arr[j]+1.)
	ENDFOR		
ENDFOR
P_arr=1.6e-9*3.28e5*Aph_obs*P_arr	; in erg/s
min_power=MIN(P_arr)
max_power=MAX(P_arr)
mean_power=MEAN(P_arr)
gmean_power=geom_mean(P_arr)
hudson_power=1.6e-9*3.28e5 * g_obs^2. * (g_obs-1.)^2. * BETA(g_obs-0.5,1.5) * Aph_obs * Ek^(-g_obs+1.) * (ADDFRAC + 1./(g_obs-1.))
IF NOT KEYWORD_SET(QUIET) THEN BEGIN
	PRINT,'...Nonthermal kinetic power in erg/s:'
	PRINT,'......Power min:'+strn(min_power)
	PRINT,'......Power max:'+strn(max_power)
	PRINT,'......Power mean:'+strn(MEAN(P_arr))
	PRINT,'......Power stddev/mean:'+strn(STDDEV(P_arr)/MEAN(P_arr))
	PRINT,'......Power geometric mean:'+strn(gmean_power)
	PRINT,'......Power from Hudson (1978) formula:'+strn(hudson_power)
ENDIF
END
