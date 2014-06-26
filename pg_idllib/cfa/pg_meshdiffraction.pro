FUNCTION pg_meshdiffraction,xx,yy,w=w,L=L,nomesh=nomesh

L=fcheck(L,sqrt(2.0))
w=fcheck(w,0.1)

print,l,w

x=xx[*,0]
y=yy[0,*]

xmin=min(x)
xmax=max(x)
ymin=min(y)
ymax=max(y)

zz=xx*0

min_xn=round(floor(xmin/L))
max_xn=round(ceil(xmax/L))
min_yn=round(floor(ymin/L))
max_yn=round(ceil(ymax/L))

xindarr=lonarr(max_xn-min_xn+1)
yindarr=lonarr(max_yn-min_yn+1)

FOR i=min_xn,max_xn,1 DO xindarr[i-min_xn]=value_locate(x,i*L)
FOR j=min_yn,max_yn,1 DO yindarr[j-min_yn]=value_locate(y,j*L)

xgood=where(xindarr GE 0,xcount)
ygood=where(xindarr GE 0,ycount)

IF xcount GT 0 AND ycount GT 0 THEN BEGIN 

   xindarr=xindarr[xgood]
   yindarr=xindarr[ygood]
   x=x[xindarr]
   y=y[yindarr]

   FOR i=0,xcount-1 DO BEGIN 
      FOR j=0,ycount-1 DO BEGIN 
         
         zz[xindarr[i],yindarr[j]]=L*L*(w*L*pg_sinc(x[i]*w)*pg_sinc(y[j]*L)+w*L*pg_sinc(x[i]*L)*pg_sinc(y[j]*w)-w*w*pg_sinc(x[i]*w)*pg_sinc(y[j]*w))

      ENDFOR 
   ENDFOR 

ENDIF 

IF keyword_set(nomesh) THEN $
   zz=L*L*(w*L*pg_sinc(xx*w)*pg_sinc(yy*L)+w*L*pg_sinc(xx*L)*pg_sinc(yy*w)-w*w*pg_sinc(xx*w)*pg_sinc(yy*w))

return,zz

;; thisx=x[xindarr]
;; thisy=y[

;; FOR i=min_nx,max_nx,1 DO BEGIN 
;;    FOR j=min_ny,max_ny,1 DO BEGIN 
;;       thisx=x[xind]
;;       this
;;       zz[xind,yind]=L*L*(w*L*pg_sinc(x)*pg_sinc())
;;    ENDFOR 
;; ENDFOR 




END 

