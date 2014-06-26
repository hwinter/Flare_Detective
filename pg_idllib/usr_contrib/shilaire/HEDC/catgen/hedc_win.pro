
;=======================================================================================================================
PRO hedc_win,xs,ys,nb=nb
	IF NOT KEYWORD_SET(nb) THEN nb=0
	CASE N_PARAMS() OF
		1: BEGIN xsize=xs & ysize=xs & END
		2: BEGIN xsize=xs & ysize=ys & END
		ELSE: BEGIN xsize=512 & ysize=512 & END
	ENDCASE	
	
	IF !D.NAME NE 'Z' THEN BEGIN 
		WINDOW,nb,xs=xsize,ys=ysize
	ENDIF ELSE BEGIN
		DEVICE,/CLOSE
		DEVICE, set_resolution=[xsize,ysize]
	ENDELSE

	!P.MULTI=0	
END
;=======================================================================================================================










;IF NOT KEYWORD_SET(Zbuffer) THEN wdef,0 ELSE BEGIN
;        old_device=!D.NAME
;        set_plot,'Z',/COPY
;        DEVICE, set_resolution=[512,512]
;ENDELSE
;
;; END----------
;IF KEYWORD_SET(Zbuffer) THEN BEGIN
;        DEVICE,/CLOSE
;        SET_PLOT,old_device
;ENDIF
