;+
;
; NAME:
;        map_pix2coor
;
; PURPOSE: 
;        transform a point given in pixel unit to a solar coordinate.
;        The pixel (i,j) is converted to the geometric coordinates
;        of the center of that pixel, (0,0)  correspond to the center
;        of the lower left pixel. To get, say, the coordinates
;        corresponding to the upper right corner of this pixel,
;        you have to input (i+0.5,j+0.5), and so on for the other corners
; 
;
; CALLING SEQUENCE:
;
;        scoor=map_pix2coor(pixcoor,map)
; 
;
; INPUTS:
;
;        map : a (Zarro) map structure
;        pixcoor: pixel coordinates
;
; KEYWORDS:
;        
;                
; OUTPUT:
;        scoor: coordinates in arcseconds from sun center       
; CALLS:
;
; VERSION:
;       
;        4-MAR-2003 written
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;-

FUNCTION map_pix2coor,pixcoor,map

dim=size(map.data)

scoor=fltarr(2)


scoor[0]=map.xc+map.dx*(pixcoor[0]-dim[1]/2.+0.5); the +0.5 is necessary
scoor[1]=map.yc+map.dy*(pixcoor[1]-dim[2]/2.+0.5); to ensure that the
                                ;coordinate correspond
                                ;to the center of the pixel!!!!

RETURN,scoor

END





