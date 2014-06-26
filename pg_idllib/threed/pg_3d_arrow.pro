;+
; NAME:
;
; pg_3d_arrow
;
; PURPOSE:
;
; construct an arrow surface
;
; CATEGORY:
;
; 3d utils
;
; CALLING SEQUENCE:
;
; pg_3d_arrow,startp,endp,perpv,r1=r1,r2=r2,headratio=headratio,xx=xx,yy=yy,zz=zz
;
; INPUTS:
;
; startp: 3d array with x,y,z of the starting point
; endp: 3d array with x,y,z of the ending point
; perpv: vector with main direction for body (if flattened)
;
; OPTIONAL INPUTS:
; 
;
;
; KEYWORD PARAMETERS:
;
;
;
; OUTPUTS:
;
; XX,YY,ZZ: array with the coordinates of the arrow surface vertices
;
; OPTIONAL OUTPUTS:
;
;
;
; COMMON BLOCKS:
;
;
;
; SIDE EFFECTS:
;
;
;
; RESTRICTIONS:
;
;
;
; PROCEDURE:
;
;
;
; EXAMPLE:
;
;
;
; MODIFICATION HISTORY:
;
; 25-JAN-2007 written Paolo Grigis 
; (pgrigis@astro.phys.ethz.ch)
;
;-

;.comp pg_3d_arrow

PRO pg_3d_arrow_test

nb=10
nr=32
nh=20

ra=1d-2
rb=4d-2
ra2=0.5*ra
rb2=0.5*rb

pow=0.8

col1=[255B,72,72]
col2=[0B,0,230]


startp=[0.2,0.8,0]
endp=[0.7,0.5,0]
perpv=[0,0,1]

pg_3d_arrow,startp,endp,perpv,xx=xx,yy=yy,zz=zz,ra=ra,rb=rb $
               ,nb=nb,nr=nr,nh=nh,pow=pow

startp=[0.7,0.5,0.2]
endp=[0.2,0.2,0.2]
perpv=[0,0,1]

pg_3d_arrow,startp,endp,perpv,xx=xx2,yy=yy2,zz=zz2,ra=ra2,rb=rb2 $
               ,nb=nb,nr=nr,nh=nh,pow=pow


;startp=[0.,0.,0]
;endp=[1,1,0]
;perpv=[1.,-1,0]
;pg_3d_arrow,startp,endp,perpv,xx=xx,yy=yy,zz=zz

isurface,zz,xx,yy,/isotropic,shading=1,style=2,/hidden_lines $
        ,xmajor=0,ymajor=0,zmajor=0,xminor=0,yminor=0,zminor=0 $
        ,identifier=id,xrange=[0,1],yrange=[0,1],zrange=[-0.2,0.6],color=col2

isurface,zz2,xx2,yy2,/isotropic,shading=1,style=2,/hidden_lines,overplot=id,color=col1 ;$
;        ,xmajor=0,ymajor=0,zmajor=0,xminor=0,yminor=0,zminor=0 $
;        ,identifier=id,xrange=[0,1],yrange=[0,1],zrange=[-1,1]

startp=[0.2,0.8,0]
endp=[0.7,0.5,0]
perpv=[0,0,1]

pg_3d_arrow,startp,endp,perpv,xx=xx,yy=yy,zz=zz,ra=ra,rb=rb $
               ,nb=nb,nr=nr,nh=nh,pow=pow


startp=[0.7,0.5,0.2]
endp=[0.2,0.8,0.2]
perpv=[0,0,1]

pg_3d_arrow,startp,endp,perpv,xx=xx2,yy=yy2,zz=zz2,ra=ra2,rb=rb2 $
               ,nb=nb,nr=nr,nh=nh,pow=pow


;startp=[0.,0.,0]
;endp=[1,1,0]
;perpv=[1.,-1,0]
;pg_3d_arrow,startp,endp,perpv,xx=xx,yy=yy,zz=zz

isurface,zz,xx,yy,/isotropic,shading=1,style=2,/hidden_lines $
        ,xmajor=0,ymajor=0,zmajor=0,xminor=0,yminor=0,zminor=0 $
        ,identifier=id,xrange=[0,1],yrange=[0,1],zrange=[-0.2,0.6],color=col2

isurface,zz2,xx2,yy2,/isotropic,shading=1,style=2,/hidden_lines,overplot=id,color=col1 ;$
;        ,xmajor=0,ymajor=0,zmajor=0,xminor=0,yminor=0,zminor=0 $
;        ,identifier=id,xrange=[0,1],yrange=[0,1],zrange=[-1,1]



startp=[0.2,0.8,0]
endp=[0.7,0.5,0]
perpv=[0,0,1]

pg_3d_arrow,startp,endp,perpv,xx=xx,yy=yy,zz=zz,ra=ra,rb=rb $
               ,nb=nb,nr=nr,nh=nh,pow=pow


startp=[0.7,0.5,0.2]
d=sqrt(0.5^2+0.3^2)
alpha=!PI*0.92
endp=startp
endp[0]+=d*cos(alpha)
endp[1]+=d*sin(alpha)
perpv=[0,0,1]

pg_3d_arrow,startp,endp,perpv,xx=xx2,yy=yy2,zz=zz2,ra=ra2,rb=rb2 $
               ,nb=nb,nr=nr,nh=nh,pow=pow


;startp=[0.,0.,0]
;endp=[1,1,0]
;perpv=[1.,-1,0]
;pg_3d_arrow,startp,endp,perpv,xx=xx,yy=yy,zz=zz

isurface,zz,xx,yy,/isotropic,shading=1,style=2,/hidden_lines $
        ,xmajor=0,ymajor=0,zmajor=0,xminor=0,yminor=0,zminor=0 $
        ,identifier=id,xrange=[0,1],yrange=[0,1],zrange=[-0.2,0.6],color=col2

isurface,zz2,xx2,yy2,/isotropic,shading=1,style=2,/hidden_lines,overplot=id,color=col1 ;$

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

mysurf = OBJ_NEW('IDLgrSurface',zz,xx,yy)
mysurf->setproperty,color=[255B,0,0],style=2,shading=1,hidden_lines=1;,gouraud=1
mysurf2 = OBJ_NEW('IDLgrSurface',zz2,xx2,yy2)
mysurf2->setproperty,color=[0,255B,0],style=2,shading=1,hidden_lines=1;,gouraud=1


oWindow = OBJ_NEW('IDLgrWindow')  
;oWindow->SetProperty,retain=2
;oWindow->getProperty,retain=test

; Create a viewport; 
oView = OBJ_NEW('IDLgrView')  

oView->SetProperty, LOCATION=[0.,0.], DIMENSIONS=[1,1] $
                  ,color=[240,240,240],units=3 $
                  ,viewplane_rect=[0, 0,1,1] 

;oWindow->Draw, oView  


oModel = OBJ_NEW('IDLgrModel')  
oView->Add, oModel  
; Create a text object and add it to the model:  


oModel->Add, mysurf
oModel->Add, mysurf2

oWindow->Draw, oView  




END


PRO pg_3d_arrow,startp,endp,vperp,xx=xx,yy=yy,zz=zz,ra=ra,rb=rb,pow=pow $
               ,nb=nb,nr=nr,nh=nh

n=fcheck(nb,200)
nr=fcheck(nr,64)
nh=fcheck(nh,100)

headratio=0.25

t=findgen(n+1)/(n-1)*(1-headratio)
t2=findgen(nr)/(nr-1)*!Pi*2
t3=(1-headratio)+findgen(nh)/(nh-1)*headratio


dp=endp-startp

x=startp[0]+dp[0]*t
y=startp[1]+dp[1]*t
z=startp[2]+dp[2]*t

xx=fltarr(n+nh,nr)
yy=fltarr(n+nh,nr)
zz=fltarr(n+nh,nr)

Ra=fcheck(ra,0.02)
Rb=fcheck(rb,0.002)

p=fcheck(pow,0.5)

v2=vperp/sqrt(total(vperp^2))
v3=v2*0

;compute body

FOR i=0,n-1 DO BEGIN 

;   ;direction vector
   v1=[x[i+1]-x[i],y[i+1]-y[i],z[i+1]-z[i]]
   v1=v1/sqrt(total(v1*v1))

   v3=pg_vector_prod(v1,v2)
   v3=v3/sqrt(total(v3*v3))

   rra=ra*cos(t2)
   rrb=rb*sin(t2)

   xx[i,*]=x[i]+(pg_getsign(rra)*abs(rra)^p)*v2[0]+(pg_getsign(rrb)*abs(rrb)^p)*v3[0]
   yy[i,*]=y[i]+(pg_getsign(rra)*abs(rra)^p)*v2[1]+(pg_getsign(rrb)*abs(rrb)^p)*v3[1]
   zz[i,*]=z[i]+(pg_getsign(rra)*abs(rra)^p)*v2[2]+(pg_getsign(rrb)*abs(rrb)^p)*v3[2]


ENDFOR
;end

;compute head

v1=[x[n]-x[n-1],y[n]-y[n-1],z[n]-z[n-1]]
v1=v1/sqrt(total(v1*v1))
v3=pg_vector_prod(v1,v2)
v3=v3/sqrt(total(v3*v3))

x=startp[0]+dp[0]*t3
y=startp[1]+dp[1]*t3
z=startp[2]+dp[2]*t3

;length 
L=1.4

;xx=fltarr(nh,nr)
;yy=fltarr(nh,nr)
;zz=fltarr(nh,nr)

;.run
FOR i=0,nh-1 DO BEGIN 
   f=1. - i/(nh-1.)
   rra=ra*cos(t2)
   rrb=rb*sin(t2)

   xx[i+n,*]=x[i]+l*f*((pg_getsign(rra)*abs(rra)^p)*v2[0]+(pg_getsign(rrb)*abs(rrb)^p)*v3[0])
   yy[i+n,*]=y[i]+l*f*((pg_getsign(rra)*abs(rra)^p)*v2[1]+(pg_getsign(rrb)*abs(rrb)^p)*v3[1])
   zz[i+n,*]=z[i]+l*f*((pg_getsign(rra)*abs(rra)^p)*v2[2]+(pg_getsign(rrb)*abs(rrb)^p)*v3[2])
 
  
ENDFOR
;end



END

