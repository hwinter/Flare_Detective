;+
; NAME:
;
; pg_rotate3dvec
;
; PURPOSE:
;
; performs a rotation in 3d space of a vector (a,b,c). The rotation is specified
; as 3 angle of rotation around x,y,z. The rotations are performed in the
; following order: first around z, then around y, then around x by the specifed angles.
;
; CATEGORY:
;
; geometry
;
; CALLING SEQUENCE:
;
; rotvec=pg_rotate3dvec(Vector,Xangle=Xangle,Yangle=Yangle,Zangle=Zangle $
;                      ,Xrotation=Xrotation,Yrotation=Yrotation,Zrotation=Zrotation $
;                      ,RotationMatrix=RotationMatrix)
;
; INPUTS:
;
; Vector: 3D vector to be rotated
; Xangle:angle of the rotation around the X axis (default 0)
; Yangle:angle of the rotation around the Y axis (default 0)
; Zangle:angle of the rotation around the Z axis (default 0)
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
; rotvec: Rotated Vector
;
; OPTIONAL OUTPUTS:
;
; Xrotation: the X rotation matrix
; Yrotation: the Y rotation matrix
; Zrotation: the Z rotation matrix
; RotationMatrix: the total rotation matrix
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
; ninety=!Pi/2
; rotvec=pg_rotate3dvec([0,1,0],Xangle=ninety,Yangle=ninety,Zangle=ninety)
;
; AUTHOR
;
; Paolo Grigis
; pgrigis@cfa.harvard.edu
;
; MODIFICATION HISTORY:
;
; 31-DEC-2009 written (happy 2010!)
;
;-

FUNCTION pg_rotate3dvec,Vector,Xangle=Xangle,Yangle=Yangle,Zangle=Zangle $
                       ,Xrotation=Xrotation,Yrotation=Yrotation,Zrotation=Zrotation $
                       ,RotationMatrix=RotationMatrix


Xangle=fcheck(Xangle,0.0)
Yangle=fcheck(Yangle,0.0)
Zangle=fcheck(Zangle,0.0)

Xcos=cos(Xangle)
Xsin=sin(Xangle)
Xrotation=[[1.0,0,0],[0,Xcos,-Xsin],[0,Xsin,Xcos]]

Ycos=cos(Yangle)
Ysin=sin(Yangle)
Yrotation=[[Ycos,0,Ysin],[0,1,0],[-Ysin,0,Ycos]]

Zcos=cos(Zangle)
Zsin=sin(Zangle)
Zrotation=[[Zcos,-Zsin,0],[Zsin,Zcos,0],[0,0,1]]

RotatedVector=Xrotation##YRotation##ZRotation##Vector

return, RotatedVector

END

