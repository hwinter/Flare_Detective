;+
; NAME:
;
; pg_convolve_images
;
; PURPOSE:
;
; Convolves two images of the same size by using FFT product.
;
; CATEGORY:
;
; image processing
;
; CALLING SEQUENCE:
;
; convolved_image=pg_convolve_images(image1,image2)
;
; INPUTS:
;
; image1,image2: two float (or double) arrays of the same size (nx by ny)
; 
; OPTIONAL INPUTS:
;
; NONE
;
; KEYWORDS:
;
; NONE
; 
; OUTPUTS:
;
; convolved_imag: the convolved image, a nx by ny image (float or double)
;
; OPTIONAL OUTPUTS:
;
; error: 0: succesful 1:an error occurred
;
; COMMON BLOCKS:
;
; NONE
;
; SIDE EFFECTS:
;
; NONE
;
; RESTRICTIONS:
;
; The two input images *must* have the same size
;
; PROCEDURE:
;
; Computes the FFT of each image, multiplies them and compute the inverse FFT 
;
; EXAMPLE:
;
;
; AUTHOR:
;
; Paolo Grigis, Harvard-Smithsonian Center for Astrophysics
; pgrigis@cfa.harvard.edu
;
; MODIFICATION HISTORY:
;
; 28-SEP-2009 written PG
; 
;
;-


FUNCTION pg_convolve_images,image1,image2,error=error,verbose=verbose,double=double

error=-1
s1=size(image1)
s2=size(image2)

IF s1[0] EQ 2 AND s2[0] EQ 2 AND total(s1[1:2] EQ s2[1:2]) EQ 2 THEN BEGIN 

   nx=s1[1]
   ny=s1[2]

   convolved_image=shift(abs(fft(fft(image1,-1,double=double)*fft(image2,-1,double=double),1,double=double)),nx/2,ny/2)*nx*ny

ENDIF $
ELSE BEGIN 
   error=1
   IF keyword_set(verbose) THEN BEGIN 
      print,'ERROR: This program needs two arrays as inputs with the same size!'
      print,'Returning'
   ENDIF 
   convolved_image=-1
ENDELSE 

RETURN,convolved_image

END


