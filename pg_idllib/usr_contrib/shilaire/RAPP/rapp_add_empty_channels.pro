;+
; PSH 2004/09/20
;
;-
FUNCTION rapp_add_empty_channels, spg, largest_jump=largest_jump, blankvalue=blankvalue
	IF NOT KEYWORD_SET(largest_jump) THEN largest_jump=0.05
	minintv=largest_jump*(MAX(spg.y)-MIN(spg.y))
	IF NOT KEYWORD_SET( blankvalue) THEN  blankvalue=0.99*MIN(spg.spectrogram)
	
	newdata=spg.spectrogram
	newyaxis=spg.y
	
	i=1L
	goon=1
	WHILE goon DO BEGIN
		IF abs(newyaxis[i]-newyaxis[i+1]) GT minintv THEN BEGIN
			newyaxis=[newyaxis[0:i],newyaxis[i]+sgn(newyaxis[i+1]-newyaxis[i])*minintv,newyaxis[i+1:*]]
			PRINT,'Added: '+strn(newyaxis[i]+minintv)
			newdata=[[newdata[*,0:i]],[FLTARR(N_ELEMENTS(spg.spectrogram[*,0]))+blankvalue],[newdata[*,i+1:*]]]
		ENDIF		
		i=i+1
		IF i GE N_ELEMENTS(newyaxis)-1 THEN goon=0
	ENDWHILE
	RETURN,{spectrogram:newdata,x:spg.x,y:newyaxis}
END

