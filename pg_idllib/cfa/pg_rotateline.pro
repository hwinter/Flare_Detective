;+
; NAME:
;
; pg_rotateline
;
; PURPOSE:
;
; rotates a line by an angle
;
; CATEGORY:
;
; geomertical utils
;
; CALLING SEQUENCE:
; 
; pg_rotateline,intercept=intercept,slope=slope,angle=angle,newintercept=newintercept,newslope=newslope
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
;  intercept=0.3
;  slope=0.8
;  angle=0.77
;  pg_rotateline,intercept=intercept,slope=slope,angle=angle,newintercept=newintercept,newslope=newslope
;  
;
;
; MODIFICATION HISTORY:
;
;-

PRO pg_rotateline,intercept=intercept,slope=slope,angle=angle,newintercept=newintercept,newslope=newslope

m=slope
h=intercept
alpha=angle

mr=(m*cos(alpha)+sin(alpha))/(cos(alpha)-m*sin(alpha))
hr=h*(cos(alpha)+mr*sin(alpha))


newslope=mr
newintercept=hr


end

