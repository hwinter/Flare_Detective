
;+
;NAME:
;	rhessi_get_spin_axis_position.pro
;PROJECT:
;	HESSI at ETHZ
;CATEGORY:
; 
;PURPOSE:
;	Returns the spin axis position (a 2-element array), or -1 if something went amiss.	
;CALLING SEQUENCE:
;	spin_axis_pos=rhessi_get_spin_axis_position(time)
;
;INPUT:
;	time : a time in ANYTIM format, or a time interval (2-element array of such times)
;		If a single time is given, routine assumes a time interval of 1 min (-30 to +30 secs.)
;		This should be ok most of the time.
;
;OPTIONAL INPUT:	
;	None
;
;OUTPUT:
;	The spin axis' x- and y-coordinates (2-element array), in arcsec from Sun-center (averaged over time interval, or 1 min. if a single time was given).
;
;INPUT KEYWORDS:
;	None
;
;OUTPUT KEYWORDS:
;	radius : distance between spin axis and imaging axis.
;	sigma_xy : 2-D array containing the standard deviations of both x and y.
;	sigma_radius : standard deviation of radius
;
;EXAMPLE:
;	spin_axis_pos=rhessi_get_spin_axis_position('2002/02/26 10:27:00')
;
;HISTORY:
;	PSH, 2002/12/06 written.
;
;-

FUNCTION rhessi_get_spin_axis_position, time, err=err, LOUD=LOUD, radius=radius, sigma_xy=sigma_xy, sigma_radius=sigma_radius
	err=0
	CATCH,err
	IF err NE 0 THEN BEGIN 
		CATCH,/CANCEL 
		PRINT,'........rhessi_get_spin_axis_position.pro: problem! Returning -1...' 
		xy=-1
		GOTO,THEEND
	ENDIF
	
	IF N_ELEMENTS(time) EQ 2 THEN time_intv=anytim(time) ELSE time_intv=anytim(time)+[-30.,30.]
	ao=hsi_aspect_solution() 
	ao->set,aspect_cntl_level=0     
	ao->set,obs_time_interval=anytim(time_intv)
	;ao->set,aspect_time_range=anytim(time_intv)    
	as=ao->getdata()
	
	times=as.time * 2d^(-7)
	;t0=hsi_sctime2any(as.t0)	; actually not needed...

	;calculate the coordinates of the center of the circle defined by three points about 1 second apart in time. Do this as long as I have points available, and average the result.	
	i=0
	WHILE ((i+21) LT N_ELEMENTS(times)) DO BEGIN
		x1=as.POINTING[i,0]
		x2=as.POINTING[i+10,0]
		x3=as.POINTING[i+21,0]
		y1=as.POINTING[i,1]
		y2=as.POINTING[i+10,1]
		y3=as.POINTING[i+21,1]
		CIR_3PNT,[x1,x2,x3],[y1,y2,y3],r0,x0,y0
		IF exist(xc) THEN BEGIN
			xc=[xc,x0] 
			yc=[yc,y0]
			r=[r,r0]
		ENDIF ELSE BEGIN
			xc=x0
			yc=y0
			r=r0
		ENDELSE		
		i=i+32
	ENDWHILE	
	IF KEYWORD_SET(LOUD) THEN PRINT,'Standard error: xc: '+strn(STDDEV(xc))+' yc: '+strn(STDDEV(yc))+' radius: '+strn(STDDEV(r))
	xy=[MEAN(xc),MEAN(yc)]
	radius=MEAN(r)
	sigma_xy=[STDDEV(xc),STDDEV(yc)]
	sigma_radius=STDDEV(r)	
	
	THEEND:
	OBJ_DESTROY,ao
	RETURN,xy
END

