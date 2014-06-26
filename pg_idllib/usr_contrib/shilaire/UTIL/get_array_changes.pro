; This function returns the subscipt of any changes between
; the elements of an array. The array must contain at least
; 2 elements ! The first element is never included.
; This routine was designed with 1-D arrays in mind.
;
; EXAMPLE:
;	PRINT,get_array_changes([0,1,0,0,0,1,1,1,0])
;				  1 1 0 0 1 0 0 1
;


FUNCTION get_array_changes, arr
	ss=WHERE(arr-SHIFT(arr,1) NE 0)
	IF ss[0] EQ -1 THEN RETURN,-1
	IF ss[0] EQ 0 THEN ss=ss[1:*]
	RETURN,ss
END


