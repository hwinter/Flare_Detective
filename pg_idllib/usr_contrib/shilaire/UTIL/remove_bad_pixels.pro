;removes all pixels with brightness bigger than threshold*avrg of surrounding 8 pixels
;replaces them with the average mu.


FUNCTION remove_bad_pixels,image,threshold=threshold
	IF NOT KEYWORD_SET(threshold) THEN threshold=3.	; !!! log vs. linear scale data...
	threshold=FLOAT(threshold)
	img=FLOAT(image)
	
	nx=N_ELEMENTS(img[*,0])
	ny=N_ELEMENTS(img[0,*])

	n=0L
	FOR i=1L,nx-2 DO BEGIN
		FOR j=1L,ny-2 DO BEGIN
			avrg=(image[i-1,j-1]+image[i,j-1]+image[i+1,j-1]+image[i-1,j]+image[i+1,j]+image[i-1,j+1]+image[i,j+1]+image[i+1,j+1])/8.
			IF abs(image[i,j] - avrg) GE ((threshold-1.)*abs(avrg)) THEN BEGIN
				img[i,j]=avrg
				n=n+1
			ENDIF
		ENDFOR
	ENDFOR		
	PRINT,'....................remove_bad_pixels.pro replaced '+strn(n)+' pixels.'
	RETURN,img
END	






;removes all pixels with brightness bigger than mu+threshold*sigma of the 8 surrounding pixels.
; replaces them with the average mu.
;	THIS IS EXTREMELY SLOW, AND NOT VERY EFFECTIVE !!!
;
;FUNCTION remove_bad_pixels,image,threshold=threshold
;	IF NOT KEYWORD_SET(threshold) THEN threshold=10
;	threshold=FLOAT(threshold)
;	img=FLOAT(image)
;	
;	nx=N_ELEMENTS(img[*,0])
;	ny=N_ELEMENTS(img[0,*])
;
;	n=0L
;	FOR i=1L,nx-2 DO BEGIN
;		FOR j=1L,ny-2 DO BEGIN
;			neighbouringpixels=[image[i-1,j-1],image[i,j-1],image[i+1,j-1],image[i-1,j],image[i+1,j],image[i-1,j+1],image[i,j+1],image[i+1,j+1]]
;			mu=MEAN(neighbouringpixels)
;			sigma=STDDEV(neighbouringpixels)
;			IF abs(image[i,j] - mu) GE threshold*sigma THEN BEGIN
;				img[i,j]=mu
;				n=n+1
;			ENDIF
;		ENDFOR
;	ENDFOR		
;	PRINT,'....................remove_bad_pixels.pro replaced '+strn(n)+' pixels.'
;	RETURN,img
;END	
;
