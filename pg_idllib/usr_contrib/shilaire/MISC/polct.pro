; PSH,	2001/10/22
;	psainth@hotmail.com OR shilaire@astro.phys.ethz.ch
;
; RESTRICTION:
;	Assumes a 256-color map is being used...
;

PRO polct

r=BYTARR(256)
g=BYTARR(256)
b=BYTARR(256)

FOR i=1,63 DO BEGIN
	r(i)=0
	g(i)=255-4*i
	b(i)=255
ENDFOR 

FOR i=64,127 DO BEGIN
	r(i)=0
	g(i)=4*(i-64)
	b(i)=255-4*(i-64)
ENDFOR 

FOR i=128,191 DO BEGIN
	r(i)=4*(i-128)
	g(i)=255-4*(i-128)
	b(i)=0
ENDFOR 

FOR i=192,254 DO BEGIN
	r(i)=255
	g(i)=4*(i-192)
	b(i)=0
ENDFOR 

r(0)=0
r(255)=255
g(0)=0
g(255)=255
b(0)=0
b(255)=255

TVLCT,r,g,b
print,"........ PSH's polarization color table loaded"
END
