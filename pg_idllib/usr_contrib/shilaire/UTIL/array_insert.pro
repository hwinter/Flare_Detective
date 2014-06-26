; inserts a 1-D array into another one.
;start_ss is the position in base array of first inserted element

FUNCTION array_insert,basearray,arraytobeinserted,start_ss
	
	nbase=N_ELEMENTS(basearray)
	ninsert=N_ELEMENTS(arraytobeinserted)
	
	;could do a lot of error checking, here...
	
	CASE start_ss OF
		0:RETURN,[arraytobeinserted,basearray]
		nbase:RETURN,[basearray,arraytobeinserted]		
		ELSE: RETURN,[basearray[0:start_ss-1],arraytobeinserted,basearray[start_ss:*]]
	ENDCASE
END
