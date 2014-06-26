pro myct2,nb=nb
;nb is actually the number of color indices available.
if not exist(nb) then nb=!D.TABLE_SIZE

loadct,1,ncolors=nb-6
tvlct,r,g,b,/get
r(nb-6)=255
r(nb-5)=255
r(nb-4)=255
r(nb-3)=0
r(nb-2)=255
r(nb-1)=255
g(nb-6)=0
g(nb-5)=90
g(nb-4)=255
g(nb-3)=255
g(nb-2)=0
g(nb-1)=255
b(nb-6)=0
b(nb-5)=9
b(nb-4)=0
b(nb-3)=0
b(nb-2)=255
b(nb-1)=255
tvlct,r,g,b
print,' Now using the modified BLUE/WHITE color table of PSH... '
end
