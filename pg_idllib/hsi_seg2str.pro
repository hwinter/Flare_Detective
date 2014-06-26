;+
; NAME:
;      hsi_seg2str
;
; PURPOSE: 
;      return a string with the segment written like
;      1F 3F 5R 6R 7R 
;
; INPUTS:
;      segment: RHESSI segments
;  
; OUTPUTS:
;      a string with the segment used
;      
; KEYWORDS:
;        
;
; HISTORY:
;       16-OCT-2002 written
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;
;-

FUNCTION hsi_seg2str,segment

IF n_elements(segment) NE 18 THEN $
    print,'Not a valid RHESSI segment array!'

str=''
FOR i=0,8 DO BEGIN
    IF segment[i] THEN BEGIN
        str=str+strtrim(i+1,2)+'F'
        IF segment[i+9] THEN str=str+'R ' ELSE str=str+' '
    ENDIF $
    ELSE $
        IF segment[i+9] THEN $
            str=str+strtrim(i+1,2)+'R '
ENDFOR
return,str

END











