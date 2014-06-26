

;+
; NAME:
;       F_POW
;
; PURPOSE: power-law function
;
; CALLING SEQUENCE: result = f_pow(x, a)
;
; CATEGORY: SPEX, spectral fitting
;
; INPUTS:
;       x - independent variable, nominally energy in keV under SPEX
;           if a 2xN array is passed, these are interpreted as edges
;           and the value is calculated at the arithmetic mean
;       a - parameters describing the broken power-law
;       a[0] - normalization at epivot, photon flux of first power-law
;              at epivot
;       a[1] - negative photon power law index
;	a[2] - low-energy turnover
;
; OPTIONAL INPUTS:

; OUTPUTS:
;       result of function, a power law
; OPTIONAL OUTPUTS:
;
; PROCEDURE:

; CALLS:   F_DIV, EDGE_PRODUCTS
;
; COMMON BLOCKS:
;       none
;
; RESTRICTIONS: power-law cannot be flatter then x^(-.01)
;
; MODIFICATION HISTORY:
;       PSH, 2003/10/21
;-
;
;----------------------------------------------------------------------------------------------------------
FUNCTION f_pow_cutoff_below_turnover, Eph, a, epivot
	;assume/use the following:
	delta=a[1]+1
	n_pts=300L > LONG(2e5 * 10d^(-a[1]/3.)) < 300000L
	E0max=n_pts
	
	FOR i=0,N_ELEMENTS(Eph)-1 DO BEGIN
		E0=Eph[i]*(a[2]/Eph[i])^(DINDGEN(n_pts+1)/n_pts)	;log-spaced...
		;E0=Eph[i]+(a[2]-Eph[i])*(DINDGEN(n_pts+1)/n_pts)	;lin-spaced
			
		tmp=sqrt(1-Eph[i]/E0)
		y=E0*(-tmp + ALOG((1+tmp)/(1-tmp))) + Eph[i]/2*ALOG(Eph[i]/(-Eph[i]+2*E0*(1+tmp)))
		y=y/Eph[i]*a[2]^(-delta)
		IF i EQ 0 THEN res=INT_TABULATED(E0,y,/DOUBLE) ELSE res=[res,INT_TABULATED(E0,y,/DOUBLE)]
	ENDFOR

	RETURN,a[0]*epivot^a[1] * a[1]*(a[1]-1)/BETA(a[1]-1,0.5)*res
END
;----------------------------------------------------------------------------------------------------------
FUNCTION f_pow_turnover,x,a

	if (size(x))[0] eq 2 then edge_products, x, mean=xm else xm = x
	@function_com

	res=f_pow_cutoff(xm,a)

	;adding the low-E effects of constant electron distribution below a[2] (NR BH bremcross, NR coll. losses):
	ss=WHERE(xm LT a[2])
	IF ss[0] NE -1 THEN res[ss]=res[ss]+f_pow_cutoff_below_turnover(xm[ss],a, epivot[0])

return, res
END
;----------------------------------------------------------------------------------------------------------
