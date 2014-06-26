; Takes a HESSI image, and tries to return number of sources in it.
;
; The idea is to iteratively remove 2d gaussian sources until 20% of peak value in image is reached.
;
; EXAMPLE:
;	PRINT,hedc_nbr_sources(imagecube)
;

;-----------------------------------------------------------------------------------------------------
FUNCTION hedc_nbr_sources_in_image, image, SHOW=SHOW

	;settings:
	minpeak=0.2
	minsigma=5.
	maxnbrsources=6.
	minsourcesize=3.5	;FWHM in pixels

	nx=N_ELEMENTS(image[*,0])
	ny=N_ELEMENTS(image[0,*])
	img=FLOAT(image)
	img=img/MAX(img)
		;img=FLOAT(image > 0)
	orig=img
	
	themean=MEAN(orig)
	thesigma=STDDEV(orig)
	themin=MIN(orig)
	themax=MAX(orig)
	minsourcesigma=minsourcesize/2.355
	
	IF themax LT (themean+minsigma*thesigma) THEN RETURN,-9999
	IF KEYWORD_SET(SHOW) THEN BEGIN
		WINDOW,0,xs=800,ys=800
		!P.MULTI=[0,3,3]
	ENDIF
	
	ns=0	
;	WHILE ( (MAX(img) GT minpeak*themax) AND (MAX(img) GT (themean+minsigma*thesigma))) DO BEGIN
	WHILE ( (MAX(img) GT minpeak*themax) AND (MAX(img) GT (themean+minsigma*STDDEV(img)))) DO BEGIN
		IF KEYWORD_SET(SHOW) THEN plot_image,img,xtit='Z range: '+strn(MIN(img))+','+strn(MAX(img)),charsize=2.0,MAX=themax,MIN=themin
		img=(img-GAUSS2DFIT(img,coeff,/TILT))
		IF ( (abs(coeff[2]) GT 2*nx) OR (abs(coeff[3]) GT 2*ny) ) THEN GOTO,THEEND		; if source size is HUGE!
		IF ( (abs(coeff[2]-nx/2) GT nx/2) OR (abs(coeff[3]-ny/2) GT ny/2) ) THEN GOTO,THEEND	; if source position is outside picture...
		IF ( (coeff[2] GE  minsourcesigma) AND (coeff[3] GE  minsourcesigma) ) THEN BEGIN
		    ;seems we have a source...
		    ns=ns+1
		    ;IF MAX(coeff[2:3]) GT 2*MIN(coeff[2:3]) THEN ns=ns+1	;as probably a double source...
		ENDIF ELSE GOTO,THEEND	;if reached that point, means failure to converge... return number of sources found so far...
		IF ns GT maxnbrsources THEN RETURN,-9999
	ENDWHILE

THEEND:
	IF KEYWORD_SET(SHOW) THEN BEGIN
		plot_image,img,xtit='Z range: '+strn(MIN(img))+','+strn(MAX(img)),charsize=2.0,MAX=themax,MIN=themin
		!P.MULTI=0
		PRINT,'
	ENDIF
	RETURN,ns
END
;-----------------------------------------------------------------------------------------------------
FUNCTION hedc_nbr_sources, imgs, SHOW=SHOW, NBARR=NBARR	
	siz=SIZE(imgs)
	IF siz[0] LT 2 THEN BEGIN PRINT,'Need a 2D image or 3D image cube, or a 4D image tesseract!' & RETURN,-1 & ENDIF
	IF siz[0] EQ 4 THEN BEGIN
		;make an image cube out of the image tesseract
		imagecube=REFORM(imgs,siz[1],siz[2],siz[3]*siz[4])
	ENDIF ELSE imagecube=imgs
	
	nbrsources=hedc_nbr_sources_in_image(imagecube[*,*,0], SHOW=SHOW)
	IF N_ELEMENTS(imagecube[0,0,*]) EQ 1 THEN RETURN,nbrsources ELSE BEGIN
		FOR i=1,N_ELEMENTS(imagecube[0,0,*])-1 DO nbrsources=[nbrsources,hedc_nbr_sources_in_image(imagecube[*,*,i], SHOW=SHOW)]	
	ENDELSE
	IF KEYWORD_SET(NBARR) THEN RETURN,nbrsources ELSE RETURN,MAX(nbrsources)
END
;-----------------------------------------------------------------------------------------------------
