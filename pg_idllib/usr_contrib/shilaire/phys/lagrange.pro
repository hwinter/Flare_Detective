; this routine seem not to be yet up to snuff...



;Computes the Fx,Fy component of the force felt by a small mass at coord (x,y),
; not forgetting the all important contribution of the centyrifugal force.

;Masses are in units of Msun, distances in AUs.
;result should be an acceleration in Gees, if /Gee is set, otherwise, in AU/yr^2

FUNCTION lagrange,xp,yp,LOUD=LOUD,Gee=Gee

	;CONSTANTS--------------------------------
	K = 39.478 ; K is the acceleration on Earth by the Sun's gravity, in AU/yr^2 (precision could be improved...)
	Ma = 1.0
	Mb = 1/1000.
	D = 4.5D
	OMEGA = 2*!dPI/11

	;DERIVED--------------------------------
	xa = -D*Mb/(Ma+Mb)
	xb = D*Ma/(Ma+Mb)

	x=DOUBLE(xp)
	y=DOUBLE(yp)
	

	;THE REST--------------------------------
	ax=K*Ma*(-x+xa)/((x-xa)^2 + y^2)^1.5 + K*Mb*(-x+xb)/((x-xb)^2 + y^2)^1.5 + x*OMEGA^2
	ay=K*Ma*(-y)/((x-xa)^2 + y^2)^1.5 + K*Mb*(-y)/((x-xb)^2 + y^2)^1.5 + y*OMEGA^2

	IF LOUD GE 1 THEN BEGIN
		myct3,ct=1
		WDEF,1
		PLOT,/iso,[0],[0],psym=1,color=255,xr=[-D,D],yr=[-D,D],xtit='AU',ytit='AU'		; plots barycenter
		tvellipse,-xa,-xa,0,0,/DATA,color=252			;trajectory of big body
		OPLOT,[xa],[0],color=252,psym=2	;plots big body		
		tvellipse,xb,xb,0,0,/DATA,color=252			;trajectory of small body
		OPLOT,[xb],[0],color=252,psym=4	;plots small body
		OPLOT,[x],[y],color=250,psym=7	;plots point of interest
		ARROW,x,y,x+ax/2,y+ay/2,/DATA,color=254
		;the length of the arrow corresponds to the distance travelled at this constant acceleration in 1 year.
	ENDIF	
	IF LOUD GE 2 THEN BEGIN
		myct3,ct=1
		WDEF,2
		pixres=0.1		;AU per pixel
		nbrpix=128

		accel=FLTARR(nbrpix,nbrpix)
		FOR i=0L,nbrpix-1 DO BEGIN
			FOR j=0L,nbrpix-1 DO BEGIN
				a=lagrange(DOUBLE(i-nbrpix/2)*pixres,DOUBLE(j-nbrpix/2)*pixres,LOUD=0,/G)
				accel[i,j]=(a[0]^2 + a[1]^2)^0.5
			ENDFOR
		ENDFOR
		plot_image,alog(accel),top=240		
	ENDIF	


	IF KEYWORD_SET(Gee) THEN RETURN,[ax,ay]/6639.2/9.81 ELSE RETURN,[ax,ay]
END
