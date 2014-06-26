; PSH 2002/02/22
;
; Simulates Hessi back projection for one collimator.
;
;
; Here, I assume the incident angle is ~parallel to the axis... no?!
; And that grids extend infinitely in their plane...
;
;
;
;







;===================================================================================
FUNCTION hessigt1,spratio,spincenter,r,phi
; this function (hessi _grid_transmission) simply returns 0D if point source is behind a slat, or 1D if in a slit.
	x=r*cos(phi)
	x=x-spincenter
	; at this point, x is the distance (in pitch units) between middle of slit to source.	
	x = x MOD 1
	x=abs(x)
	IF ((x GE spratio/2D) AND (x LT (1D - spratio/2D))) THEN RETURN,0D ELSE RETURN,1D
END

;===================================================================================
PRO hsicoll,	spratio=spratio, 	$; slit/pitch ratio (default is 0.5)
		spincenter=spincenter,	$; in units of pitch. =0 if spin axis is in middle of a slit (default is 0.25 : on edge between slit and slat)
		roffset=roffset,	$; radial roffset: distance between point source/image center and spin axis (in units of pitch!) (default is 3.888)
		phioffset=phioffset,	$; angular offset between point source/image center and ecliptic, in degrees (default is 30 deg.).
		stroll=stroll,		$; start and end roll angles (default is 0 and 360)
		endroll=endroll,	$; those are angle between point source and axis perpendicular to slats
		nsteproll=nsteproll,	$; number of steps for roll angle iterations (default is 17)
		pp=pp,			$; back projected image pixel size in pitch unit (default is 10D/OUTIMGSIZ)
		LOUD=LOUD,		$; to have any output displayed...
		image=image,		$; if not set, will use a point source. MUST BE A SQUARE IMAGE!!!
		ifov=ifov,		$; image FOV (in units of pitch!) (only use if image keyword is used !) (default is 10D)
		spincenter_err=spincenter_err,$;	phase error for the reconstruction (in units of pitch, default is OF COURSE 0.)
		OUTIMGSIZ=OUTIMGSIZ, 	$	; dimension of output image, default is 64
		lc=lc,backproj=backproj	 ; OUTPUT KEYWORDS !!!		
		

	IF NOT EXIST(OUTIMGSIZ) THEN  OUTIMGSIZ = 64

	IF not exist(spratio) then spratio=0.5D
	spratio=DOUBLE(spratio)		
	
	IF not exist(spincenter) then spincenter=0.25D
	spincenter=DOUBLE(spincenter)
	
	IF not exist(roffset) then roffset=3.7D
	roffset=DOUBLE(roffset)
	
	IF not exist(phioffset) then phioffset=30D
	phioffset=DOUBLE(phioffset)
	phioffset=phioffset*!PI/180D

	IF not exist(stroll) then stroll=0
	stroll=DOUBLE(stroll)
	stroll=stroll*!PI/180D
	
	IF not exist(endroll) then endroll=360
	endroll=DOUBLE(endroll)
	endroll=endroll*!PI/180D
	
	IF not exist(nsteproll) then nsteproll=17
	nsteproll=LONG(nsteproll)

	IF not exist(pp) then pp=10D/OUTIMGSIZ
	pp=DOUBLE(pp)

	IF NOT KEYWORD_SET(LOUD) THEN LOUD=0

	IF NOT KEYWORD_SET(ifov) THEN ifov=10D
	ifov=DOUBLE(ifov)

	IF NOT KEYWORD_SET(spincenter_err) THEN spincenter_err=0D
	spincenter_err=DOUBLE(spincenter_err)
	
	;..................................................
	
	deltaroll=(endroll-stroll)/nsteproll	; in radians
	
	;..................................................
	;..................................................
	lc=DBLARR(nsteproll)
	IF NOT KEYWORD_SET(image) THEN BEGIN
		; single point source:
		FOR i=0L,nsteproll-1 DO lc(i)=hessigt1(spratio,spincenter,roffset,phioffset-stroll-i*deltaroll)
		;..................................................
	ENDIF ELSE BEGIN
		; any image source:
		image=DOUBLE(image)
		;let's CONGRID the image so that it has 4 times the IMAGER pixel resolution. Several options:
			image=CONGRID(image,4*OUTIMGSIZ,4*OUTIMGSIZ)			; no interpolation done
			;image=CONGRID(image,4*OUTIMGSIZ,4*OUTIMGSIZ,/interp,/minus)	; linear interpolation
			;image=CONGRID(image,4*OUTIMGSIZ,4*OUTIMGSIZ,cubic=-0.5,/minus)	; spline interpolation
		
		nxy=N_ELEMENTS(image(*,0))	; already decided iinout image must be square
		ipp=nxy/ifov	; ImagePixelperPitch.
		FOR  i=0L,nsteproll-1 DO BEGIN
			tmplc=0D
			FOR j=0L,nxy-1 DO BEGIN
				FOR k=0L,nxy-1 DO BEGIN
					xabs=(j-nxy/2)/ipp + roffset*cos(phioffset)
					yabs=(k-nxy/2)/ipp + roffset*sin(phioffset)
					rin=sqrt(xabs^2 + yabs^2)
					phiin=myarctan(xabs,yabs)-stroll-i*deltaroll
					tmplc=tmplc+image(j,k)*hessigt1(spratio,spincenter,rin,phiin)
				ENDFOR
			ENDFOR
			lc(i)=tmplc
		ENDFOR	
		;..................................................
	ENDELSE
	IF LOUD GE 2 THEN BEGIN window,1,xs=768,ys=512 & PLOT,lc,psym=-7,title='Modulation profile' & END
;..........................................................
; reconstructing...........................................
	backproj=DBLARR(OUTIMGSIZ,OUTIMGSIZ)
		
	FOR i=0L,nsteproll-1 DO BEGIN
		tmpimg=DBLARR(OUTIMGSIZ,OUTIMGSIZ)
		curroll=stroll+i*deltaroll
		FOR j=0L,OUTIMGSIZ-1 DO BEGIN
			FOR k=0L,OUTIMGSIZ-1 DO BEGIN
				ximg=(j-OUTIMGSIZ/2)*pp	; in units of pitch
				yimg=(k-OUTIMGSIZ/2)*pp ; in units of pitch
				rimg=sqrt(ximg^2 + yimg^2)
				phiimg=myarctan(ximg,yimg)
				tmpimg(j,k)=lc(i)*hessigt1(spratio,spincenter+spincenter_err,rimg,phiimg-curroll)
			ENDFOR		
		ENDFOR
	backproj=backproj+tmpimg
		IF LOUD GE 3 THEN BEGIN
			wdef,0
			PLOT_IMAGE,tmpimg
			x=roffset*cos(phioffset)/pp +OUTIMGSIZ/2
			y=roffset*sin(phioffset)/pp +OUTIMGSIZ/2
			oplot,[x],[y],psym=-7,color=128
			IF i EQ 0 THEN print,x,y
		ENDIF
	ENDFOR
	backproj=backproj/max(backproj)
	IF LOUD GE 1 THEN BEGIN wdef,0 & PLOT_IMAGE,backproj & END
;..........................................................
END
