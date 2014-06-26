; Takes a HESSI image, and tries to return number of sources in it.
;
; The idea is to iteratively remove 2d gaussian sources until 20% of peak value in image is reached.
;
; EXAMPLE:
;	PRINT,hedc_nbr_sources(imagecube)
;

;-----------------------------------------------------------------------------------------------------
FUNCTION hedc_nbr_sources_in_image1, image, SHOW=SHOW

	;settings:
	minpeak=0.2
	minsigma=5.
	maxnbrsources=6.
	minsourcesize=3.5	;FWHM in pixels

	img=FLOAT(image)
	img=img/MAX(img)
		;img=FLOAT(image > 0)
	orig=img
	
	themean=MEAN(img)
	thesigma=STDDEV(img)
	themin=MIN(img)
	themax=MAX(img)
	minsourcesigma=minsourcesize/2.355
	
	IF MAX(img) LT (themean+minsigma*thesigma) THEN RETURN,-9999
	IF KEYWORD_SET(SHOW) THEN BEGIN
		;psh_win,800
		WINDOW,0,xs=800,ys=800
		!P.MULTI=[0,3,3]
	ENDIF
	
	ns=0	
;	WHILE ( (MAX(img) GT minpeak*themax) AND (MAX(img) GT (themean+minsigma*thesigma))) DO BEGIN
	WHILE ( (MAX(img) GT minpeak*themax) AND (MAX(img) GT (themean+minsigma*STDDEV(img)))) DO BEGIN
		IF KEYWORD_SET(SHOW) THEN plot_image,img,xtit='Z range: '+strn(MIN(img))+','+strn(MAX(img)),charsize=2.0,MAX=themax,MIN=themin
		tmpimg=SMOOTH(img,7)
		tmpmax=MAX(tmpimg)
		tmpxy=max2d(tmpimg)
		img=img-mpfit2dpeak(img,coeff,/TILT,estimates=[0,tmpmax,2,2,tmpxy[0],tmpxy[1],0],/GAUSS)
		IF ( (coeff[2] GE  minsourcesigma) AND (coeff[3] GE  minsourcesigma) ) THEN BEGIN
		    ;seems we have a source...
		    ns=ns+1
		    ;IF MAX(coeff[2:3]) GT 2*MIN(coeff[2:3]) THEN ns=ns+1	;as probably a double source...
		ENDIF
		IF ns GT maxnbrsources THEN RETURN,-9999
	ENDWHILE
	IF KEYWORD_SET(SHOW) THEN BEGIN
		plot_image,img,xtit='Z range: '+strn(MIN(img))+','+strn(MAX(img)),charsize=2.0,MAX=themax,MIN=themin
		!P.MULTI=0
		PRINT,'
	ENDIF
	RETURN,ns
END
;-----------------------------------------------------------------------------------------------------
FUNCTION hedc_nbr_sources1, imagecube, SHOW=SHOW
	IF (SIZE(imagecube))[0] LT 2 THEN BEGIN PRINT,'Need a 2D image or 3D imagecube!' & RETURN,-1 & ENDIF
	nbrsources=hedc_nbr_sources_in_image1(imagecube[*,*,0], SHOW=SHOW)
	IF N_ELEMENTS(imagecube[0,0,*]) EQ 1 THEN RETURN,nbrsources ELSE BEGIN
		FOR i=1,N_ELEMENTS(imagecube[0,0,*])-1 DO nbrsources=[nbrsources,hedc_nbr_sources_in_image1(imagecube[*,*,i], SHOW=SHOW)]	
	ENDELSE
;	RETURN,MAX(nbrsources)
	RETURN,nbrsources
END
;-----------------------------------------------------------------------------------------------------
