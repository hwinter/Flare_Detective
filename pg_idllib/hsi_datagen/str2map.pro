;+
;
; NAME:
;        str2map
;
; PURPOSE: 
;        convert a structure {image, hessi_parameters} in a Zarro
;        map object
;
; CALLING SEQUENCE:
;
;        map=str2map(str)
;
; INPUTS:
;
;        str: structure {im,hessipar}
;
; OUTPUT: 
;        a map object 
;
; VERSION:
;       28-NOV-2002 written
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;-

FUNCTION str2map,str
image=str.im
par=str.hessipar

map=make_map(image)

map.xc=par.xyoffset[0]
map.yc=par.xyoffset[1]
map.time=anytim(par.time_range[0],/yohkoh)
map.dx=par.pixel_size[0]
map.dy=par.pixel_size[1]

RETURN, map

END
