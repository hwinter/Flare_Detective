;+
; NAME:
;
; pg_darkcol
;
; PURPOSE:
;
; load nice color table using brewer colors, dark2 qualiitative color
; table courtesy of M. Galloy
;
; CATEGORY:
;
; color utils
;
; CALLING SEQUENCE:
;
; pg_darkcol
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
; /help: shows the colors
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
; MODIFICATION HISTORY:
;
; 29-JUL-2009 PG written
; 
;-


PRO pg_darkcol,help=help

loadct,0
linecolors

r0=[  27, 217, 117, 231, 102, 230, 166, 102]
g0=[ 158,  95, 112,  41, 166, 171, 118, 102]
b0=[ 119,   2, 179, 138,  30,   2,  29, 102]

tvlct,r,g,b,/get

r[14]=r0
g[14]=g0
b[14]=b0

r[255]=255
g[255]=255
b[255]=255

tvlct,r,g,b

IF keyword_set(help) THEN pg_plot_coltable

END


