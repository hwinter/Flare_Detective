;+
; NAME:
;
; pg_map_setzero
;
; PURPOSE:
;
; set a region of a Zarro map structure equal zero
;
; CATEGORY:
;
; map utilities
;
; CALLING SEQUENCE:
;
; pg_map_setzero,map,x,y,xpixel,ypixel [,zero=zero]
;
; INPUTS:
;
; map: a Zarro map structure
; x,y: coordinates of the center pixel
; xpixel,ypixel: number of pixel of the rectangle to set to zero
;
; OPTIONAL INPUTS:
;
; zero: the value whioch is set in the array, default 0.
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
; Paolo Grigis, Institute for Astronomy, ETH Zurich
; pgrigis@astro.phys.ethz.ch
;
;
; MODIFICATION HISTORY:
;
; 12-FEB-2002 written
;
;
;-
PRO pg_map_setzero,map,x,y,xpixel,ypixel,zero=zero

checkvar,zero,0.


pixcoor=map_coor2pix([x,y],map)


xmin=0
xmax=(size(map.data))[1]-1
ymin=0
ymax=(size(map.data))[2]-1

xinds=(round(pixcoor[0])-round(xpixel)/2)>xmin
xinde=(round(pixcoor[0])+round(xpixel)/2-1+(round(xpixel) MOD 2))<xmax
yinds=(round(pixcoor[1])-round(ypixel)/2)>ymin
yinde=(round(pixcoor[1])+round(ypixel)/2-1+(round(ypixel) MOD 2))<ymax

data=map.data

data[xinds:xinde,yinds:yinde]=zero

map.data=data

END
