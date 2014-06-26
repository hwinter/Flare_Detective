;+
;
; NAME:
;        mapcenterfit
;
; PURPOSE: 
;        find the coordinates of the center of an ellipse which can be
;        best fitted to the map object
;      
;
; CALLING SEQUENCE:
;
;        cent=mapcenterfit(map, [optional keywords])
; 
;
; INPUTS:
;
;        map : a (Zarro) map structure
;        maxfr: consider only pixel brighter than maxfr of the maximum
;
; KEYWORDS:
;        onlypositive: set the negative element of the array to 0
;        dontlower: set the unwanted data to 0, but don't lower the
;        rest, work only if maxfr is already set
;        centroid: return the centroid instead of the center of the
;        fitted ellipse
;                
; OUTPUT:
;        cent: coordinates of the center of the ellipse        
;        ell: the fitted ellipse
; CALLS:
;        gauss2dfit
;
; VERSION:
;       
;        4-DEC-2002 written
;       23-JAN-2003 imported in rapp_idl, cleaned up
;       04-MAR-2003 added dontlower,centroid,angle keywords
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;-

FUNCTION mapcenterfit,map,onlypositive=onlypositive,ell=ell,maxfrac=maxfrac,mpfit=mpfit,dontlower=dontlower,centroid=centroid,angle=angle


;
;select range of pixel to use for computation of centroid
;

data=map.data

IF keyword_set(onlypositive) THEN  maxfrac=0.

;data=map.data > 0 $
;ELSE  data=map.data


;dontlower....

IF exist(maxfrac) THEN BEGIN
    IF keyword_set(dontlower) THEN BEGIN
        wh=where(data LT maxfrac*max(data))
        data[wh]=0
    ENDIF ELSE $
    data=(data-maxfrac*max(data)) > 0
ENDIF


;dim=size(data)

; find centrum in pixel units
IF keyword_set(centroid) THEN BEGIN
    cenn=centroid(data)
    c=fltarr(6)
    c[4:5]=cenn
ENDIF $
ELSE $
   IF keyword_set(mpfit) THEN $
      ell=mpfit2dpeak(data,c,/tilt) $
   ELSE $
      ell=gauss2dfit(data,c,/tilt) 

IF arg_present(angle) THEN angle=c[6]

;convert pixel units to solar coordinates
cent=fltarr(2)
cent=map_pix2coor([c[4],c[5]],map)
;cent[0]=map.xc+map.dx*(c[4]-dim[1]/2.+0.5)
;cent[1]=map.yc+map.dy*(c[5]-dim[2]/2.+0.5)

RETURN,cent

END

