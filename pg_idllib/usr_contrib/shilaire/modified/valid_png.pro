;+
; PROJECT:
;       PSH's PhD
;
; NAME:
;       VALID_PNG()
;
; PURPOSE:
;       To detect if the given file is in PNG format
;
; CATEGORY:
;       Utility
;
; EXPLANATION:
;
; SYNTAX:
;       Result = valid_png(filename)
;
; INPUTS:
;       FILENAME - Name of the file to be detected
;
; OPTIONAL INPUTS:
;       None.
;
; OUTPUTS:
;       RESULT   - 1/0 indicating whether the given file is or is not
;                  a PNG file
;       DIMENSIONS - image dimensions
;;
; OPTIONAL OUTPUTS:
;       None.
;
; KEYWORDS:
;       ERROR - A named variable containing any error message. If no
;               error occurs, a null string is returned.
;
; COMMON:
;       None.
;
; RESTRICTIONS:
;       None.
;
; SIDE EFFECTS:
;       None.
;
; HISTORY:
;       Version 1, November 1, 1995, Liyun Wang, GSFC/ARC. Written
;       Version 2, 30-Jan-1999, Zarro (SM&A) - introduced QUERY_GIF 
;		Version PSH, 2001/06/11 , Saint_Hilaire (ETHZ - IfA)
; CONTACT:
;       Liyun Wang, GSFC/ARC (Liyun.Wang.1@gsfc.nasa.gov)
;-
;

FUNCTION valid_png, filename,dimensions,error=error

   ON_ERROR, 1
   error = ''
   dimensions=[0,0]
   IF datatype(filename) NE 'STR' THEN BEGIN
      error = 'Syntax: a = valid_png(filename)'
      MESSAGE, error, /cont
      RETURN, 0
   ENDIF

   chk=loc_file(filename,count=count)
   if count eq 0 then begin
     error = 'File "'+STRTRIM(filename,2)+'" does not exist!'
     MESSAGE, error, /cont
     RETURN, 0
   ENDIF

;-- new way

   if have_proc('query_gif') then begin
    is_png=call_function('query_png',filename,info)
    if is_png then begin
     dimensions=info.dimensions
     return,1
    endif
   endif

bad: return,0
END
