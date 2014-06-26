; EXAMPLE:
;	intvs=[[1,3],[3,4],[6,8]]
; 	intv2complement=[0,10]
;	PRINT,psh_intv_complement(intvs, intv2complement)
;
;
; intvs is a [2,n] array of disjoint intervals.
; intv2complement is a 2-element array, which must not necessarily encompass all the intervals in intvs.
;
; If intvs or intv2complement are strings, they are assumed to be anytimes...
;
; PSH, 2004/08/09 written
;

FUNCTION psh_intv_complement, intvs1, intv2complement1
	IF datatype(intvs1) eq 'STR' THEN intvs=anytim(intvs1) ELSE intvs=intvs1
	IF datatype(intv2complement1) eq 'STR' THEN intv2complement=anytim(intv2complement1) ELSE intv2complement=intv2complement1

	IF m_has_overlap(intvs,intv2complement,inter=inter) THEN BEGIN
		IF intv2complement[0] LT inter[0,0] THEN cintvs=[intv2complement[0],inter[0,0]] ELSE cintvs=-1
		i=1L
		WHILE i LE N_ELEMENTS(inter[0,*])-1 DO BEGIN
			IF inter[1,i-1] LT inter[0,i] THEN BEGIN
				IF N_ELEMENTS(cintvs) EQ 1 THEN cintvs=[inter[1,i-1],inter[0,i]] ELSE cintvs=[[cintvs],[inter[1,i-1],inter[0,i]]]
			ENDIF
			i=i+1
		ENDWHILE
		IF inter[1,i-1] LT intv2complement[1] THEN BEGIN
			IF N_ELEMENTS(cintvs) EQ 1 THEN cintvs=[inter[1,i-1],intv2complement[1]] ELSE cintvs=[[cintvs],[inter[1,i-1],intv2complement[1]]]
		ENDIF

		RETURN,cintvs

	ENDIF ELSE RETURN,intv2complement 
END
