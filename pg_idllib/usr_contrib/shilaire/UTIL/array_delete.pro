; this works only for 1-D arrays.
;
; if the number of elements to delete (need not to be sorted, can be repeated several times) is equal or bigger
; then inarr's size, returns a 'NULL' message
;





FUNCTION array_delete_one_element,inarr,ss_to_delete
	n=N_ELEMENTS(inarr)
	ss_to_remove=ss_to_delete[0]
		
	IF n LE 1 THEN MESSAGE,'......................array too small'
	IF ss_to_remove GT (n-1) THEN MESSAGE,'......................index to delete is too big !!!'
	
	;now, n>=2
	
	IF ss_to_remove EQ 0 THEN RETURN,inarr[1:*]
	IF ss_to_remove EQ (n-1) THEN RETURN,inarr[0:n-2]
	
	RETURN,[inarr[0:ss_to_remove-1],inarr[ss_to_remove+1:*]]
END









FUNCTION array_delete,inarr,ss_to_remove

	ss_to_delete= ss_to_remove[UNIQ(ss_to_remove, SORT(ss_to_remove))]
	newarr=inarr
	
	IF N_ELEMENTS(ss_to_delete) GT N_ELEMENTS(inarr) THEN MESSAGE,'...............Too many elements to delete !!!'
	IF N_ELEMENTS(ss_to_delete) EQ N_ELEMENTS(inarr) THEN RETURN,'NULL'
	
	WHILE N_ELEMENTS(ss_to_delete) GT 1 DO BEGIN
		newarr=array_delete_one_element(newarr,ss_to_delete[0])
		tmp=ss_to_delete[1:*]
		ss_to_delete=tmp-1
	ENDWHILE
	newarr=array_delete_one_element(newarr,ss_to_delete)
		
	RETURN,newarr
END




