; by Pascal Saint-Hilaire, 2003/05/24
;	shilaire@astro.phys.ethz.ch
;
; same principle as max2d.pro, but for a tesseract
;	

FUNCTION max4d,inarr,minimum=minimum,value=value

S=size(inarr)
IF KEYWORD_SET(minimum) THEN value=min(inarr,i) ELSE value=max(inarr,i)
it=i/(S[3]*S[2]*S[1])
iz=(i-it*S[3]*S[2]*S[1])/(S[2]*S[1])
iy=(i-it*S[3]*S[2]*S[1]-iz*S[2]*S[1])/S[1]
ix=i-it*S[3]*S[2]*S[1]-iz*S[2]*S[1]-iy*S[1]
RETURN,[ix,iy,iz,it]
END
