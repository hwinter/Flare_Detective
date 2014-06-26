;create some test data in polar coordinates (radar view)
;; nr=512
;; nphi=512
;; r=findgen(nr)/(nr-1)
;; phi=findgen(nphi)/(nphi-1)*2*!Pi
;; rr=(phi*0+1)#r
;; pphi=phi#(r*0+1)

;; ray=exp(-(rr-0.5)^2*140-(pphi-2.5)^2*1)
;; tvscl,ray

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; ;conversion polar ->cartesian
;; xx=rr*cos(pphi)
;; yy=rr*sin(pphi)

;; ;interpolation via triangular mesh (as in http://www.dfanning.com/tips/grid_surface.html)
;; Triangulate, xx, yy, triangles, boundaryPts

;; gridSpace = [0.01, 0.01]
;; griddedData = TriGrid(xx, yy, ray, triangles, gridSpace,XGrid=xvector,YGrid=yvector)

;; tvscl,griddedData


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PRO pg_imwarp_test

;create some data in strange coordinates....
nx=16;32;512
ny=16;32;512
xx=randomn(seed,nx,ny)*0.5+0.5
yy=randomn(seed,nx,ny)*0.5+0.5

x=findgen(nx)/(nx-1)*3-1
y=findgen(ny)/(ny-1)*3-1
xx2=x#(y*0+1)
yy2=(x*0+1)#y

;plot,xx,yy,psym=1,/iso

zz=exp(-(xx-0.4)^2*7-(yy-0.6)^2*9)
zz2=exp(-(xx2-0.4)^2*7-(yy2-0.6)^2*9)

im2=pg_imwarp(zz2,xx,yy,xs=-1,xe=2,ys=-1,ye=2,nx=200,ny=200,xxout=xxout,yyout=yyout)

loadct,5
pg_plotimage,im2,xxout,yyout,/iso,xrange=[-0.2,1.2],yrange=[-0.1,1.1],/xstyle,/ystyle
;contour,im2,xxout,yyout,/iso,xrange=[-1,2],yrange=[-1,2],/xstyle,/ystyle,levels=(findgen(10)+1)/10
linecolors
oplot,xx,yy,psym=1,color=2

;other coordinates...


nx=227
ny=149
x=findgen(nx)/(nx-1)*0.1
y=findgen(ny)/(ny-1)*3.14*0.3
xx=x#(y*0+1)
yy=(x*0+1)#y

zz=exp(-(xx-0.4)^2*0.1-(yy-0.6)^2*400) & tvscl,zz

xx2=(xx)*sin(xx+yy*2)
yy2=(xx)*cos(xx+yy*2)

;im2=pg_imwarp(zz,xx2,yy2,xs=-10,xe=10,ys=-10,ye=10,nx=500,ny=500,xxout=xxout,yyout=yyout)

im2=pg_imwarp(data,xx2,yy2,xs=0.0,xe=0.15,ys=-0.1,ye=0.15,nx=500,ny=500,xxout=xxout,yyout=yyout)

pg_plotimage,im2
tvscl,data,500,500
 
ros='/MacApps/rsi/idl_6.3/examples/data/rose.jpg'
im=read_image(ros)

;ok test seem to cnfirm that this works pretty much ok!

;needs to apply to real world image


END


;warp image....

FUNCTION pg_imwarp,im1,x1,y1,xs=xs,xe=xe,ys=ys,ye=ye,nx=nx,ny=ny,error=error,xxout=xxout,yyout=yyout,quintic=quintic

error=1

s1=size(im1)

IF (s1[0] NE 2) THEN return,-1

nx1=s1[1]
ny1=s1[2]



IF n_elements(x1) EQ nx1 THEN $
   xx1=rebin(x1,nx1,ny1) $
ELSE $
   IF n_elements(x1) NE nx1*ny1 THEN $;t=
      RETURN,-1 $
   ELSE $
      xx1=x1


IF n_elements(y1) EQ ny1 THEN $
   yy1=transpose(rebin(y1,ny1,nx1)) $
ELSE $
   IF n_elements(y1) NE nx1*ny1 THEN $
      RETURN,-1 $
   ELSE $
      yy1=y1


Triangulate, xx1, yy1, triangles, boundaryPts

gs = [double(xe-xs)/nx, double(ye-ys)/ny]
im2 = TriGrid(xx1, yy1, im1, triangles,gs, [xs,ys,xe,ye],nx=nx,ny=ny,XGrid=xxout,YGrid=yyout,quintic=quintic)


return,im2

END



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;test triangulate
;; nr=128;512
;; nphi=128;512
;; r=findgen(nr)/(nr-1)
;; phi=findgen(nphi)/(nphi-1)*2*!Pi
;; rr=(phi*0+1)#r
;; pphi=phi#(r*0+1)

;; ray=exp(-(rr-0.5)^2*140-(pphi-2.5)^2*1)
;; tvscl,ray

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; ;conversion polar ->cartesian
;; xx=rr*cos(pphi)
;; yy=rr*sin(pphi)


;; ;x=randomu(seed,300)
;; ;y=randomu(seed,300)
;; x=xx & y=yy

;; pg_setplotsymbol,'CIRCLE',size=0.8
;; plot,x,y,psym=8,xrange=[0.0,0.2],yrange=[-0.1,0.1],/xstyle,/ystyle,/iso

;; triangulate,x,y,tri,boundary,connectivity=clist

;; FOR i=0,n_elements(tri[0,*])-1 DO BEGIN 
;;    oplot,x[tri[*,i]],y[tri[*,i]]
;; ENDFOR

;; ;sample data....

;; ;;x=[0.0,1,1,0,0.2,0.6,0.8,0.3]
;; ;;y=[0.0,0,1,1,0.8,0.2,0.6,0.25]

;; x=randomu(seed,100)
;; y=randomu(seed,100)



;; pg_setplotsymbol,'CIRCLE',size=0.8
;; plot,x,y,psym=8,xrange=[-0.1,1.1],yrange=[-0.1,1.1],/xstyle,/ystyle,/iso

;; triangulate,x,y,tri,boundary,connectivity=clist

;; ;FOR i=0,n_elements(tri[0,*])-1 DO BEGIN 
;; ;   oplot,x[[tri[*,i],tri[0,i]]],y[[tri[*,i],tri[0,i]]]
;; ;ENDFOR

;; FOR i=0,clist[0]-2 DO BEGIN 
;;    thislist=clist[clist[i]:clist[i+1]-1]
;;    boundary=0
;;    IF thislist[0] EQ i THEN BEGIN 
;;       thislist=thislist[1:*]
;;       boundary=1
;;    ENDIF $
;;    ELSE BEGIN 
;;       thislist=[thislist,thislist[0]]
;;    ENDELSE

 
;;    print,thislist
;;    print,i
;;    print,' '
 
;;   FOR j=0,n_elements(thislist)-2 DO BEGIN
;;       thistriangle=[i,thislist[j],thislist[j+1]]
;; ;      print,thistriangle
;;       pg_circumcircle_center,[x[thistriangle[0]],y[thistriangle[0]]] $
;;                             ,[x[thistriangle[1]],y[thistriangle[1]]] $
;;                             ,[x[thistriangle[2]],y[thistriangle[2]]] $
;;                             ,cx,cy
;;       ;print,i,j,thistriangle
;; ;      stop
;;       IF j EQ 0 THEN BEGIN 
;;          allcx=cx
;;          allcy=cy
;;       ENDIF $
;;       ELSE BEGIN 
;;          allcx=[allcx,cx]
;;          allcy=[allcy,cy]
;;       ENDELSE
;;    ENDFOR
   
;;    IF boundary EQ 0 THEN BEGIN 
;;       allcx=[allcx,allcx[0]]
;;       allcy=[allcy,allcy[0]]
;;    ENDIF

;;    oplot,allcx,allcy,color=5

;; ENDFOR





