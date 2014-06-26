;+
; PSH 2004/09/23
;
; EXAMPLE:
;	1)
;	a=[0,1,2,3,4,7,6,3,3]	
;	PRINT, psh_uniq_sort(a)
;	2)
;	a=[0,1,2,3,4,7,6,3,3]
;	PRINT,a[psh_uniq_sort(a,/SS)]
;-

FUNCTION psh_uniq_sort, arr, SS=SS
	IF KEYWORD_SET(SS) THEN RETURN,UNIQ(arr,SORT(arr)) ELSE RETURN, arr[UNIQ(arr,SORT(arr))]
END
