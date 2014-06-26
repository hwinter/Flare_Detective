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
; 05-OCT-2009 PG modifed to perform *blind* deconvolution
;
;-


FUNCTION pg_rlblinddeconv,image,psf,np=np,nn=nn,s=s,h=hok

on_error,2

np=1000
nn=40

;initializes error
error=-1

;initializes s and h
s=image/total(image)
s0=s
h0=psf/total(psf)
;h=s*0+1;psf/total(psf)
;h=h/total(h)

;get array dimension and sizes
sim=size(image)
spsf=size(psf)

;check for non 1D or 2D 
IF sim[0] EQ 0 OR sim[0] GT 2 OR spsf[0] EQ 0 OR spsf[0] GT 2 THEN BEGIN 
   ;wrong dimension -> return
   error=1
   print,'This algorithm only works for 1D or 2D arrays'10   print,'You supplied a '+strtrim(sim[0],2)+'D and a '+strtrim(spsf[0],2)+'D array instead'
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
;;iter=fcheck(round(niter)>0,20)

;;;  ;initialize object with image;
;;;  ohat=image

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

;;   ;precomputes often used arrays
;;   fpsf=fft(psf,-1)
;;   cfpsf=conj(fpsf)

   ;main iteration loop
 ;;   FOR i=0,iter-1 DO BEGIN 

;;       ;step 1 blur psf with signal 
;;       hblur=fft(fft(s,-1)*fft(h,-1),1)
;;       hblur=shift(hblur,sx)

;;       ;threshold=1d-20
;;       ;ind=where(abs(hblur) LT threshold,count)
;;       ;IF count GT 0 THEN hblur[ind]=complex(threshold,0)

;;       hmulti=fft((fft(image/hblur,-1))*conj(fft(s,-1)),1)
;;       hnew=h/total(image)*shift(hmulti,sx)
;;       h=hnew

;;   ENDFOR 

;need more normalization?

   h=h0
   s=s0

   FOR k=0,np DO BEGIN 
      
      ;s=constant
      s=s*0+1
      s=s/total(s)

;      h=psf/total(psf)
;      s=s0/total(s0);

      ;improve s
      FOR i=0,nn-1 DO BEGIN 

         ;blur object model with PSF
         sblur=fft(fft(s,-1)*fft(h,-1),1)
         ;shift frequencies such that 0 = middle
         sblur=shift(sblur,sx)
         ;correlate image/blurred image with PSF
         smulti=fft((fft(s0/sblur,-1))*conj(fft(h,-1)),1)
         ;multiply improved object model
         ;shifts frequencies such that 0 = middle
         s=s*shift(smulti,sx)
         
      ENDFOR 

      ;h=constant
      h=h*0+1
      h=h/total(h)

      ;improve h
      FOR i=0,nn-1 DO BEGIN 

      ;step 1 blur psf with signal 
         hblur=fft(fft(s,-1)*fft(h,-1),1)
         hblur=shift(hblur,sx)
         hmulti=fft((fft(s0/hblur,-1))*conj(fft(s,-1)),1)
         h=h*shift(hmulti,sx)

      ENDFOR 

  
      h=real_part(h)
      s=real_part(s)
  
      print,'S: '+strtrim(total(s),2)
      print,'H: '+strtrim(total(h),2)

   ENDFOR 

   error=0

ENDELSE 


hok=h

RETURN,s

END 
