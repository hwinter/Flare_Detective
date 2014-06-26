FUNCTION psh_test_qromo, x
	;RETURN,x^(-4d)
	d=4d
	eps=10d
	RETURN,x^(-d-1)*ALOG((1+sqrt(eps/x))/(1-sqrt(eps/x)))
END
