;+
; NAME:
;
; pg_set_ps
;
; PURPOSE:
;
; set the plot to ps, with ok defaults
;
; CATEGORY:
;
; utilties (ps)
;
; CALLING SEQUENCE:
;
; pg_set_ps 
;
; INPUTS:
;
;
;
; OPTIONAL INPUTS:
;
;
;
; KEYWORD PARAMETERS:
;
; psfonts: uses hardware ps fonts
; filename: ps filename
; landscape: if set uses landscape default settings
;
; OUTPUTS:
;
;
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
;
;
; AUTHOR:
; Paolo Grigis, Institute for Astronomy, ETH Zurich
; pgirgis@astro.phys.ethz.ch
;
; MODIFICATION HISTORY:
;
; 23-FEB-2004 Paolo Grigis written
; 02-APR-2004 added encapsulated keyword PG
; 22-SEP-2004 added psfonts keyword PG
; 30-MAY-2006 changed psfonts behavior to enable true type fonts usage PG
;-

PRO pg_set_ps,filename=filename,landscape=landscape $
             ,xsize=xsize,ysize=ysize,psfonts=psfonts $
             ,xoffset=xoffset,yoffset=yoffset $
             ,info=info,encapsulated=encapsulated


filename=fcheck(filename,'idl.ps')

IF keyword_set(psfonts) THEN !P.font=1

IF NOT keyword_set(encapsulated) THEN BEGIN 
   IF keyword_set(landscape) THEN BEGIN

      xoffset=fcheck(xoffset,1)
      yoffset=fcheck(yoffset,29)
      xsize=fcheck(xsize,28)
      ysize=fcheck(ysize,18)
      landscape=1
      portrait=0
      encapsulated=0

   ENDIF ELSE BEGIN

      xoffset=fcheck(xoffset,1)
      yoffset=fcheck(yoffset,1)
      xsize=fcheck(xsize,18)
      ysize=fcheck(ysize,28)
      landscape=0
      portrait=1
      encapsulated=0

   ENDELSE
ENDIF ELSE BEGIN
   landscape=0
   portrait=1
   encapsulated=1
   xsize=fcheck(xsize,18)
   ysize=fcheck(ysize,28)
   xoffset=0
   yoffset=0
ENDELSE


IF keyword_set(info) THEN BEGIN 

   print,'PS SETTINGS'
   print,'FILE    : ',filename
   print,'XOFFSET : ',strtrim(string(xoffset),2)
   print,'YOFFSET : ',strtrim(string(yoffset),2)
   print,'XSIZE   : ',strtrim(string(xsize),2)
   print,'YSIZE   : ',strtrim(string(ysize),2)
    IF landscape EQ 1 THEN $
     print,'ORIENTATION: LANDSCAPE' ELSE $
     print,'ORIENTATION: PORTRAIT'
   IF encapsulated EQ 0 THEN $
     print,'PS file' ELSE $
     print,'EPS file'

   RETURN

ENDIF 


set_plot,'PS'
device,filename=filename $
      ,yoffset=yoffset,ysize=ysize,xoffset=xoffset,xsize=xsize $
      ,portrait=portrait,landscape=landscape,encapsulated=encapsulated

IF keyword_set(psfonts) THEN device,SET_FONT='Helvetica', /TT_FONT


END
