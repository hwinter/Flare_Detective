;+
; NAME:
;
; PG_FFTFASTDECONV
;
; PURPOSE:
;
; Perform a fast deconvolution of an image and a point-spread function.
; Warning: this is by no means the best way to perform deconvolution, and
; artifacts may be quite strong - or your result may be very sensitive to
; noise.
;
; CATEGORY:
;
; image processing tools
;
; CALLING SEQUENCE:
;
; deconvolved_signal=pg_fftfastdeconv(image,psf,threshold=threshold)
;
; INPUTS:
;
; image: an array (any size/dimension OK). This is the imnage to be deconvolved.
; psf:   an array with the same size/dimension as image. This should be normalized
;        (i.e. total(psf) is equal to 1). This is the PSF.
;
; OPTIONAL INPUTS:
;
; threshold: The algorithm performs a division of two images in frequency
;            spaces. Unfortunately - division by zero may occurr. Therefore,
;            all fourier components less than threshold are artifically set to 0. 
;            This will cause the result of the division to have INFs and NANs -
;            these will the be set to 0.
;
;
;
; KEYWORD PARAMETERS:
;
;
;
; OUTPUTS:
;
;
;
; OPTIONAL OUTPUTS:
;
; error: error state from the routine. The meaning of the values is described
;        below:
;        -1:  unknown error
;         0:  successful completion
;         1:  image or psf have unallowed size (0 or more than 3 dimensions)
;         2:  image and psf size differ
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
; Inputs needs to be as described above.
;
; PROCEDURE:
; 
; Uses a simple FFT inversion procedure - *warning* may not be the best way
; to do this *end warning*. if signal is the original signal, psf the point
; spread function and image the blurred image we have:
;
; image=INVF(F(signal)*F(psf))
;
; where F means fourier transformation (FT) and INVF inverse FT.
;
; Therefore
; F(image)=F(signal)*F(psf) and
; signal=INVF(F(image)/F(psf))
;
; Unfortunately, this doesn't work very well if F(psf) is 0.
;
; 
;
; EXAMPLE:
;
;
;
; AUTHOR:
;
; Paolo Grigis 
; pgrigis@cfa.harvard.edu
;
; MODIFICATION HISTORY:
;
; 02-OCT-2009 written PG
;
;-

FUNCTION pg_fftfastdeconv,image,psf,threshold=threshold,error=error

on_error,2

;initializes error
error=-1

;get array dimension and sizes
sim=size(image)
spsf=size(psf)

;check for non 1D or 2D or 3D images
IF sim[0] EQ 0 OR sim[0] GT 3 OR spsf[0] EQ 0 OR spsf[0] GT 3 THEN BEGIN 
   ;wrong dimension -> return
   error=1
   print,'This algorithm only works for 1D, 2D or 3D arrays'
   print,'You supplied a '+strtrim(sim[0],2)+'D and a '+strtrim(spsf[0],2)+'D array instead'
   RETURN,image
ENDIF 

;check that sizes match
IF total(sim[1:sim[0]] EQ spsf[1:spsf[0]]) NE sim[0] THEN BEGIN 
   ;no match -> returns and sets error to 1
   error=2
   print,'This algorithm only works for images and psf of the same size!'
   RETURN,image
ENDIF 


;initializes trheshold
IF  size(image,/tname)  EQ  'FLOAT'  THEN $
   threshold=fcheck(threshold,1e-7) ELSE $
   threshold=fcheck(threshold,1d-16)

;FFT of image and zero insertion
fftim=fft(image,-1)
ind=where(abs(fftim) LT threshold,count)
IF count GT 0 THEN fftim[ind]=0

;FFT of PSF and zero insertion
fftpsf=fft(psf,-1)
ind=where(abs(fftpsf) LT threshold,count)
IF count GT 0 THEN fftpsf[ind]=0

;Frequency Space division
fratio=fftim/fftpsf
ind=where(finite(fratio) EQ 0,count)
IF count GT 0 THEN fratio[ind]=0

n=n_elements(image)

CASE sim[0] OF 
   1: BEGIN
         error=0
         RETURN,shift(fft(fratio,1),sim[1]/2+(sim[1] MOD 2))/n ;addition of mod 2 necessary to make it work for odd-sized image too
      END 
   2: BEGIN
         error=0
         RETURN,shift(fft(fratio,1),sim[1]/2+(sim[1] MOD 2),sim[2]/2+(sim[2] MOD 2))/n
      END 
   3: BEGIN
         error=0
         RETURN,shift(fft(fratio,1),sim[1]/2+(sim[1] MOD 2),sim[2]/2+(sim[2] MOD 2),sim[3]/2+(sim[3] MOD 2))/n
      END 
   ELSE: BEGIN 
      ;not that this should NEVER happpen!
      RETURN,image
   ENDELSE  
ENDCASE

END






