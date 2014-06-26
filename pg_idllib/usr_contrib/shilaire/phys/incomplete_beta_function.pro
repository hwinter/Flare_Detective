;PSH 2003/05/02
;
;EXAMPLE:
;	print,incomplete_beta_function(1.5,1.5,0.5)
;	print,incomplete_beta_function(1.5,1.5,1.)
;	the last should be the same as print,beta(1.5,1.5)
;-------------------------------------------------------------------------
FUNCTION incomplete_beta_function__integrand, x, a=a, b=b
	IF NOT keyword_set(a) THEN MESSAGE,'Specify a !'
	IF NOT keyword_set(b) THEN MESSAGE,'Specify b !'
	RETURN, x^(a-1.) * (1-x)^(b-1.)
END
;-------------------------------------------------------------------------
FUNCTION incomplete_beta_function, a,b,x
	res=integrate_1d('incomplete_beta_function__integrand',0,x,n=10000,a=a,b=b)
	RETURN,res
END
;-------------------------------------------------------------------------

