;	PSH 2003/01/27
;
;EXAMPLE:
;	extended_source_drift,[-0.3,-1.5],50
;



PRO extended_source_drift,XYpos, dir, SILENT=SILENT,		$
	delta=delta, gamma=gamma, nu_dot_over_nu=nu_dot_over_nu

;assumes index of refraction is 1 throughout the corona... 
;otherwise see Plasma Astrophysics by A.O. Benz, pp.108-109


Xrange=[-2.D,2.D]
Yrange=[-4.5D,1.5D]
XYwindowpixels=[512,768]

SolarRadius = 696000.D		; km
DistanceES  = 150000000.D 	; km
T=2000000D			; K
nu=430D				; MHz
c=299792.458			; km/s


XYpos=DOUBLE(XYpos)
dir=!PI*DOUBLE(dir)/180.
length=(Xrange(1)-Xrange(0))/10.


; delta = angle between beam and radial direction
delta=ACOS( ( XYpos[0]*cos(dir) + XYpos[1]*sin(dir) )/SQRT(XYpos[0]^2 +XYpos[1]^2) )
; gamma = angle of beam as seen from Earth
gamma=ACOS( -( XYpos[0]*cos(dir) + (XYpos[1]+DistanceES/SolarRadius)*sin(dir) )/SQRT( XYpos[0]^2 + (XYpos[1]+DistanceES/SolarRadius)^2 ) )
; Hn
Hn=0.05*T	;km
nu_dot_over_nu=c*cos(delta)/( 2*Hn*cos(gamma) )

IF NOT KEYWORD_SET(SILENT) THEN BEGIN
	window,0,xsize=XYwindowpixels[0],ysize=XYwindowpixels[1]
	plot,Xrange,Yrange,/iso,xstyle=1,ystyle=1,xmargin=[3,1],ymargin=[2,2]
	oplot,Xrange,Yrange,color=0
	oplotcircle,[0,0],1
	ARROW,/DATA,0,0,(Xrange(1)-Xrange(0))/10.,0
	XYOUTS,/DATA,0.2,-0.1,'X'
	ARROW,/DATA,0,0,0,(Xrange(1)-Xrange(0))/10.
	XYOUTS,/DATA,-0.1,0.2,'Y'
	
	oplot,[XYpos(0)],[XYpos(1)],psym=-7
	;ARROW, XYpos(0), XYpos(1), XYpos(0)+length*cos(dir), XYpos(1)+length*sin(dir), /DATA
	PLOTS,XYPOS[0]+length*cos(dir)*[-1.,1.],XYPOS[1]+length*sin(dir)*[-1.,1.], /DATA
	
	ARROW,/DATA, 0,(9*Yrange(0)+Yrange(1))/10., 0, (19*Yrange(0)+Yrange(1))/20.
	XYOUTS,/DATA, 0.1,-4.0,'EARTH'

	ligne='delta: '+STRN(180.*delta/!PI,format='(f15.1)')+' degrees'
	XYOUTS,0.7*XYwindowpixels(0),0.1*XYwindowpixels(1),/DEV,ligne
	ligne='gamma: '+STRN(180.*gamma/!PI,format='(f15.1)')+' degrees'
	XYOUTS,0.7*XYwindowpixels(0),0.1*XYwindowpixels(1)-15,/DEV,ligne
	ligne='nu_dot/nu: '+STRN(nu_dot_over_nu,format='(f15.3)')+' s!U-1!N'
	XYOUTS,0.7*XYwindowpixels(0),0.1*XYwindowpixels(1)-30,/DEV,ligne

ENDIF
;wdel,0
END
