; EXAMPLE:
;	array=FINDGEN(20)
;	PRINT, array[psh_skip(array ,5)]
;
;
; 
;PSH 2004/08/09
;	returns ss of 1 every SKIP images...
;

FUNCTION psh_skip, array, skipfactor, CENTER=CENTER, COMPLEMENT=COMPLEMENT
	sf=FIX(skipfactor) > 2
	IF N_ELEMENTS(array) LT sf THEN ss=0+KEYWORD_SET(CENTER)*N_ELEMENTS(array)/2 ELSE ss=sf*LINDGEN(CEIL(DOUBLE(N_ELEMENTS(array))/sf))+KEYWORD_SET(CENTER)*sf/2
	IF ss[N_ELEMENTS(ss)-1] GE N_ELEMENTS(array) THEN ss=ss[0:N_ELEMENTS(ss)-2]
	IF KEYWORD_SET(COMPLEMENT) THEN BEGIN
		tmp=BYTARR(N_ELEMENTS(array))+1B
		FOR i=0L, N_ELEMENTS(ss)-1 DO tmp[ss[i]]=0
		tmp_ss=WHERE(tmp NE 0)		
		IF tmp_ss[0] EQ -1 THEN RETURN,-1 ELSE ss=tmp_ss
	ENDIF
	RETURN, ss
END
