;RESTRICTIONS: should interpolate linealy data (e.g. CONGRID) which might have constant values: those aren't detected.



FUNCTION find_local_maxima_1d, vecteur, INTERP=INTERP,	$
	ss=ss

	IF NOT KEYWORD_SET(INTERP) THEN INTERP=0
	IF INTERP EQ 1 THEN INTERP=2
	IF INTERP NE 0 THEN vector=SMOOTH(INTERPOL(vecteur,INTERP*N_ELEMENTS(vecteur),/SPLINE),INTERP) ELSE vector=vecteur

	n=N_ELEMENTS(vector)
	i=0L
	res='none'
	ss=-1
	WHILE i LT n DO BEGIN
		CASE i OF
			0: BEGIN
				IF vector[0] GT vector[1] THEN BEGIN
					IF datatype(res) EQ 'STR' THEN BEGIN
						res=vector[0] 
						ss=0
					ENDIF ELSE BEGIN
						res=[res,vector[0]]
						ss=[ss,0]
					ENDELSE
				ENDIF
			END
			n-1: BEGIN
				IF vector[n-1] GT vector[n-2] THEN BEGIN
					IF datatype(res) EQ 'STR' THEN BEGIN
						res=vector[n-1] 
						ss=n-1
					ENDIF ELSE BEGIN
						res=[res,vector[n-1]]
						ss=[ss,n-1]
					ENDELSE			
				ENDIF					
			END
			ELSE: BEGIN
				value=vector[i]
				IF ((vector[i-1] LT value) AND (vector[i+1] LT value))	THEN BEGIN
					IF datatype(res) EQ 'STR' THEN BEGIN
						res=vector[i] 
						ss=i
					ENDIF ELSE BEGIN
						res=[res,vector[i]]
						ss=[ss,i]
					ENDELSE								
				ENDIF
			ENDELSE
		ENDCASE		
		i=i+1;
	ENDWHILE
	IF INTERP NE 0 THEN ss=ss/INTERP
	RETURN,res
END
