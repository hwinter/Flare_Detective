;
;return the map coordinates of a point selected by the mouse
;

FUNCTION mapcoor

!mouse.button=0
clicks=0
xint=0 & yint=0
oldx=0 & oldy=0

WHILE (!mouse.button NE 4) AND (clicks LE 1) DO BEGIN
    cursor,xint,yint,/data,/down
    IF !mouse.button EQ 1 THEN BEGIN
        print,'x: ',xint
        print,'y: ',yint
        ;IF clicks EQ 0 THEN BEGIN
        ;    oldx=xint
        ;    oldy=yint
        ;ENDIF
        ;
        ;clicks=clicks+1
    ENDIF
    ;print,clicks
ENDWHILE

RETURN,-1
END
