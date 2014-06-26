;+
; PSH 2004/09/07
;
; This routine allows to display a picture on the screen, click on some points with the mouse,
; and put then in an IDL array, which can later be saved as a fits file.
; I use to convert bitmap (.GIF, .jpg, .png) plots into IDL arrays...
;
; First, 2 points must be clicked, and their respective x,y values entered.
; Then, as many points in the plot as wished can be taken (right-click to stop).
; 
;
; EXAMPLE 1:
;	PLOT,FINDGEN(100)
;	data=psh_plot2array(cursor=40)
;	linecolors
;	OPLOT,data.x,data.y,color=2,psym=4
;	mwrfits,data,'file.fits',/CREATE,['X-axis units, Y-axis units','ProutBouchef']
;
;	
; EXAMPLE 2:
;	PLOT,FINDGEN(100)+1,/YLOG
;	data=psh_plot2array(/YLOG)
;	OPLOT,data.x,data.y,color=2,psym=4
;
; EXAMPLE 3:
;	PLOT,10^(FINDGEN(10)),10^FINDGEN(10),/XLOG,/YLOG
;	data=psh_plot2array(/XLOG,/YLOG)
;	OPLOT,data.x,data.y,color=2,psym=4
;
;-

FUNCTION psh_plot2array, XLOG=XLOG, YLOG=YLOG, SILENT=SILENT, color=color, cursor=cursor, data_to_update=data_to_update
	IF NOT KEYWORD_SET(color) THEN color=0
	IF KEYWORD_SET(SILENT) THEN SILENT=1 ELSE SILENT=0
	IF KEYWORD_SET(cursor) THEN DEVICE,cursor_standard=cursor ; 24, 40, 32,,33,34 (STD),35 40,...

	;First, calibrate the data...
	IF NOT SILENT THEN PRINT,'Click on a calibration point (e.g. lower left corner):'
	CURSOR,x1n,y1n,/NORMAL,/DOWN
	IF NOT SILENT THEN PRINT,'Now enter its X data coordinate:'
	tmp=0d & READ,tmp & PRINT,tmp & x1d=tmp
	IF NOT SILENT THEN PRINT,'Now enter its Y data coordinate:'
	tmp=0d & READ,tmp & PRINT,tmp & y1d=tmp

	IF NOT SILENT THEN PRINT,'Now click the second calibration point (e.g. upper right corner):'
	CURSOR,x2n,y2n,/NORMAL,/DOWN
	IF NOT SILENT THEN PRINT,'Now enter its X data coordinate:'
	tmp=0d & READ,tmp & PRINT,tmp & x2d=tmp
	IF NOT SILENT THEN PRINT,'Now enter its Y data coordinate:'
	tmp=0d & READ,tmp & PRINT,tmp & y2d=tmp
	
	IF NOT SILENT THEN PRINT,'Now left-click on as many points as desired on the curve.'
	IF NOT SILENT THEN PRINT,'Middle-click to erase last entry, right-click to quit.'	

	xn='bla'
	yn='bla'
	!MOUSE.button=0		
	WHILE !MOUSE.button NE 4 DO BEGIN
		CURSOR,x,y,/NORMAL,/DOWN
		CASE !MOUSE.button OF
			1:BEGIN
				IF NOT SILENT THEN PRINT,'Point grabbed!'
				PLOTS,x,y,/NORM,psym=7,color=color
				IF datatype(xn) NE 'STR' THEN BEGIN
					xn=[xn,x]
					yn=[yn,y]
				ENDIF ELSE BEGIN
					xn=x
					yn=y
				ENDELSE
			END
			2:BEGIN
				IF datatype(xn) NE 'STR' THEN BEGIN
					IF NOT SILENT THEN PRINT,'Last point removed!'				
					PLOTS,xn[N_ELEMENTS(xn)-1],yn[N_ELEMENTS(yn)-1],/NORM,psym=7,color=0
					IF N_ELEMENTS(xn) EQ 1 THEN BEGIN 
						xn='bla' 
						yn='bla'
					ENDIF ELSE BEGIN
						xn=xn[0:N_ELEMENTS(xn)-2]
						yn=yn[0:N_ELEMENTS(yn)-2]
					ENDELSE
				ENDIF				
			END
			ELSE:BEGIN
				IF NOT SILENT THEN PRINT,'Exiting routine...'				
			END
		ENDCASE	
		IF NOT SILENT THEN BEGIN
			IF datatype(xn) NE 'STR' THEN PRINT,'Number of points taken so far: '+strn(N_ELEMENTS(xn)) ELSE PRINT,'No points taken so far.'
		ENDIF
	ENDWHILE

	IF datatype(xn) EQ 'STR' THEN BEGIN
		IF NOT SILENT THEN PRINT,'No points grabbed! Returning -1'
		RETURN,-1
	ENDIF

	IF KEYWORD_SET(XLOG) THEN BEGIN
		xd=x1d*(x2d/x1d)^((xn-x1n)/(x2n-x1n))		
	ENDIF ELSE BEGIN
		dx=(x2d-x1d)/(x2n-x1n)	;dxd/dxn ;LIN scale
		xd=x1d+(xn-x1n)*dx
	ENDELSE
	IF KEYWORD_SET(YLOG) THEN BEGIN
		yd=y1d*(y2d/y1d)^((yn-y1n)/(y2n-y1n))
	ENDIF ELSE BEGIN
		dy=(y2d-y1d)/(y2n-y1n)	;dyd/dyn ;LIN scale
		yd=y1d+(yn-y1n)*dy
	ENDELSE

	IF KEYWORD_SET(data_to_update) THEN BEGIN
		xd=[data_to_update.x,xd]
		yd=[data_to_update.y,yd]
	ENDIF
	ss=UNIQ(xd,SORT(xd))
	xd=xd[ss]
	yd=yd[ss]

	IF KEYWORD_SET(cursor) THEN DEVICE,cursor_standard=34
	RETURN,{x:xd,y:yd}	
END


