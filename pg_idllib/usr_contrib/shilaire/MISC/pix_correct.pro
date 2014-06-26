; a part of an image array can be entered, corrected for, and then used to replace 
;	original part of an image.
;
;	EXAMPLE:  
;		pix_correct,myimg(20:40,3:70),out	; enter part of image you want to edit
;		myimg(20:40,3:70)=out				; apply the corrections to original image
;				
;	USAGE:
;		middle-click: choose pixel color
;		left-click: replace picel by currently choosen color
;		right-click: ends...
;
;


PRO pix_correct,inimg,outimg,mag=mag,pixval=pixval

; mag is magnifying factor, default is 10
IF not keyword_set(mag) then mag=10
IF not keyword_set(pixval) then pixval=0
nx=N_ELEMENTS(inimg(*,0))
ny=N_ELEMENTS(inimg(0,*))
img=inimg

dispimg=congrid(img,mag*nx,mag*ny)
tvscl,dispimg
!mouse.button=0
WHILE (!mouse.button NE 4) DO BEGIN
        cursor,dispx,dispy,/dev,/down
        IF (!mouse.button EQ 2) THEN BEGIN        	
			pixval=img(dispx/mag,dispy/mag)
			print,'x= '+strn(dispx/mag)+'   y= '+strn(dispy/mag)+'    Pixel value= '+strn(pixval)
        ENDIF
        IF (!mouse.button EQ 1) THEN BEGIN
			img(dispx/mag,dispy/mag)=pixval
			dispimg=congrid(img,mag*nx,mag*ny)
			tvscl,dispimg				
        ENDIF
ENDWHILE
outimg=img
END
