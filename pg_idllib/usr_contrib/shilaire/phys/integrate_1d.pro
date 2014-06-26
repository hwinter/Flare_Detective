; PSH 2003/02/25
;	Integrate_1d using basic Riemann summation...
;
; EXAMPLE:
;	print,integrate_1d('integrate_1d_samplefunction',0,1,n=10000)
;	0.33328333	[Ideally: 1/3]
;
;--------------------------------------------------
FUNCTION integrate_1d_samplefunction,x,_extra=_extra
	RETURN,x^2
END
;--------------------------------------------------
FUNCTION integrate_1d,fct,aaa,bbb,n=n,_extra=_extra
	IF NOT KEYWORD_SET(n) THEN n=1000	;integration steps
	
	aa=DOUBLE(aaa)
	bb=DOUBLE(bbb)
	
	dx=DOUBLE(bb-aa)/n
	
	tot=0D
	FOR i=0L,n-1 DO BEGIN		
		tot=tot+dx*CALL_FUNCTION(fct,aa+i*dx,_extra=_extra)
	ENDFOR
	
	RETURN,tot
END
;--------------------------------------------------
