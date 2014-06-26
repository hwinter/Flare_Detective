;
; PSH 2002/03/11
;
;
;	EXAMPLE:
;		IDL> newcube=interpolate_cube(oldcube)
;


FUNCTION interpolate_cube,incube

oldcube=FLOAT(incube)
S=size(oldcube)
oldnb=S[3]

newnb=2*oldnb
newcube=FLTARR(S[1],S[2],2*oldnb)

newcube(*,*,0)=oldcube(*,*,0)
FOR i=0,oldnb-2 DO BEGIN
	newcube(*,*,2*i)=oldcube(*,*,i)
	newcube(*,*,2*i+1)=(oldcube(*,*,i)+oldcube(*,*,i+1))/2.
ENDFOR
newcube(*,*,newnb-1)=oldcube(*,*,oldnb-1)

RETURN,newcube
END
