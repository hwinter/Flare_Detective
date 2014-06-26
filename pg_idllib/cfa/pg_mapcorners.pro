;+
; NAME:
;
;  pg_mapcorners
;
; PURPOSE:
;
;  compute the positions of the corners of a SSW map...
;
; CATEGORY:
;
;
;
; CALLING SEQUENCE:
;
;
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
;
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
;
; Paolo Grigis
; pgrigis@cfa.harvard.edu
;
;
; MODIFICATION HISTORY:
;
; 09-SEP-2008 written PG
;
;-

PRO pg_mapcorners,map,ulc=ulc,urc=urc,llc=llc,lrc=lrc;,halfpix=halfpix


xc=map.xc
yc=map.yc

s=size(map.data)
nx=s[1]
ny=s[2]

;off=keyword_set(halfpixel)*0.5*[dx,dy]

dx=map.dx
dy=map.dy

ulc=[xc,yc]+0.5*[nx,ny]*[-dx,+dy];+[-off[0],+off[1]]
urc=[xc,yc]+0.5*[nx,ny]*[+dx,+dy];+[+off[0],+off[1]]
llc=[xc,yc]+0.5*[nx,ny]*[-dx,-dy];+[-off[0],-off[1]]
lrc=[xc,yc]+0.5*[nx,ny]*[+dx,-dy];+[+off[0],-off[1]]

END


