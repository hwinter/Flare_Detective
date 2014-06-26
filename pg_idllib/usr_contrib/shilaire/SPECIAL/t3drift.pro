;	Pascal Saint-Hilaire	2001/10/24
;			psainth@hotmail.com OR shilaire@astro.phys.ethz.ch
;
;PURPOSE:
;	THIS PROGRAM CALCULATES THE DRIFT RATE nu_dot/nu, GIVEN
;		A BEAM POSITION, SPEED, AND DIRECTION
;
;CALL SEQUENCE:
;	t3drift, XYpos, beta, dir	[,/SILENT] [, delta=delta] [, gamma=gamma] [,nu_dot_over_nu=nu_dot_over_nu]
;
;	(t3 as in TYPE III)
;
;INPUT:
;	XYpos: position array, in terms of solar radii
;	beta: beam velocity, in units of c
;	dir : beam direction, angle from x-axis, in degrees
;
;KEYWORD:
;	\SILENT: no output to screen
;
;OPTIONAL OUTPUT:
;	delta : angle between beam direction and solar radial direction 
;		(>90 degrees means the beam is going downwards in the corona)
;
;	gamma : angle between beam direction and line-of-sight of Observer (on Earth)
;		(>90 degrees means the beam is going away from observer...)
;
;	nu_dot_over_nu : drift rate over mean frequency, in s^-1
;
;
;EXAMPLE:
;	t3drift,[-1,-1], 0.9, -135
;	t3drift,[-1.001,0.],0.99,0	;max. positive drift rate...
;



PRO t3drift,XYpos, beta, dir, SILENT=SILENT,		$
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
beta=DOUBLE(beta)
dir=!PI*DOUBLE(dir)/180.
length=(Xrange(1)-Xrange(0))/10.


; delta = angle between beam and radial direction
delta=ACOS( ( XYpos[0]*cos(dir) + XYpos[1]*sin(dir) )/SQRT(XYpos[0]^2 +XYpos[1]^2) )
; gamma = angle of beam as seen from Earth
;;;;; FAUX!: gamma=ACOS( ( XYpos[0]*cos(dir) + (XYpos[1]-DistanceES/SolarRadius)*sin(dir) )/SQRT( XYpos[0]^2 + (XYpos[1]-DistanceES/SolarRadius)^2 ) )
gamma=ACOS( -( XYpos[0]*cos(dir) + (XYpos[1]+DistanceES/SolarRadius)*sin(dir) )/SQRT( XYpos[0]^2 + (XYpos[1]+DistanceES/SolarRadius)^2 ) )
; Hn
Hn=0.05*T	;km
nu_dot_over_nu=-c*beta*cos(delta)/( 2*Hn*(1-beta*cos(gamma)) )

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
	ARROW, XYpos(0), XYpos(1), XYpos(0)+length*cos(dir), XYpos(1)+length*sin(dir), /DATA
	
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
