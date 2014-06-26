;+
;
; NAME:
;        map_coor2pix
;
; PURPOSE: 
;        transform a point solar coordinates to a pixel index (i,j),
;        given in real format. 
;
; CALLING SEQUENCE:
;
;        pixcoor=map_coor2pic(coor,map [,/index])
; 
;
; INPUTS:
;
;        map : a (Zarro) map structure
;        coor: solar coordinates, accept arrays like [x,y] or [[x1,x2],[y1,y2]]
;
; KEYWORDS:
;        index: if set, returns a monodimensional index for the pixel
;        round: if set, rounds the pixels output values
;                
; OUTPUT:
;        pixcoor: coordinates in arcseconds from sun center       
; CALLS:
;
; VERSION:
;       
;        28-MAR-2003 written P.G.
;        13-OCT-2004 added /round P.G.
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;       pgrigis@astro.phys.ethz.ch
;-

FUNCTION map_coor2pix,coor,map,index=index,round=round

dim=size(map.data)

IF size(coor,/n_dimensions) EQ 1 THEN $
pixcoor=fltarr(2) $
ELSE $
pixcoor=fltarr(2,(size(coor))[2])


;scoor[0]=map.xc+map.dx*(pixcoor[0]-dim[1]/2.+0.5); the +0.5 is necessary
;scoor[1]=map.yc+map.dy*(pixcoor[1]-dim[2]/2.+0.5); to ensure that the
                                ;coordinate correspond
                                ;to the center of the pixel!!!!

pixcoor[0,*]=(coor[0,*]-map.xc)/float(map.dx)+dim[1]/2.-0.5
pixcoor[1,*]=(coor[1,*]-map.yc)/float(map.dy)+dim[2]/2.-0.5

IF keyword_set(round) THEN BEGIN
   pixcoor=round(pixcoor)
ENDIF 

IF keyword_set(index) THEN BEGIN
    pixcoor_tmp=round(pixcoor[0])+round(pixcoor[1])*dim[1]
    pixcoor=pixcoor_tmp
ENDIF


RETURN,pixcoor

END





