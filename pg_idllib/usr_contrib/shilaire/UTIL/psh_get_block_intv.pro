;+
; PSH 2004/08/12 written
;
; From an inoput (1-D?) array, will return a list [2,n] of intervals that have same values.
;
;
; PRINT,psh_get_block_intv([1])
; PRINT,psh_get_block_intv([3,3,3])
; PRINT,psh_get_block_intv([1,2,3,3,3])
; PRINT,psh_get_block_intv([1,1,1,1,2,2,2])
; PRINT,psh_get_block_intv([1,1,1,1,2,2,2],min=4)
; PRINT,psh_get_block_intv([1,1,1,1,2,2,2],val=2)
; PRINT,psh_get_block_intv([1,1,1,1,2,2,2],val=0)
; PRINT,psh_get_block_intv([1,1,1,1,2,2,2],val=[1,2])
; PRINT,psh_get_block_intv([1,1,1,1,2,2,2],min=4,val=1)
; PRINT,psh_get_block_intv([1,1,1,1,2,2,2],min=4,val=2)
; PRINT,psh_get_block_intv([1,1,1,1,2,2,2],min=4,val=2)
; PRINT,psh_get_block_intv(FINDGEN(10))
; PRINT,psh_get_block_intv(FINDGEN(10),min=2)
; PRINT,psh_get_block_intv(FINDGEN(10),val=[3,5,7])
;
;
;
; KEYWORDS:
;	min_length: minimal block length. May cause a -1 output!
;	value:	list of values whose intervals should be returned. May cause a -1 output!
;
;-
;----------------------------------------------------------------------------------------------------------
FUNCTION psh_get_block_intv_takeit, arr, min_length=min_length, values=values
	IF KEYWORD_SET(min_length) THEN BEGIN
		IF N_ELEMENTS(arr) LT min_length THEN RETURN,0
	ENDIF
	IF exist(values) THEN BEGIN
		tmp=WHERE(values EQ arr[0])
		IF tmp[0] EQ -1 THEN RETURN,0
	ENDIF
	RETURN,1
END
;----------------------------------------------------------------------------------------------------------
FUNCTION psh_get_block_intv, arr, min_length=min_length, values=values
	IF NOT KEYWORD_SET(min_length) THEN min_length=0
	n=N_ELEMENTS(arr)
	ch_ss=get_array_changes(arr)
	IF ch_ss[0] EQ -1 THEN BEGIN
		newintv=[0,n-1]
		IF psh_get_block_intv_takeit(arr[newintv[0]:newintv[1]], min_length=min_length, values=values) THEN RETURN,newintv ELSE RETURN,-1
	ENDIF

	newintv=[0,ch_ss[0]-1]
	IF psh_get_block_intv_takeit(arr[newintv[0]:newintv[1]], min_length=min_length, values=values) THEN intvs=newintv ELSE intvs=-1
	FOR i=0L,N_ELEMENTS(ch_ss)-2 DO BEGIN
		newintv=[ch_ss[i],ch_ss[i+1]-1]
		IF psh_get_block_intv_takeit(arr[newintv[0]:newintv[1]], min_length=min_length, values=values) THEN BEGIN
			IF N_ELEMENTS(intvs) EQ 1 THEN intvs=newintv ELSE intvs=[[intvs],[newintv]]
		ENDIF
	ENDFOR
	newintv=[ch_ss[N_ELEMENTS(ch_ss)-1],n-1]
	IF psh_get_block_intv_takeit(arr[newintv[0]:newintv[1]], min_length=min_length, values=values) THEN BEGIN
		IF N_ELEMENTS(intvs) EQ 1 THEN intvs=newintv ELSE intvs=[[intvs],[newintv]]
	ENDIF
	RETURN,intvs
END
;----------------------------------------------------------------------------------------------------------
