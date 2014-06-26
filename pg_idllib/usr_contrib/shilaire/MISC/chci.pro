; written 2001/07/20 Pascal Saint-Hilaire
;		psainth@hotmail.com
;		shilaire@astro.phys.ethz.ch

; PURPOSE: quickly change one color index to a certain r,g,b value


PRO chci,index,newr,newg,newb
tvlct,r,g,b,/get
r(index)=newr
g(index)=newg
b(index)=newb
tvlct,r,g,b
END
