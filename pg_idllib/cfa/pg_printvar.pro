;+
; NAME:
;
; pg_printvar
;
; PURPOSE:
;
; print names and values of varaibles
;
; CATEGORY:
; 
; utils
;
; CALLING SEQUENCE:
;
;  pg_printvar,a [,b,c,...] [,format=format]
;
; INPUTS:
;
; variables (up yo 9)
;
; OPTIONAL INPUTS:
;
; format: optional format statement to string()
;
; KEYWORD PARAMETERS:
;
; 
;
; OUTPUTS:
;
; none - output is written to the screen
;
; OPTIONAL OUTPUTS:
;
;
;
; COMMON BLOCKS:
;
;
;
; SIDE EFFECTS:
;
;
;
; RESTRICTIONS:
;
;
;
; PROCEDURE:
;
;
;
; EXAMPLE:
;
; a=1 & b=2.0 & pg_printvar,a,b
;
;
; AUTHOR
;
; Paolo C. Grigis
;
; MODIFICATION HISTORY:
;
; 18-AUG-2009 written PG
;
;-


PRO pg_printvar,x0,x1,x2,x3,x4,x5,x6,x7,x8,x9,format=format

IF exist(x0) THEN print,scope_varname(x0,level=-1)+' = '+strtrim(string(x0,format=format),2)
IF exist(x1) THEN print,scope_varname(x1,level=-1)+' = '+strtrim(string(x1,format=format),2)
IF exist(x2) THEN print,scope_varname(x2,level=-1)+' = '+strtrim(string(x2,format=format),2)
IF exist(x3) THEN print,scope_varname(x3,level=-1)+' = '+strtrim(string(x3,format=format),2)
IF exist(x4) THEN print,scope_varname(x4,level=-1)+' = '+strtrim(string(x4,format=format),2)
IF exist(x5) THEN print,scope_varname(x5,level=-1)+' = '+strtrim(string(x5,format=format),2)
IF exist(x6) THEN print,scope_varname(x6,level=-1)+' = '+strtrim(string(x6,format=format),2)
IF exist(x7) THEN print,scope_varname(x7,level=-1)+' = '+strtrim(string(x7,format=format),2)
IF exist(x8) THEN print,scope_varname(x8,level=-1)+' = '+strtrim(string(x8,format=format),2)
IF exist(x9) THEN print,scope_varname(x9,level=-1)+' = '+strtrim(string(x9,format=format),2)


END

