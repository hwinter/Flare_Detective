; Ion is at position 0.
; Electron is initially at position D.
;Impact parameter is zero...
;
;EXAMPLE:
;	PRINT,electron_return_time(1.,/LOUD)
;
;--------------------------------------------------------------------------------
FUNCTION electron_return_time, D, dt=dt, LOUD=LOUD
		
	mp=1.66e-27	;kg
	me=9.1e-31	;kg
	e=1.6e-19	;C
	e0=8.85e-12	;F/m	
		
	Nuc=1d
	z=1d
	
	IF NOT KEYWORD_SET(dt) THEN dt=0.001d
	
	txv=[0d,DOUBLE(D),0d]
	
	WHILE txv[1] GT 0. DO BEGIN
		newt=txv[0]+dt
		newx=txv[1]+dt*txv[2]
		newv=txv[2]-SGN(txv[1])*dt*z*e^2. /(4*!dPi*me*e0*txv[1]^2.)
		
		txv[0]=newt
		txv[1]=newx
		txv[2]=newv
		IF KEYWORD_SET(LOUD) THEN PRINT,'Elapsed time: '+strn(txv[0])+' [s]. Distance: '+strn(txv[1])+' [m].  Speed: '+strn(txv[2])+' [m/s].'
	ENDWHILE
	RETURN,txv[0]
END
;--------------------------------------------------------------------------------
