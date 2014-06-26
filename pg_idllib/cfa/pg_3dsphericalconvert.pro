;+
; NAME:
;
; pg_3dsphericalconvert
;
; PURPOSE:
;
; Convert coordinates on a sphere (Longitude, Latitude) in 2 dimensional
; (x,y) plane coordinates as would appear from an observer far away from
; the sphere.
; The sphere is rotated from the null position (Centered on [e1,e2,e3]=[0,0,0],
; North pole in the 3-direction, central meridian in the 1,3-plane) by performing
; the following operations: 
; - first, rotate by angle B around 1-axis 
; - second, rotate by angle P around 3-axis
; - third rotate by angle L around the sphere axis
;
; The projected coordinates are in a plan x,y where x is parallel to the 2
; direction, and y is parallel to the 3 direction (i.e. north pole before
; rotation). They are taken as the (2,3) component of the vectors corresponding
; to the coordinates on the sphere, after appllying the 3 rotations.
;
; CATEGORY:
;
; spherical geometry
;
; CALLING SEQUENCE:
;
; pg_3dsphericalconvert,Latitude=Latitude,Longitude=Longitude $
;                      ,Xcoord=Xcoord,Ycoord=Ycoord $
;                      ,Bangle=Bangle,Pangle=Pangle,Langle=Langle $
;                      ,Visible=Visible
;
; INPUTS:
;
; Longitude: 1 or more elements array with Longitude (from -180 to +180, 0 at
;           central meridian). All angles are in degrees.
; Latitude: 1 or more elements array with Latitude (from -90 (south pole) 
;           +90 (north pole). Must have the same number of elements as Longitude.
;           All angles are in degrees.
;
; Bangle: rotation around 1-axis (see above). Defaults to 0. All angles are in degrees.
; Pangle: rotation around 3-axis (see above). Defaults to 0. All angles are in degrees.
; Langle: rotation around sphere axis (see above). Defaults to 0. All angles are in degrees.
;
;
; OPTIONAL INPUTS:
;
; Radius: the sphere's radius - defaults to 1.
;
; NONE
;
; KEYWORD PARAMETERS:
;
; NONE
;
; OUTPUTS:
;
; Xccord,Ycoord: arrays of projected coordinates (contains same number of
; elements as latitude, longitude)
;
; OPTIONAL OUTPUTS:
;
; Visible: array of 0s and 1s. If 1, the coordinates correponding to that index
;          are in front of the sphere as seen by the observer, if 0 on the backside
;
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
; Latiutude & Longitude must have the same number of elements.
;
; PROCEDURE:
;
; Geometrically rotates vectors and take projections.
; I computed the formula manually - but I am sure you
; can find it in some book.
;
; EXAMPLE:
;
; lat=50.0
; lon=30.0
; pg_3dsphericalconvert,Latitude=lat,Longitude=lon,Bangle=25.0,Pangle=25.0,Langle=25.0,Xcoor=x,Ycoor=y
; print,x,y
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


PRO pg_3dsphericalconvert,Latitude=Latitude,Longitude=Longitude $
                         ,Xcoord=Xcoord,Ycoord=Ycoord, Radius=Radius $
                         ,Bangle=Bangle,Pangle=Pangle,Langle=Langle $
                         ,Visible=Visible

LatitudeIn  =fcheck(Latitude,0.0)/180.0*!Pi
LongitudeIn =fcheck(Longitude,0.0)/180.0*!Pi
BangleIn    =fcheck(Bangle,0.0)/180.0*!Pi
PangleIn    =fcheck(Pangle,0.0)/180.0*!Pi
LangleIn    =fcheck(Langle,0.0)/180.0*!Pi
RadiusIn    =fcheck(Radius,1.0)

IF n_elements(Latitude) NE n_elements(Longitude) THEN BEGIN 
   print,'Invalid Input!'
   print,'Call this routine with two vectors Latitude and Longitude with the same'
   print,'number of elements'
   print,'pg_3dsphericalconvert,Latitude=Latitude,Longitude=Longitude $'
   print,'                     ,Bangle=Bangle,Pangle=Pangle'
ENDIF

LongitudeIn =LongitudeIn+LangleIn

;; This is older stuff - left in for future reference if ever needed
;; ;basis vector rotated by B around y and by P around z
;; ex=[cos(Bangle)*cos(Pangle),cos(Bangle)*sin(Pangle),-sin(Bangle)]
;; ey=[-sin(Pangle),cos(Pangle),0]
;; ez=[sin(Bangle)*cos(Pangle),sin(Bangle)*sin(Pangle),cos(Bangle)]
;; ;er=ex*cos(Longitude)*cos(Latitude)+ey*sin(Longitude)*cos(Latitude)+ez*sin(Latitude)
;; ;Xcoord=ex[1]*cos(Longitude)*cos(Latitude)+ey[1]*sin(Longitude)*cos(Latitude)+ez[1]*sin(Latitude)
;; ;Ycoord=ex[2]*cos(Longitude)*cos(Latitude)+ey[2]*sin(Longitude)*cos(Latitude)+ez[2]*sin(Latitude)

Xcoord=cos(BangleIn)*sin(PangleIn)*cos(LongitudeIn)*cos(LatitudeIn)+cos(PangleIn)*sin(LongitudeIn)*cos(LatitudeIn)+sin(BangleIn)*sin(PangleIn)*sin(LatitudeIn)
Ycoord=-sin(BangleIn)*cos(LongitudeIn)*cos(LatitudeIn)+cos(BangleIn)*sin(LatitudeIn)
LOScoord=cos(BangleIn)*cos(PangleIn)*cos(LongitudeIn)*cos(LatitudeIn)-sin(PangleIn)*sin(LongitudeIn)*cos(LatitudeIn)+sin(BangleIn)*cos(PangleIn)*sin(LatitudeIn)

Xcoord*=RadiusIn
Ycoord*=RadiusIn

visible=LOScoord GE 0

RETURN

END

