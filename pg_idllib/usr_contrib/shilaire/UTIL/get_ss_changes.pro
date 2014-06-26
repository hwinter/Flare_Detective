; this functions returns the positions of changes in the input array 
;	(meaning a change occured between the ith and ith+1 positions)
; ex: PRINT,get_ss_changes([1,1,1,0,0,0,1,1,0,1,1,1]) returns:
;		[2,5,7,8]
;	or returns -1 if absolutely no changes ever occurred.


FUNCTION get_ss_changes,inarr
	IF N_ELEMENTS(inarr) LT 2 THEN BEGIN
		MESSAGE,'........ array size smaller than 2 !!!',/CONT
		RETURN,-1
	ENDIF
		
	res=-1
	FOR i=0,N_ELEMENTS(inarr)-2 DO BEGIN
		IF inarr[i] EQ inarr[i+1] THEN res=[res,0] ELSE res=[res,1]			
	ENDFOR
	RETURN,WHERE(res[1:*] NE 0)
END
