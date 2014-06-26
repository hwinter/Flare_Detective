;  Pascal Saint-Hilaire	2001/07/23
;	psainth@hotmail.com OR shilaire@astro.phys.ethz.ch
;
; this routine simply returns the coordinates of a pixel in a window 
; at each left-click, and prints them as stdout. Right-click to quit.
;
; OPTIONAL INPUT : w : window# to be examined
;
; MODIFIED:
;	2001/10/26 : added /data keyword, and crosshair capability
;	2001/11/19 : added the pixel value when reading device points
;

PRO mouse_pos,w,data=data

IF exist(w) then BEGIN
	oldwindow=!D.WINDOW
	wset,w
ENDIF

;IF EXIST(data) THEN cursor,x,y,/data,/down ELSE cursor,x,y,/dev,/down
!mouse.button=0

WHILE (!mouse.button NE 4) DO BEGIN
	IF EXIST(data) THEN cursor,x,y,/data,/down ELSE cursor,x,y,/dev,/down
	IF (!mouse.button EQ 1) THEN BEGIN
		IF NOT EXIST(data) THEN BEGIN
			pixval=TVRD(x,y,1,1)
			PRINT,'x='+STRN(x)+' y='+STRN(y)+'  Pixel value='+STRN(pixval)	
		ENDIF ELSE PRINT,'x='+STRN(x)+' y='+STRN(y)
	ENDIF
	IF (!mouse.button EQ 2) THEN BEGIN
		IF KEYWORD_SET(data) THEN NormPos=CONVERT_COORD(x,y,/data,/to_normal) ELSE NormPos=CONVERT_COORD(x,y,/dev,/to_norm)
	print,NormPos
		plots,[NormPos(0),NormPos(0)],[0.0,1.0],/norm
		plots,[0.0,1.0],[NormPos(1),NormPos(1)],/norm
	ENDIF
ENDWHILE

if exist(w) then wset,oldwindow
END
