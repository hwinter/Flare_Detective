;+
; NAME:
;
; pg_plotsphericalgrid
;
; PURPOSE:
;
; Plots a spherical grid in an x,y direct graphic plot (optionally overplots).
; The sphere is rotated from the null position (Centered on [e1,e2,e3]=[0,0,0],
; North pole in the 3-direction, central meridian in the 1,3-plane) by performing
; the following operations: 
; - first, rotate by angle B around 1-axis 
; - second, rotate by angle P around 3-axis
; - third rotate by angle L around the sphere axis
; The equator and central meridian are plotted with increased thickness.
; 
; CATEGORY:
;
; spherical geometry
;
; CALLING SEQUENCE:
;
; pg_plotsphericalgrid,LatitudeSpacing=LatitudeSpacing,LongitudeSpacing=LongitudeSpacing $
;                     ,Bangle=Bangle,Pangle=Pangle,Langle=Langle, Radius=Radius
;                     ,NPoints=Npoints
;
;
; INPUTS:
;
; LongitudeSpacing: spacing in degrees of longitude grid (default 15)
; Latitude: spacing in degrees of latitude grid (default 15)
;
; Bangle: rotation around 1-axis (see above). Defaults to 0. All angles are in degrees.
; Pangle: rotation around 3-axis (see above). Defaults to 0. All angles are in degrees.
; Langle: rotation around sphere axis (see above). Defaults to 0. All angles are in degrees.
;
;
; OPTIONAL INPUTS:
;
; Radius: the sphere's radius - defaults to 1.
; Npoints: number of points in each longitude or latitude circle (defaults to 256)
; LimbDraw: if set, draws the sphere's limb
; Hole: if set, leaves an ungridded hole near the north pole (looks better)
; Color: grid colos
; LimbColor: limb color
; LimbThick: limb thickness
;
; NONE
;
; KEYWORD PARAMETERS:
;
; Overplot: if set, overplots grid on a pre-existing plot
;
; OUTPUTS:
;
; NONE
;
; OPTIONAL OUTPUTS:
;
; NONE
;
; COMMON BLOCKS:
; 
; NONE
;
; SIDE EFFECTS:
;
; NONE
;
; RESTRICTIONS:
;
;
; PROCEDURE:
;
; Uses pg_3dsphericalconvert to convert from a (long,lat)-grid to x,y coordinates.
;
; EXAMPLE:
;
; 
; AUTHOR:
;
; Paolo Grigis
; pgrigis@cfa.harvard.edu
;
; MODIFICATION HISTORY:
;
; 04-JAN-2010 written PG
;
;-


PRO  pg_plotsphericalgrid,LatitudeSpacing=LatitudeSpacing,LongitudeSpacing=LongitudeSpacing $
                         ,Bangle=Bangle,Pangle=Pangle,Langle=Langle, Radius=Radius $
                         ,NPoints=Npoints,Overplot=Overplot,LimbDraw=LimbDraw,hole=hole,color=color $
                         ,LimbColor=LimbColor,LimbThick=LimbThick,EquatorThick=EquatorThick,CentralMeridianThick=CentralMeridianThick $
                         ,_extra=_extra


Npoints=fcheck(Npoints,256)

LatitudeSpacingIn  =float(fcheck(LatitudeSpacing,15.0))
LongitudeSpacingIn =float(fcheck(LongitudeSpacing,LatitudeSpacingIn))
BangleIn    =fcheck(Bangle,0.0)
PangleIn    =fcheck(Pangle,0.0)
LangleIn    =fcheck(Langle,0.0)
RadiusIn    =fcheck(Radius,1.0)

ColorIn=fcheck(Color,!P.color)
LimbColorIn=fcheck(LimbColor,ColorIn)
EquatorThickIn=fcheck(EquatorThick,2.0)
CentralMeridianThickIn=fcheck(CentralMeridianThick,2.0)


;print,pangle

nan=!values.f_nan

IF NOT keyword_set(Overplot) THEN plot,[0,0],/nodata,xrange=sqrt(2.0)*RadiusIn*[-1,1],yrange=sqrt(2.0)*RadiusIn*[-1,1],/iso,_extra=_extra

nlat=ceil((90.0/LatitudeSpacingIn))
nlong=ceil((180.0/LongitudeSpacingIn))

lon=(findgen(Npoints)/(Npoints-1)*360-180)
FOR j=-nlat,nlat DO BEGIN 
   lat=replicate(j*LatitudeSpacingIn,Npoints)
   IF keyword_set(hole) THEN lat=lat>(-80)<80
   ;pritn,nlat,lat[0]

   pg_3dsphericalconvert,Latitude=lat,Longitude=lon,Bangle=Bangle,Pangle=Pangle,Langle=Langle,visible=visible,Xcoor=x,Ycoor=y,Radius=RadiusIn
   
   ind=where(visible EQ 0,count) ;& count=0
   IF count GT 0 THEN  BEGIN 
      x[ind]=nan
      y[ind]=nan
   ENDIF 

   oplot,x,y,color=ColorIn
   IF j EQ 0 THEN BEGIN 
      oplot,x,y,color=ColorIn,thick=EquatorThickIn
   ENDIF 
ENDFOR


IF keyword_set(hole) THEN BEGIN 
   lat=(findgen(Npoints)/(Npoints-1)*160-80)
ENDIF $
ELSE BEGIN 
   lat=(findgen(Npoints)/(Npoints-1)*180-90)
ENDELSE 

FOR j=-nlong,nlong DO BEGIN 
   lon=replicate(j*LongitudeSpacingIn,Npoints)

   ;pritn,nlong,lon[0]

  
   pg_3dsphericalconvert,Latitude=lat,Longitude=lon,Bangle=Bangle,Pangle=Pangle,Langle=Langle,visible=visible,Xcoor=x,Ycoor=y,Radius=RadiusIn
   
   ind=where(visible EQ 0,count) ;& count=0
   IF count GT 0 THEN  BEGIN 
      x[ind]=nan
      y[ind]=nan
   ENDIF 

   oplot,x,y,color=ColorIn
   IF j EQ 0 THEN BEGIN 
      ;stop
      oplot,x,y,color=ColorIn,thick=CentralMeridianThickIn
   ENDIF 
ENDFOR

IF keyword_set(LimbDraw) THEN BEGIN 
   t=findgen(Npoints)/(Npoints-1)*2*!Pi
   x=RadiusIn*cos(t)
   y=RadiusIn*sin(t)
   oplot,x,y,color=LimbColorIn,thick=LimbThick
ENDIF



RETURN

END

