;+
; NAME:
;
; pg_richardsonlucy_deconv
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
; deconvolved_image=pg_richardsonlucy_deconv(image,psf,niter=niter)
;
; INPUTS:
;
; image: a one- or two-dimensional array, the image or spectrum to be
;        deconvolved. Must be a numeric floating point type (with simple
;        or double precision).
; psf: an array with the same number of dimensions as "image" representing the
;      PSF of the system that prodcued the image. It can have a different number
;      of elements than image. Must be a numeric floating point type (with simple
;      or double precision).
; 
;
; OPTIONAL INPUTS:
;
; niter: the number of iterations to be performed (default: 25)
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
;       0: successful completion
;       1: image or psf have unallowed size (0 or more than 2 dimensions)
;       2: image or psf have unallowed type (floating point or double required)
;
; ihat: final blurred object model 
; ohat: final object model
;
;
; COMMON BLOCKS:
;
; NONE
;
; SIDE EFFECTS:
;
;
;
; RESTRICTIONS:
;
;
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
; 11-MAR-2009 written PG
; 16-APR-2009 allowed complex ohat input/output PG
; 28-SEP-2009 note that padding seems to be broken - always use /nopad until fixed
;
;-

FUNCTION pg_richardsonlucy_deconv,image,psf,niter=niter,error=error,verbose=verbose,ihat=ihat,ohat=ohat $
                                 ,plotprogress=plotprogress,nopad=nopad,inputohat=inputohat

progver='0.2'


;no error status is 0
error=0

niter=fcheck(niter,25)

;get image size and dimension
imsize=size(image)
psfsize=size(psf)

;check for scalars or 3D arrays that may sneak in (we don't want those)
IF imsize[0] EQ 0 OR imsize[0] GT 2 OR psfsize[0] EQ 0 OR psfsize[0] GT 2 OR imsize[0] NE psfsize[0] THEN BEGIN 
   print,'Invalid image or PSF size. This function work only with 1- or 2-dimensional'
   print,'arrays, and both arguments must have the same dimension'
   error=1
   RETURN,-1
ENDIF


;check for numeric floating point types. The test below is tru if either image
;or psf is not of type 4 or 5 (floating or double)
IF ~(imsize[n_elements(imsize)-2]   EQ 4 || imsize[n_elements(imsize)-2]   EQ 5) || $
   ~(psfsize[n_elements(psfsize)-2] EQ 4 || psfsize[n_elements(psfsize)-2] EQ 5) THEN BEGIN    

   print,'Invalid image or PSF type. This function works only with floating point' 
   print,'or double numeric arrays'
   error=2
   RETURN,-1

ENDIF

twodim=imsize[0] EQ 2

;prints some general info on the screen
IF keyword_set(verbose) THEN BEGIN 
   
   IF twodim THEN  BEGIN
      print,' '
      print,'Richardson-Lucy deconvolution (ver:'+progver+') of a '+strtrim(imsize[1],2)+'x'+strtrim(imsize[2],2)+' image' + $
            ' and a '+strtrim(psfsize[1],2)+'x'+strtrim(psfsize[2],2)+ ' PSF.'
      print,' '
   ENDIF $
   ELSE BEGIN 
      print,' '
      print,'Richardson-Lucy deconvolution (ver:'+progver+') of a '+strtrim(n_elements(image),2)+ $
            '-element spectrum with a '+strtrim(n_elements(psf),2),'-element PSF'
      print,' '
   ENDELSE

ENDIF


;perform main RL iteration
IF twodim THEN BEGIN 
   ;RL for 2-dim images

   ;psf normalization
   psfnorm=pg_fft_2dim_convolution(psf,psf*0+1,nopad=nopad)

   ;starting values for RL iteration
   IF (NOT keyword_set(inputohat)) OR n_elements(ohat) EQ 0 THEN BEGIN 
      print,'NO Input OHAT!'
      ohat=image
   ENDIF


   FOR i=0,niter-1 DO BEGIN 

      IF keyword_set(verbose) THEN $
         print,'Performing 2D iteration '+strtrim(i+1,2)+' of '+strtrim(niter,2)
      
      ;these are the 2 simple steps of RL algorithm
      ihat=pg_fft_2dim_convolution(psf,ohat,nopad=nopad)
      ohat*=pg_fft_2dim_convolution(image/ihat,psf,/corr,nopad=nopad)/psfnorm

      IF keyword_set(plotprogress) THEN BEGIN 
         tvscl,ohat
         wait,0.05
         
         im=tvrd(/true)
         write_png,'~/machd/aiapsfdata/movies/frame_noisy_'+smallint2str(i+1,strlen=3)+'.png',im

      ENDIF


   ENDFOR


ENDIF $
ELSE BEGIN 

   ;RL for 1-dim images

   ;psf normalization
   psfnorm=pg_fft_convolution(psf,psf*0+1,nopad=nopad)

   ;starting values for RL iteration
   IF (~ keyword_set(inputohat)) OR n_elements(ohat) EQ 0 THEN ohat=image


   FOR i=0,niter-1 DO BEGIN 

      IF keyword_set(verbose) THEN $
         print,'Performing 2D iteration '+strtrim(i+1,2)+' of '+strtrim(niter,2)
      
      ;these are the 2 simple steps of RL algorithm
      ihat=pg_fft_convolution(psf,ohat,nopad=nopad)
      ohat*=pg_fft_convolution(image/ihat,psf,/corr,nopad=nopad)/psfnorm


      IF keyword_set(plotprogress) THEN BEGIN 
         ymax=max([abs(ohat),abs(image)])
         plot,image,yrange=ymax*[-0.1,1.1]
         oplot,ohat,color=2,thick=2
         wait,0.05
      ENDIF

   ENDFOR


ENDELSE

;ohat=abs(ohat)
;ihat=abs(ihat)

RETURN,abs(ohat)

END




