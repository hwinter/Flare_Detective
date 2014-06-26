
;=======================================================================================================================
PRO psh_win,xs,ys,nb=nb
	CASE N_PARAMS() OF
		1: BEGIN xsize=xs & ysize=xs & END
		2: BEGIN xsize=xs & ysize=ys & END
		ELSE: BEGIN xsize=512 & ysize=512 & END
	ENDCASE	
	
	IF ((!D.NAME NE 'Z') AND (!D.NAME NE 'PS')) THEN BEGIN 
		IF EXIST(nb) THEN WINDOW,nb,xs=xsize,ys=ysize ELSE WINDOW,xs=xsize,ys=ysize,/FREE
	ENDIF ELSE BEGIN
		DEVICE,/CLOSE
		IF (!D.NAME EQ 'Z') THEN DEVICE,set_resolution=[xsize,ysize]
	ENDELSE

	!P.MULTI=0	
END
;=======================================================================================================================
