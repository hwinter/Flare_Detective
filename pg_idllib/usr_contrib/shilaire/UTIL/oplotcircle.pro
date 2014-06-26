;
;EXAMPLE:
;	oplotcircle,[45,65],25
;

PRO oplotcircle, XYcenter,radius,_extra=_extra

XYcenter=FLOAT(XYcenter)
radius=FLOAT(radius)

angle=findgen(361)
angle=!PI*angle/180.

Xnew=XYcenter(0) + radius
Ynew=XYcenter(1)
FOR i=0,360 DO BEGIN
	Xold=Xnew
	Yold=Ynew
	Xnew=XYcenter(0)+radius*cos(angle[i])
	Ynew=XYcenter(1)+radius*sin(angle[i])
	oplot,[Xold,Xnew],[Yold,Ynew],_extra=_extra
ENDFOR

END
