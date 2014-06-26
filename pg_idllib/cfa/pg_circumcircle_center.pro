;
;find the center of the circumcircle of a triangle given by a,b,c
;

PRO pg_circumcircle_center,a,b,c,cx,cy

ba=b-a
ca=c-a

x11=(ba[0]^2+ba[1]^2)
x21=(ca[0]^2+ca[1]^2)

detdiv=(ba[0]*ca[1]-ca[0]*ba[1])

cx=a[0]+0.5*(x11*ca[1] -x21*ba[1])/detdiv
cy=a[1]+0.5*(-x11*ca[0]+x21*ba[0])/detdiv

END

