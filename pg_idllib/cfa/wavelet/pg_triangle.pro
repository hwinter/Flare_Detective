;return a triangular function...

FUNCTION pg_triangle,x,xc=xc,width=width

xc=fcheck(xc,0d)
b=fcheck(width,1)

thx=abs((x-xc)/b)

ind1=where(thx LE 1d,count1)
;; ind2=where(thx GT 1d AND thx LE 2d,count2)

res=x*0d
IF count1 GT 0 THEN res[ind1]=1/b*(1-thx[ind1])
;; IF count2 GT 0 THEN res[ind2]=(-0.5d +0.25d*thx[ind2])*1.5/b

return,res

END


