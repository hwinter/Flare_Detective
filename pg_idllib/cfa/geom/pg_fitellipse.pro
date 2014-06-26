FUNCTION pg_ellipsedistance,p,xpoint=xpoint,ypoint=ypoint

a=p[0]
b=p[1]
theta=p[2]
xc=p[3]
yc=p[4]

npoints=n_elements(xpoint)

rtot=0

FOR i=0,npoints-1 DO BEGIN 
   rtot=rtot+(pg_distfromellipse(xpoint=xpoint[i],ypoint=ypoint[i],a=a,b=b,xc=xc,yc=yc,theta=theta))^2
ENDFOR

;print,rtot

;pritn,rtot

return,rtot


END


PRO pg_test2,x,y,par

npoints=20
t=randomu(seed,npoints)*!Pi*2
dx=randomn(seed,npoints)*0.02
dy=randomn(seed,npoints)*0.02

t2=findgen(1000)/999*!Pi*2

theta=0.47

a=2.1
b=1

xc=0.4
yc=-0.1

px1=a*cos(theta)
py1=a*sin(theta)

sq=!Pi/2

px2=b*cos(theta+sq)
py2=b*sin(theta+sq)


x=xc+px1*cos(t)+px2*sin(t)+dx
y=yc+py1*cos(t)+py2*sin(t)+dy

x2=xc+px1*cos(t2)+px2*sin(t2);+dx
y2=yc+py1*cos(t2)+py2*sin(t2);+dy


plot,x,y,psym=6,xrange=[-3,3],yrange=[-3,3],/iso
oplot,x2,y2,color=5

par=pg_fitellipse(x,y)

print,par

a=par[0]
b=par[1]
theta=par[2]
xc=par[3]
yc=par[4]


t=findgen(1000)/1000*!Pi*2

px1=a*cos(theta)
py1=a*sin(theta)

sq=!Pi/2

px2=b*cos(theta+sq)
py2=b*sin(theta+sq)

linecolors
oplot,xc+px1*cos(t)+px2*sin(t),yc+py1*cos(t)+py2*sin(t),col=2

END

function pg_fitellipse,x,y

xaverage=average(x)
yaverage=average(y)

parinfo=replicate({value:0d,fixed:0,limited:[0,0],limits:[0d,0],parname:' '},5)

parinfo[0].parname='a: semimajor axis'
parinfo[0].value=0.5*(max(x)-min(x))
parinfo[0].limited=[1,0]
parinfo[0].limits=[0d,0]

parinfo[1].parname='b: semimajor axis'
parinfo[1].value=0.5*(max(y)-min(y))
parinfo[1].limited=[1,0]
parinfo[1].limits=[0d,0]

parinfo[2].parname='theta: inclination angle'
parinfo[2].value=1.0
parinfo[2].limited=[1,1]
parinfo[2].limits=[-!Dpi/2,!DPi/2]

parinfo[3].parname='xc: x of center'
parinfo[3].value=xaverage
parinfo[3].limited=[0,0]

parinfo[4].parname='yc: y of center'
parinfo[4].value=yaverage
parinfo[4].limited=[0,0]


functargs={xpoint:x,ypoint:y}

result=tnmin('pg_ellipsedistance',parinfo=parinfo,/autoderivative,functargs=functargs)

return,result

end



