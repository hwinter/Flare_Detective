; Same as has_overlap.pro, except that the inputs can be [2,*] arrays of intervals!
;
; EXAMPLES:
;	PRINT,m_has_overlap([1,3],[[2.5,3.5],[5.5,6.5],[6.7,7.7]],inter=inter)
;	PRINT,m_has_overlap([[1,3],[7.5,8]],[[2.5,3.5],[5.5,6.5],[6.7,7.7]],inter=inter)
;
;
;-------------------------------------------------------------------------------------------------------------------------
FUNCTION m_has_overlap_sub, in1, m_in, inter=inter
	nintvs=N_ELEMENTS(m_in[0,*])

	IF nintvs EQ 0 THEN RETURN,-1 ELSE BEGIN
		res=has_overlap(in1,m_in[*,0], inter=inter)
		IF nintvs LE 1 THEN RETURN,res ELSE BEGIN
			FOR i=1,nintvs-1 DO BEGIN
				res=res+has_overlap(in1,m_in[*,i], inter=interi)
				IF N_ELEMENTS(interi) GT 1 THEN BEGIN
					IF N_ELEMENTS(inter) LE 1 THEN inter=interi ELSE inter=[[inter],[interi]]
				ENDIF
			ENDFOR
			RETURN,KEYWORD_SET(res)
		ENDELSE
	ENDELSE
END
;-------------------------------------------------------------------------------------------------------------------------
FUNCTION m_has_overlap, intvs1, intvs2, inter=inter
	n_intvs=N_ELEMENTS(intvs1[0,*])

	IF n_intvs EQ 0 THEN RETURN,-1 ELSE BEGIN
		res=m_has_overlap_sub(intvs1[*,0], intvs2, inter=inter)
		IF n_intvs LE 1 THEN RETURN,res ELSE BEGIN
			FOR i=1,n_intvs-1 DO BEGIN
				res=res+m_has_overlap_sub(intvs1[*,i], intvs2, inter=interi)
				IF N_ELEMENTS(interi) GT 1 THEN BEGIN
					IF N_ELEMENTS(inter) LE 1 THEN inter=interi ELSE inter=[[inter],[interi]]
				ENDIF
			ENDFOR
			RETURN,KEYWORD_SET(res)
		ENDELSE
	ENDELSE
END
;-------------------------------------------------------------------------------------------------------------------------

