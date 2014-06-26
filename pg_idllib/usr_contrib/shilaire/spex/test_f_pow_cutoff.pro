

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
;	a[2] - low-energy cutoff
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
; RESTRICTIONS: Power-law cannot be flatter then x^(-.01)
;		Gamma should not be smaller than 2.0 (slight discrepance at cutoff energy.)
;
; MODIFICATION HISTORY:
;       PSH, 2003/10/20
;-
;
;----------------------------------------------------------------------------------------------------------
FUNCTION f_pow_cutoff_below_cutoff, Eph, a, epivot
	;assume/use the following:
	delta=a[1]+1
	n_pts=300L > LONG(2e5 * 10d^(-a[1]/3.)) < 300000L			; this insures accuracy within 1 per mil, for delta>=3.0
;	n_pts=1000000
	E0max=n_pts					; this insures accuracy within 1 per mil, for delta>=3.0
PRINT,n_pts,E0max
	E0=a[2]*(E0max/a[2])^(DINDGEN(n_pts+1)/n_pts)	;log-spaced...
	;E0=a[2]+(E0max-a[2])*(DINDGEN(n_pts+1)/n_pts)	;lin-spaced

	FOR i=0,N_ELEMENTS(Eph)-1 DO BEGIN
		tmp=Eph[i]/E0
		y=-sqrt(1-tmp)/tmp + ALOG(Eph[i])/2 + ALOG((1+sqrt(1-tmp))/(1-sqrt(1-tmp)))/tmp - ALOG(-Eph[i]+2*E0*(1+sqrt(1-tmp)))/2
		y=y*E0^(-delta)
		IF i EQ 0 THEN res=INT_TABULATED(E0,y,/DOUBLE) ELSE res=[res,INT_TABULATED(E0,y,/DOUBLE)]
	ENDFOR

	RETURN, a[0]*epivot^a[1] * a[1]*(a[1]-1)/BETA(a[1]-1,0.5)*res
END
;----------------------------------------------------------------------------------------------------------
FUNCTION f_pow_cutoff,x,a

	if (size(x))[0] eq 2 then edge_products, x, mean=xm else xm = x
	@function_com

	res=a[0]* f_div(epivot, xm)^a[1]

	;adding the low-E effects of cutoff (NR BH bremcross):
	ss=WHERE(xm LT a[2])
	IF ss[0] NE -1 THEN res[ss]=f_pow_cutoff_below_cutoff(xm[ss],a, epivot[0])

return, res
END
;----------------------------------------------------------------------------------------------------------
