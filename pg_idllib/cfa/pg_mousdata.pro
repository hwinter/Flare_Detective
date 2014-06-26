;+
; NAME:
;   pg_mousdata
;
; CALLING SEQUENCE:
;
;  pg_mousdata,x=x,y=y
;
;
; PURPOSE:
;  returns x and y coordinates of points clicked on the screen by the user
;
; INPUT: 
;   none
;
; OUTPUT: 
;   x,y
;
; KEYWORDS:
;   noanytim: don't use anytim to convert the x axis coordinate
;   noprint: don't print the coordinates
;   noyprint: don't print y coordinate
;
; HISTORY:
;   07-MAY-2002 written, based on older routines
;   08-SEP-2003 added noyprint keyword
;   20-JAN-2010 modified to return array of x,y coordinates 
;-

PRO pg_mousdata,x=x,y=y,data=data,device=device,normal=normal,quiet=quiet

!mouse.button=0

xin=-1
yin=-1

WHILE (!mouse.button NE 4) DO BEGIN

    cursor,x,y,/down,data=data,device=device,normal=normal

    IF !mouse.button EQ 1 THEN BEGIN      
        
       xin=[xin,x]
       yin=[yin,y]
          
       IF NOT keyword_set(quiet) THEN $
          print,'( '+strtrim(x,2)+' , '+strtrim(y,2)+' )'

    ENDIF 

ENDWHILE

IF n_elements(xin) GE 1 THEN x=xin[1:*]
IF n_elements(yin) GE 1 THEN y=yin[1:*]

END
