;RESTRICTIONS: assumes equally spaced points for now.


PRO c_correl_1D, Xaxis1, Yval1, Xaxis2, Yval2, $
	coeff,lag


; take region of overlap between the two:
n1=N_ELEMENTS(Xaxis1)
n2=N_ELEMENTS(Xaxis2)

start1=0
start2=0
end1=n1-1
end2=n2-1


IF Xaxis1(0) LT Xaxis2(0) THEN BEGIN
	ss=WHERE(Xaxis1 GE Xaxis2(0))
	start1=ss(0)
	start2=0
ENDIF
IF Xaxis1(0) GT Xaxis2(0) THEN BEGIN
	ss=WHERE(Xaxis2 GE Xaxis1(0))
	start2=ss(0)
	start1=0
ENDIF
IF Xaxis1(n1-1) LT Xaxis2(n2-1) THEN BEGIN
	ss=WHERE(Xaxis2 GE Xaxis1(n1-1))
	end1=n1-1
	end2=ss(0)
ENDIF
IF Xaxis1(n1-1) GT Xaxis2(n2-1) THEN BEGIN
	ss=WHERE(Xaxis1 GE Xaxis2(n2-1))
	end1=ss(0)
	end2=n2-1
ENDIF

x1=Xaxis1[start1:end1]
x2=Xaxis2[start2:end2]
Yy1=Yval1[start1:end1]
Yy2=Yval2[start2:end2]

;now, xaxes should have same interval. Interpolate so that they have also same number of points
; take as reference , the x-vector with biggest number of points
IF N_ELEMENTS(x1) GE N_ELEMENTS(x2) THEN BEGIN
	x=x1
	y1=Yy1
	y2=INTERPOL(Yy2,x2,x,/SPLINE)
ENDIF ELSE BEGIN
	x=x2
	y2=Yy2
	y1=INTERPOL(Yy1,x1,x,/SPLINE)	
ENDELSE

;now, we have x, y1 and y2 to cross-correlate. (I suppose I have equally spaced points)
n=N_ELEMENTS(x)
lags=INDGEN(2*n-3)-n+2
res=C_CORRELATE(y1,y2,lags,/DOUBLE)
coeff=MAX(abs(res),lag)
lag=(lag(0)-n+2)*(x(1)-x(0))
END


