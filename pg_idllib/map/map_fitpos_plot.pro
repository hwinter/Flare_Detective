;+
;
; NAME:
;        map_fitpos_plot
;
; PURPOSE: 
;        overplot to an existing map a position and the axis of an ellipse
;        fitted to that position
;
; CALLING SEQUENCE:
;
;        map_fitpos_plot,x,y,map=map,angle=angle,psym=psym,linestyle=linestyle
; 
;
; INPUTS:
;        map: the map which is being overplotted, only needed if angle
;             is set
;        x,y: (data) coordinates of center
;        angle: inclination angle of the axis (optional)        
;        psym,linestyle: style for the point and the lines
;
; KEYWORDS:
;        
;                
; OUTPUT:
;               
; CALLS:
;
; VERSION:
;       
;        21-MAR-2003 written
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;-

PRO map_fitpos_plot,x,y,map=map,angle=a,psym=psym,linestyle=linestyle

IF n_elements(psym) EQ 0 THEN psym=4

oplot,[x],[y],psym=psym

IF n_elements(a) NE 0 THEN BEGIN

    IF n_elements(map) EQ 0 THEN $

        RETURN $

    ELSE BEGIN

        angle=-a;-0.5*!Pi

        IF n_elements(linestyle) EQ 0 THEN linestyle=1

;         IF (angle EQ 0.5*!PI) OR (angle EQ 0.) THEN BEGIN

;             xmin=x
;             xmax=x
;             ymin=map.yc+map.dy*(size(map.data))[2]
;             ymax=map.yc+map.dy*(size(map.data))[2]
;             oplot,[xmin,xmax],[ymin,ymax],linestyle=linestyle
;             xmin=map.xc-map.dx*(size(map.data))[1]
;             xmax=map.xc+map.dx*(size(map.data))[1]
;             ymin=y
;             ymax=y
;             oplot,[xmin,xmax],[ymin,ymax],linestyle=linestyle

;         ENDIF ELSE BEGIN

            print,'angle :'+string(angle)

            xmin=map.xc-map.dx*(size(map.data))[1]
            xmax=map.xc+map.dx*(size(map.data))[1]
            ymin=y-(x-xmin)*tan(angle)
            ymax=y-(x-xmax)*tan(angle)
            oplot,[xmin,xmax],[ymin,ymax],linestyle=linestyle
            angle=angle+0.5*!PI
            xmin=map.xc-map.dx*(size(map.data))[1]
            xmax=map.xc+map.dx*(size(map.data))[1]
            ymin=y-(x-xmin)*tan(angle)
            ymax=y-(x-xmax)*tan(angle)
            oplot,[xmin,xmax],[ymin,ymax],linestyle=linestyle

;        ENDELSE
        
    ENDELSE

ENDIF

END









