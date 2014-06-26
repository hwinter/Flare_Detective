;+
;
; NAME:
;        pg_loop_plot
;
; PURPOSE: 
;
;        overplots a 3D circular loop as a projection over a solar map
;
; CALLING SEQUENCE:
;
;        pg_loop_plot,p1,p2
;    
; 
; INPUTS:
;
;        p1,p2: each is an array with the x and y coordinates of 1
;               footpoint. The coordinates are in arcseconds from the
;               solar center following the convention used in plot_map
;        sunradius: optional sunaradius in arcsec. Default 960.
;        imtime: if set, computes the sun radius for the given time
;        +all keyword accepted by oplot
;
; KEYWORDS:
;        
;                
; OUTPUT:
;        none
;
; CALLS:
;        
;
; EXAMPLE:
; 
;       
; 
; VERSION:
;       
;       24-AUG-2005 written pg
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;       pgrigis@astro.phys.ethz.ch
;-

PRO pg_loop_plot,p1=p1,p2=p2,sunradius=sunradius,imtime=imtime,npoints=npoints,_extra=_extra

sunradius=fcheck(sunradius,960.);solar radius
npoints=fcheck(npoints,128);number of points to draw for the loop

IF keyword_set(imtime) THEN BEGIN 
   t=anytim(imtime,/ex)
   sun,t[6],t[5],t[4],t[0]+t[1]/60.,sd=sunradius
ENDIF

x1=p1[0]
x2=p2[0]
y1=p1[1]
y2=p2[1]

IF ((x1^2+y1^2) GT sunradius*sunradius) OR $
   ((x2^2+y2^2) GT sunradius*sunradius) THEN BEGIN 
      print,'Please make sure that both points lie inside the surface of the sun!'
      print,'No loop plotted'
      RETURN
ENDIF
 

;computes the z coordinates of the two points
z1=sqrt(sunradius^2-x1^2-y1^2)
z2=sqrt(sunradius^2-x2^2-y2^2)

;average postions
xav=0.5*(x1+x2)
yav=0.5*(y1+y2)
zav=sqrt(sunradius^2-xav^2-yav^2);this point lie on the surface of the sphere

;vector normal to the tangential plane
v=[xav,yav,zav]/sunradius

dx=0.5*sqrt((x2-x1)^2+(y2-y1)^2+(z2-z1)^2)
;half distance between the two points
;<-> radius of the loop (circle)

vx=v*dx

t=findgen(npoints)/(npoints-1)*!PI

pm=transpose([0.5*(x2+x1),0.5*(y2+y1),0.5*(z1-z2)]);center of the loop
v1=transpose(0.5*[(x2-x1),(y2-y1),(z2-z1)]);vector from one point to the center
v2=transpose(vx);vector normal to the surface

cpos=v1##cos(t)+v2##sin(t)+pm##replicate(1.,npoints);points lying on the circle


;overplots the loop
oplot,cpos[*,0],cpos[*,1],_extra=_extra

END












