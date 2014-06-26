;+
; NAME:
;
; pg_distfromellipse
;
; PURPOSE:
;
; Computes the distance from a point P=(x,y) from an ellipse E.
; The distance is equiavelent to the radius of the smallest circle centered
; on P touching E.
;
; CATEGORY:
;
; Geometrical utilities
;
; CALLING SEQUENCE:
;
; r=pg_distfromellipse(xpoint=xpoint,ypoint=ypoint,a=a,b=b,xc=xc,yc=yc,theta=theta)
;
; INPUTS:
;
; xpoint,ypoint: coordinates of the point
; a: semimajor axis of the ellipse
; b: semiminor axis of the ellipse (b should be less or equal a)
; xc,yc: center of the ellipse (defaults to 0,0 )
; theta: inclination angle of the semimajor axis of the ellipse, equal 0 when it is
;        parallel to the x-axis and positive in the counterclockwise direction.
;        (defaults to 0)
;
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
;
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
; Based on the algorithm described in:
; Distance from a Point to an Ellipse in 2D
; David Eberly
; Geometric Tools, LLC
; http://www.geometrictools.com/
;
; EXAMPLE:
;
;
;
; AUTHOR:
;
; Paolo Grigis
; pgrigis@cfa.harvard.edu
;
; MODIFICATION HISTORY:
;
; 01-SEP-2010 written PG
;
;-


FUNCTION pg_ellipse_newtfunc,t,xpoint=xpoint,ypoint=ypoint,a=a,b=b

x=fcheck(xpoint,0.5)
y=fcheck(ypoint,2.0)
a=fcheck(a,2.0)
b=fcheck(b,1.0)

result=(a*x/(t+a*a))^2+(b*y/(t+b*b))^2-1

RETURN, result

END

FUNCTION pg_ellipse_newtder,t,xpoint=xpoint,ypoint=ypoint,a=a,b=b
x=fcheck(xpoint,0.5)
y=fcheck(ypoint,2.0)
a=fcheck(a,2.0)
b=fcheck(b,1.0)

result=-2*a*a*x*x/(t+a*a)^3-2*b*b*y*y/(t+b*b)^3

return,result
END


FUNCTION pg_mynewt,t,func,funcder,threshold=threshold,_extra=_extra


myt=t

;pritn,myt

threshold=1e-5

done=0
iter=0

WHILE NOT done DO BEGIN 

   iter=iter+1

   
   newt=myt-call_function(func,myt,_extra=_extra)/call_function(funcder,myt,_extra=_extra)
   ;print,newt

   IF abs(newt-myt) LT threshold THEN done=1
   IF iter GT 15 THEN done=1

   myt=newt

ENDWHILE  

return,myt

END

PRO pg_drawell,xpoint=xpoint,ypoint=ypoint,a=a,b=b,xc=xc,yc=yc,theta=theta

theta=fcheck(theta,0.0)

t=findgen(1000)/1000*!Pi*2

px1=a*cos(theta)
py1=a*sin(theta)

sq=!Pi/2

px2=b*cos(theta+sq)
py2=b*sin(theta+sq)

plot,xc+px1*cos(t)+px2*sin(t),yc+py1*cos(t)+py2*sin(t),xrange=[-3,3],yrange=[-2.5,2.5],/iso
plots,xpoint,ypoint,psym=6,symsize=2
r=pg_distfromellipse(xpoint=xpoint,ypoint=ypoint,a=a,b=b,xc=xc,yc=yc,theta=theta)
oplot,xpoint+r*cos(t),ypoint+r*sin(t)


END 

PRO pg_test

xpoint=0.5
ypoint=2.0
a=2.0
b=1.0
xc=0.0
yc=0.0
theta=0.0

pg_drawell,xpoint=xpoint,ypoint=ypoint,a=a,b=b,xc=xc,yc=yc,theta=theta


;; .run
;; for i=0,360 do begin                                                          
;;    pg_drawell,xpoint=xpoint,ypoint=ypoint,a=b,b=a,xc=0.3,yc=0.4,theta=i/360.0*!Pi
;;    wait,0.05                                                                     
;; endfor                                                                        
;; end


END


;theta: inclination angle
;xc,yc: ellipse center
;a,b - ellipse axes
;x,y position of external point
FUNCTION pg_distfromellipse,xpoint=xpoint,ypoint=ypoint,a=a,b=b,xc=xc,yc=yc,theta=theta

;initialize variable to default values

xc=fcheck(xc,0.0)
yc=fcheck(yc,0.0)
xin=fcheck(xpoint,0.5)
yin=fcheck(ypoint,2.0)
ain=fcheck(a,2.0)
bin=fcheck(b,1.0)
theta=fcheck(theta,0)


;checks situation when a < b
IF bin GT ain THEN BEGIN 
   temp=ain
   ain=bin
   bin=temp
   theta=theta+!Pi/2
ENDIF 

;
pg_vect_proj,x=xin-xc,y=yin-yc,lx=ain*cos(theta),ly=ain*sin(theta),par=par,perp=perp,/signum

xin=par[0]
yin=perp[0]


IF xin LT 0 THEN xin=-xin
IF yin LT 0 THEN yin=-yin

;special case
threshold=1e-5
IF yin LT threshold THEN BEGIN
   IF xin LT threshold THEN BEGIN 
      r=bin
   ENDIF $
   ELSE BEGIN 
      IF xin LT (ain-bin^2/ain) THEN BEGIN 
         r=bin*sqrt(1-xin*xin/(ain*ain-bin*bin))
      ENDIF $
      ELSE BEGIN 
         ;IF xin LT a THEN BEGIN
            r=abs(ain-xin)
         ;ENDIF
      ENDELSE 
   ENDELSE 
   return,r
ENDIF


;initial guess for Newtone solution
t=bin*yin-bin^2

;solve equation numerically
Result = pg_mynewt( t,'pg_ellipse_newtfunc','pg_ellipse_newtder',x=xin,y=yin,a=ain,b=bin)

px=ain*ain*xin/(result+ain*ain)
py=bin*bin*yin/(result+bin*bin)

r=sqrt((xin-px)^2+(yin-py)^2)

return,r

END 

