;PSH, 2001/11/19
;
;seeks the best (anti-) crosscorrelation coefficient for f1 and f2 at different lags,
;and returns the associated coeff and lag
;
;this routine sure as hell better not be used for periodic signals...
;
; RESTRICTIONS:
;	f1 and f2 must have the same number of elements
;
;===============================================================================


PRO crosscorrelate, f1,f2,coeff,lag

n=LONG(N_ELEMENTS(f1))
lags=LINDGEN(2*n-3)-(n-2)
cc=C_CORRELATE(f1,f2,lags,/DOUBLE)

temp=MAX(ABS(cc),ss)

lag=ss-(n-2)
coeff=cc(ss)
END
