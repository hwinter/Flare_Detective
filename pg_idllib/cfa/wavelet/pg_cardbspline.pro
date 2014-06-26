;
;returns cardinal B-spline
;


FUNCTION pg_cardbspline,x,m

IF m LE 0 THEN res=x*0;return,x*0

IF m EQ 1 THEN BEGIN 
   ind=where(x GE 0 AND x LT 1,count)
   res=x*0
   IF count GT 0 THEN res[ind]=1
ENDIF $ 
ELSE BEGIN 
   print,m
   y1=pg_cardbspline(x,m-1)
   y2=pg_cardbspline(x-1,m-1)
   res=x/(m-1)*y1+(m-x)/(m-1)*y2
ENDELSE
RETURN,res
END

