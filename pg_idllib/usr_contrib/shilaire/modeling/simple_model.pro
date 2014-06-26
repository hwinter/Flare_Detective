; --> To test the usage of mpfitfun.pro...
; x=DINDGEN(10)
; ydata=exp(-0.5*(x/3)^2)
; yerr=3+DBLARR(10)
; params=mpfitfun('simple_model',x,ydata, yerr, [1d,1d])
;
; PLOT,x,ydata,psym=7
; OPLOT,x,params[0]*exp(-0.5*(x/params[1])^2)/(2*sqrt(!dPI))
;
;----------------------------------------------------------------------
FUNCTION simple_model, x, params
	; a 1-D gaussian...
	ymodel=params[0]*exp(-0.5*(x/params[1])^2)/(2*sqrt(!dPI))
	RETURN,ymodel
END
;----------------------------------------------------------------------


