; EXAMPLE:
;
;	PRINT,get_contiguous_ss([0,2,3,4])
;
;	x=FINDGEN(100)-50
;	ss=WHERE((x LT -25) OR (x GT 25))
;	PRINT,x[ss[get_contiguous_ss(ss)]]
;	
;
;HISTORY:
;	PSH 2004/08/05 written.
;


FUNCTION get_contiguous_ss, ss, min_length=min_length
	IF N_ELEMENTS(ss) EQ 1 THEN RETURN,[0,0]
	IF NOT KEYWORD_SET(min_length) THEN min_length=1
	
	intv=-1
	i=0L
	prev=0L
	WHILE i LT N_ELEMENTS(ss)-1 DO BEGIN
		IF ss[i+1] NE ss[i]+1 THEN BEGIN
			IF (i-prev+1 GE min_length) THEN BEGIN
				IF N_ELEMENTS(intv) EQ 1 THEN intv=[prev,i] ELSE intv=[[intv],[prev,i]]
			ENDIF
			prev=i+1	
		ENDIF
		i=i+1
	ENDWHILE
	IF (i-prev+1 GE min_length) THEN BEGIN
		IF N_ELEMENTS(intv) EQ 1 THEN intv=[prev,i] ELSE intv=[[intv],[prev,i]]
	ENDIF
RETURN,intv	
END

