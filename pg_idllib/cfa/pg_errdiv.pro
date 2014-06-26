;
;this routin computes the uncertainty in x/y, given uncertainties dx,dy
;

FUNCTION pg_errdiv,x,y,dx=dx,dy=dy,q=q

q=x/y

return,q*sqrt( (dx/x)^2+(dy/y)^2)

END

