; by Pascal Saint-Hilaire, March 19th,2001
;	shilaire@astro.phys.ethz.ch OR psainth@hotmail.com
;
; max2d.pro returns location of the maximum of input 2D-array, 
;		and optionnaly returns the maximum value
;
;OPTIONAL KEYWORDS:
; 	*  value = value of the maximum (or minimum, if /minimum keyword is also used)
;	* /minimum : looks for minimum instead of maximum.
;
;EXAMPLE : print,max2d(a)	OR
;			print,max2d(a,/min,value=value) & print,value
;


FUNCTION max2d,inarr,value=value,minimum=minimum

S=size(inarr)
IF KEYWORD_SET(minimum) THEN value=min(inarr,i) ELSE value=max(inarr,i)
ix= i MOD S[1]
iy= i/S[1]
return,[ix,iy]
end
