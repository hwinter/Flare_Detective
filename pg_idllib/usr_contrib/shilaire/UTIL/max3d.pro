; by Pascal Saint-Hilaire, March 19th,2001
;	shilaire@astro.phys.ethz.ch OR psainth@hotmail.com
;
; max3.pro returns location of the maximum of input 3D-array
;	functions under the same principles as max2d.pro - look it up for documentation.
;

FUNCTION max3d,inarr,minimum=minimum,value=value

S=size(inarr)
IF KEYWORD_SET(minimum) THEN value=min(inarr,i) ELSE value=max(inarr,i)
iz=i/(S[2]*S[1])
iy=(i-iz*S[2]*S[1])/S[1]
ix=i-iz*S[2]*S[1]-iy*S[1]
RETURN,[ix,iy,iz]
END
