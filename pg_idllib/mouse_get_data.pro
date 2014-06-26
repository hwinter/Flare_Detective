;+
; NAME:
;   mouse_get_data
;
; PURPOSE:
;   return the time and y axis coordinates of the cursor position over
;   an existing utplot
;
; INPUT: 
;   none
;
; OUTPUT: 
;   out: the [x,y] coordinates
;
; KEYWORDS:
;   noanytim: don't use anytim to convert the x axis coordinate
;   noprint: don't print the coordinates
;   noyprint: don't print y coordinate
;
; HISTORY:
;   07-MAY-2002 written, based on older routines
;   08-SEP-2003 added noyprint keyword
;-

PRO mouse_get_data,noanytim=noanytim,help=help,noprint=noprint,out=out,noyprint=noyprint

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;documentation
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

IF keyword_set(help) THEN BEGIN

    print,''
    print,'Procedure MOUSE_GET_DATA'
    print,'Returns the time and y axis coordinates of the cursor position'
    print,'over an existing utplot'
    print,''
    print,'Inputs:'
    print,'        none'
    print,''
    print,'Keywords:'
    print,'         noanytim: inhibits the x axis output as time'
    print,'         noyprint: don''t print y coordinate'
    print,''
    print,'Usage:'
    print,'mouse_get_data'
    print,''
    
    RETURN

ENDIF

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;main
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

@utcommon

!mouse.button=0

WHILE (!mouse.button NE 4) DO BEGIN

    cursor,x,y,/data,/down

    IF !mouse.button EQ 1 THEN BEGIN      
        
        out=[x,y]
 
        IF exist(noanytim) THEN BEGIN
          
            IF NOT keyword_set(noprint) THEN BEGIN
                print,x
                IF NOT keyword_set(noyprint) THEN $
                    print,y
            ENDIF

        ENDIF $
        ELSE BEGIN

            IF NOT keyword_set(noprint) THEN BEGIN            
                print,anytim(x+utbase,/yohkoh)
                IF NOT keyword_set(noyprint) THEN $
                    print,y
            ENDIF

            out=[x+utbase,y]

        ENDELSE
    ENDIF

ENDWHILE

END
