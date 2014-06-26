PRO pg_hsapp_test

n=160000
t=findgen(n)/(n-1)


P1x=0.0 - 0.5*sin(t*!Pi)
P1y=0.5 + 0.5*cos(t*!Pi)

P2x=1.0 +  0.5*sin(t*!Pi)
P2y=0.5 -  0.5*cos(t*!Pi)

x=[t  , P2x,1-t  ,P1x]
y=[0*t, P2y,1+0*t,P1y]

sf=0.50

;plot,x,y,xrange=[-1,4],yrange=[-1,2],/iso,psym=-6

pg_hshapp,x,y,xo=xo,yo=yo,sf=sf

linecolors
;plot,x,y,xrange=[-1,4],yrange=[-1,2],/iso;,psym=-6
;oplot,xo,yo,col=2;,psym=-6,color=2

pg_hshapp,xo,yo,xo=xo,yo=yo,sf=sf

;oplot,xo,yo,color=12


pg_hshapp,xo,yo,xo=xo,yo=yo,sf=sf
pg_hshapp,xo,yo,xo=xo,yo=yo,sf=sf
pg_hshapp,xo,yo,xo=xo,yo=yo,sf=sf
pg_hshapp,xo,yo,xo=xo,yo=yo,sf=sf

;oplot,xo,yo,color=5


plot,xo,yo,xrange=[-0.6,1.6],yrange=[-0.1,1.1],/iso,/xst,/yst;,psym=-6

END



























PRO pg_hshapp,x,y,xout=xout,yout=yout,sf=sf


;assumes (x,y) in the set A U B U C
;A: left half circle centered at (0,0.5), radius 0.5
;B: unit square
;C: right half circle centered at (1,0.5), radius 0.5

sf=fcheck(sf,0.4);shrink factor
zeta=!Pi*0.25*(1+2*sf);stretch factor



;protect input variables
newX=x
newY=y

;divide world into 3 sets
indSetA=where(x LT 0.0             ,countSetA)
indSetB=where(x GE 0.0 AND x LT 1.0,countSetB)
indSetC=where(x GE 1.0             ,countSetC)

;shrink sectors accordingly

IF countSetA GT 0 THEN BEGIN 
   RefX=0.0
   RefY=0.5
   newX[indSetA]=RefX+sf*(newX[indSetA]-RefX)
   newY[indSetA]=RefY+sf*(newY[indSetA]-RefY)-0.25
ENDIF 

IF countSetB GT 0 THEN BEGIN 
   RefY=0.5
   newY[indSetB]=RefY+sf*(newY[indSetB]-RefY)-0.25
   newX[indSetB]=newX[indSetB]*(2+zeta)
ENDIF 


IF countSetC GT 0 THEN BEGIN 
   RefX=1.0
   RefY=0.5
   newX[indSetC]=(2.0+zeta)+sf*(newX[indSetC]-RefX)
   newY[indSetC]=RefY+sf*(newY[indSetC]-RefY)-0.25
   
   newX[indSetC]=2+zeta-newX[indSetC]
   newY[indSetC]=1-newY[indSetC]
ENDIF 

;elongation phase
factor=(2+zeta)/3

indSetB1=where(newX GE 0.0      AND newX LT 1.0,countSetB1)
indSetB2=where(newX GE 1.0      AND newX LT 1.0+zeta,countSetB2)
indSetB3=where(newX GE 1.0+zeta AND newX LT 2.0+zeta,countSetB3)

;stop

IF countSetB1 GT 0 THEN BEGIN 
   ;no changes
ENDIF 

IF countSetB2 GT 0 THEN BEGIN 
   ;turn around

    r=0.5-newY[indSetB2]
    t=(newX[indSetB2]-1)/(zeta)*!Pi-!Pi/2
   
    newX[indSetB2]=1.0+r*cos(t)
    newY[indSetB2]=0.5+r*sin(t)


ENDIF 

IF countSetB3 GT 0 THEN BEGIN 
   ;move over
   newX[indSetB3]=2+zeta-newX[indSetB3]
   newY[indSetB3]=1     -newY[indSetB3]
ENDIF 

;new data - subsets of B




;;zeta=!Pi*0.25*(1-2*sf)


xout=newx
yout=newy




;; one3d=1.0/3.0
;; two3d=2.0/3.0

;; alpha=0.4

;; newx=x
;; newy=one3d+(y-0.5)*alpha*0.5


;; xout=newx
;; yout=newy


;; ind1=where(xout GT one3d AND xout LE two3d,count1)
;; ind2=where(xout GT two3d AND xout LE 1.0,count2)

;; IF count1 GT 0 THEN BEGIN 

;;    t=3.0*(xout[ind1]-one3d)*!PI-!PI/2
;;    r=0.5-yout[ind1]


;;    maxradius=(2+3*alpha)/12.0

;;    xout[ind1]=one3d+r*cos(t);*two3d/maxradius
;;    yout[ind1]=0.50 +r*sin(t)

;;    ;stop

;;    ;maxradius=(2+3*alpha)/12.0

;;    ;xout[ind1]=one3d+(xout[ind1]-one3d)*two3d/maxradius

;; ENDIF 


;; IF count2 GT 0 THEN BEGIN
;;    xout[ind2]=1.0-xout[ind2]
;;    yout[ind2]=1.0-yout[ind2]
;; ENDIF 

;xout=xout*12.0/(14.0+3*alpha)

END


