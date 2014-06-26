; PRINT All Info 
; by PSH 2001/04/25
; outputs an input structure either to standard ouput or to an ASCII file (appends !!!).
; principle : recursive decomposition of any given structure

; MINOR ANNOYANCE concerning arrays : only the overall 1-D index is given,
;	not the multi-dimensional index.

; USERS : NEVER use keyword a_lun : it is for internal (recursive) purposes only.

; INPUTS:
	; A : something to print to stdout or to filename
	; [filename]
	; [prefix]
	; [/type]

; if /type keyword is set, then the datatype is also printed

;******************************************************************************
PRO printai,A,filename=filename,prefix=prefix,type=type
IF NOT keyword_set(prefix) then prefix=''

;if single element...
if ((n_elements(A) eq 1) AND (datatype(A) ne 'STC')) then BEGIN
	ligne=prefix
	if keyword_set(type) then ligne=ligne+' ('+datatype(A)+')'
	ligne=ligne+': '+STRN(A)
	IF NOT keyword_set(filename) THEN PRINT,ligne ELSE BEGIN
							OPENW,a_lun,filename,/GET_LUN,/APPEND
							PRINTF,a_lun,ligne
							FREE_LUN,a_lun
							   ENDELSE
							  ENDIF

;if array....
if N_ELEMENTS(A) gt 1 then BEGIN
		for i=0,N_ELEMENTS(A)-1 do BEGIN
		printai,A(i),filename=filename,	$
			prefix=prefix+'['+STRN(i)+']',type=type
					   ENDFOR
		RETURN
			   ENDIF

;if a struct...
if datatype(A) eq 'STC' then BEGIN
		field_names=TAG_NAMES(A)	
		FOR i=0,N_TAGS(A)-1 do printai,A.(i),filename=filename,	$
					prefix=prefix+'.'+field_names(i),type=type
			     ENDIF
END
;******************************************************************************
