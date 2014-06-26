; REF: Brown J.C.:1973, Solar Physics 28, 151
;	Formula (5)
;
;EXAMPLE:
;
;	non_uniform_ionization_fractional_flux
;	(varies weakly with electron spectral index...)
;	(this is the ratio between actual flux and flux for completely ionized target (io=1)))

;------------------------------------------------------------------------------------------------------
FUNCTION non_uniform_ionization_fractional_flux_PQlimits,x
	RETURN,[x,1D]
END
;------------------------------------------------------------------------------------------------------
FUNCTION non_uniform_ionization_fractional_flux_function,x,y
	d=4D	; delta: power-law index of electron distribution
	io=1D	; ionization level, from 0 to 1
	l=.55D	; lambda
	RETURN,x^(d-2)*alog((1+sqrt(1-y))/(1-sqrt(1-y)))/(y^2)/(io+l)
END
;------------------------------------------------------------------------------------------------------
PRO non_uniform_ionization_fractional_flux
	
	d=4D
	l=.55D
	
	dzeta=(d-1)*(d-2)/BETA(d-2,0.5,/DOUBLE)*(1+l)*INT_2D('non_uniform_ionization_fractional_flux_function', [0D,1], 'non_uniform_ionization_fractional_flux_PQLimits', 48, /DOUBLE)

	PRINT,dzeta
END
;------------------------------------------------------------------------------------------------------
