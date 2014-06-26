;+
; NAME:
;
; PG_RLSLOWDECONV
;
; PURPOSE:
;
; Performs the Richardson-Lucy (RL) deconvolution of an image or a spectrum, using
; the algorithm described in: P. A. Jansson, Deconvolution of Images and
; Spectra, 2nd edition, 1997, Chapter 10. This routine should only be used in the
; case where the Point Spread Function (PSF) is known and constant across the
; imnage (or spectrum). In cases where the PSF is not known, a different blind
; deconvolution scheme should be used instead.
;
; CATEGORY:
;
; image processing
;
; CALLING SEQUENCE:
;
; deconvolved_image=pg_rlslowdeconv(image,psf,niter=niter)
;
; INPUTS:
;
; image: a one- or two-dimensional array, the image or spectrum to be
;        deconvolved. Must be a numeric floating point type (with simple
;        or double precision). ****MUST BE NON_NEGATIVE****
; psf: an array with the same number of dimensions as "image" representing the
;      PSF of the system that prodcued the image. It can have a different number
;      of elements than image. Must be a numeric floating point type (with simple
;      or double precision).
; 
;
; OPTIONAL INPUTS:
;
; niter: the number of iterations to be performed (default: 20)
;
;
; KEYWORDS:
;
; verbose: if set, a record of the workings of the routine is printed to the screen
; nopad: if set, padding of the arrays is disabled. This is faster, but can introduce
;        undesired edge effects. Use with due caution.
; inputohat: allows the user to input the ohat array. This can be used e.g. to
;            restart the iteration if not enough runs were performed.
; 
; OUTPUTS:
;
; deconvolved_image: the deconvolved image or spectrum, or -1 if an error has occurred.
;
; OPTIONAL OUTPUTS:
;
; error: error state from the routine. The meaning of the values is described below:
;        -1:  unknown error
;         0: successful completion
;         1: image or psf have unallowed size (0 or more than 2 dimensions)
;         2: image and psf size differ
;      
;
; ihat: final blurred object model (complex array)
; ohat: final object model (complex array)
;
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
; Inputs must be as desribed above.
;
; PROCEDURE:
;
; The RL algorithm performed here follows closely the algorithm explained in
; P. A. Jansson, Deconvolution of Images and Spectra, 2nd edition, 1997, Chapter
; 10.
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
; 02-OCT-2009 PG written
;
;-


FUNCTION pg_rlslowdeconv,image,psf,niter=niter,ihat=ihat,ohat=ohat

on_error,2

;initializes error
error=-1

;get array dimension and sizes
sim=size(image)
spsf=size(psf)

;check for non 1D or 2D 
IF sim[0] EQ 0 OR sim[0] GT 2 OR spsf[0] EQ 0 OR spsf[0] GT 2 THEN BEGIN 
   ;wrong dimension -> return
   error=1
   print,'This algorithm only works for 1D or 2D arrays'
   print,'You supplied a '+strtrim(sim[0],2)+'D and a '+strtrim(spsf[0],2)+'D array instead'
   RETURN,image
ENDIF 


;check that sizes match
IF total(sim[0:sim[0]] NE spsf[0:spsf[0]]) THEN BEGIN 
   ;no match -> returns and sets error to 1
   error=2
   print,'This algorithm only works for images and psf of the same size!'
   RETURN,image
ENDIF 



;sets the default value for the number of iterations
iter=fcheck(round(niter)>0,20)

;initialize object with image
ohat=image

;deals with usual 2-dim case first
IF sim[0] EQ 2 THEN BEGIN 


   ;compute sizes - needed for FFT shifts
   nx=sim[1]
   ny=sim[2]

   ;shift to be applied to the images
   sx=nx/2
   sy=ny/2


   ;precomputes often used arrays
   fpsf=fft(psf,-1)
   cfpsf=conj(fpsf)


   ;main iteration loop
   FOR i=0,iter-1 DO BEGIN 

      ;blur object model with PSF
      ihat=fft(fpsf*fft(ohat,-1),1)

      ;shift frequencies such that 0 = middle
      ihat=shift(ihat,sx,sy)
   
      ;correlate image/blurred image with PSF
      ohatmulti=fft((fft(image/ihat,-1))*cfpsf,1)

      ;multiply improved object model
      ;shifts frequencies such that 0 = middle
      ohat=ohat*shift(ohatmulti,sx,sy)

   ENDFOR
 
   error=0

ENDIF $
ELSE BEGIN ;this is the 1-dim case (very useful for testing)

   ;compute sizes - needed for FFT shifts
   nx=sim[1]

   ;shift to be applied to array
   sx=nx/2

   ;precomputes often used arrays
   fpsf=fft(psf,-1)
   cfpsf=conj(fpsf)

   ;main iteration loop
   FOR i=0,iter-1 DO BEGIN 

      ;blur object model with PSF
      ihat=fft(fpsf*fft(ohat,-1),1)

      ;shift frequencies such that 0 = middle
      ihat=shift(ihat,sx)
   
      ;correlate image/blurred image with PSF
      ohatmulti=fft((fft(image/ihat,-1))*cfpsf,1)

      ;multiply improved object model
      ;shifts frequencies such that 0 = middle
      ohat=ohat*shift(ohatmulti,sx)

   ENDFOR 

   error=0

ENDELSE 

RETURN,ohat

END 
