;+
; NAME:
;
; pg_3drotate
;
; PURPOSE:
;
; rotate a set of points in 3d space with respect to an arbitrary axis
;
; CATEGORY:
;
; geometry util
;
; CALLING SEQUENCE:
;
; pg_3drotate,x,y,z,angle=angle,rotaxis=rotaxis,axisoffset=axisoffset,
;             outx=outx,outy=outy,outz=outz
;
; INPUTS:
;
; x,y,z: 3 array with the same number of elements with the coordinates
;        of the points to rotate
; rotaxis: a vector representing the axis of rotation
; axisoffset: used to describe an axis not going through the origin
;             defaults to [0,0,0]
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
; outx,outy,outz: coordinates of the rotated points
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
; Paolo Grigis, CfA
; pgrgis@cfa.harvard.edu
;
; MODIFICATION HISTORY:
;
; 04-OCT-2007 written PG
; 
;-

PRO pg_3drotate,x,y,z,angle=angle,rotaxis=rotaxis,axisoffset=axisoffset $
               ,outx=outx,outy=outy,outz=outz


  u=fcheck(rotaxis,[0.,0.,1.])
  du=fcheck(axisoffset,[0.,0,0])
  angle=-fcheck(angle,!Pi/2)

  id3=[[1.,0,0],[0,1,0],[0,0,1]]


  ;rotation matrix
  r=[[0,-u[2],u[1]],[u[2],0,-u[0]],[-u[1],u[0],0]]*sin(angle)+$
  (id3-u#u)*cos(angle)+u#u


  IF total(abs(du)) GT 0 THEN BEGIN 

     outx=r[0,0]*(x-du[0])+r[0,1]*(y-du[1])+r[0,2]*(z-du[2])+du[0]
     outy=r[1,0]*(x-du[0])+r[1,1]*(y-du[1])+r[1,2]*(z-du[2])+du[1]
     outz=r[2,0]*(x-du[0])+r[2,1]*(y-du[1])+r[2,2]*(z-du[2])+du[2]

  ENDIF ELSE BEGIN 

     outx=r[0,0]*x+r[0,1]*y+r[0,2]*z
     outy=r[1,0]*x+r[1,1]*y+r[1,2]*z
     outz=r[2,0]*x+r[2,1]*y+r[2,2]*z

  ENDELSE

END


