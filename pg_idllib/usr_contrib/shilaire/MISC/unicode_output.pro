

PRO unicode_output,startnx=startnx
	IF NOT KEYWORD_SET(startnx) THEN startnx=0L
	psh_win,900
	nx=18L
	ny=90L
	FOR i=0L,nx-1 DO BEGIN					&$
		FOR j=0L,ny-1 DO BEGIN				
			dec2hex,strn(STRING(ny*(startnx+i)+j)),out,/UPPER,/QUIET
			txt=out+': !Z('+out+')'			
			XYOUTS,/DEV,i*50,890-j*10,txt		
		ENDFOR						
	ENDFOR
END

