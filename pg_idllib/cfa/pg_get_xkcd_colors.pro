;+
; NAME:
; 
;   pg_get_xkcd_colors
;
; PURPOSE:
;
;   read the XKCD color table (located in $PGLIBPATH/cfa/xkcd_coltable.txt).
;   This is an unchanged copy from http://xkcd.com/color/rgb.txt
;
; CATEGORY:
;
;   graphic utils
;
; CALLING SEQUENCE:
;
;   coltable=pg_get_xkcd_colors()
;
; INPUTS:
;
;   NONE
;
; OPTIONAL INPUTS:
;
;   NONE
;
; KEYWORD PARAMETERS:
;
;   NONE
;
; OUTPUTS:
;
;   Structure with color name, RGB values
;
; OPTIONAL OUTPUTS:
;
;   NONE
;
; COMMON BLOCKS:
;
;  NONE
;
; SIDE EFFECTS:
;
;  NONE
;
; RESTRICTIONS:
;
;  Environmental $PGLIBPATH should be defined
;
; PROCEDURE:
;
;  Reads ASCII file colors table.
;
; EXAMPLE:
;
;  coltable=pg_get_xkcd_colors()
;
; AUTHOR:
;
;   Paolo Grigis, pgrigis@cfa.harvard.edu
;
; MODIFICATION HISTORY:
;
;  29-NOV-2010 written PG
;
;-

FUNCTION pg_get_xkcd_colors

a=get_logenv('PGLIBPATH')

ps=path_sep()
filename=a+ps+'cfa'+ps+'xkcd_coltable.txt'


d=rd_ascii(filename)

name=d

rgb=bytarr(3,n_elements(name))


FOR i=0,n_elements(d)-1 DO BEGIN 
   name[i]=strtrim((strsplit(d[i],'#',/extract))[0],2)
   rgbstring=strtrim((strsplit(d[i],'#',/extract))[1],2)

   rstring=strupcase(strmid(rgbstring,0,2))
   gstring=strupcase(strmid(rgbstring,2,2))
   bstring=strupcase(strmid(rgbstring,4,2))

   reads,rstring,rvalue,format='(Z)'
   reads,gstring,gvalue,format='(Z)'
   reads,bstring,bvalue,format='(Z)'

   rgb[0,i]=byte(rvalue)
   rgb[1,i]=byte(gvalue)
   rgb[2,i]=byte(bvalue)


ENDFOR

ncolors=n_elements(name)
coltable={nColors:nColors,ColorNames:name,R:reform(rgb[0,*]),G:reform(rgb[1,*]),B:reform(rgb[2,*])}

RETURN, coltable

END 



