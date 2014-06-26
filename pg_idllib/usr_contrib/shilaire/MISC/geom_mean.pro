;
; PSH 2003/05/28 - created, after not being able to find it in IDL or the SSW!
;

FUNCTION geom_mean, inarr
	n=N_ELEMENTS(inarr)
	tmp=1d
	FOR i=0,n-1 DO tmp=tmp*inarr[i]^(1d/n)
	RETURN,tmp
END


