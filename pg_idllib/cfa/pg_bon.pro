;
;returns a two dimensional bed-of-nails function
;


FUNCTION pg_bon,x,y,epsilon=epsilon

epsilon=fcheck(epsilon,1e-6)

ind=where( abs(x MOD 1) LT epsilon AND abs(y MOD 1) LT epsilon)

z=x*0
z[ind]=1

return , z

END
 

