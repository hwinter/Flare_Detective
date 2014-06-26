;+
; NAME:
; 
; aia_gpurl_wrapper
;
; PURPOSE:
;
; wrapper around Mark Cheung's GPU deconvolution software
; tehre are two ways input/ouput is managed - either through FITS files or IDL
; variables - this is decided automatically by the program depending on whether
; the inputs are strings or arrays of data. 
;
; CATEGORY:
;
; AIA PSF utilities
;
; CALLING SEQUENCE:
;
; aia_gpurl_wrapper,ImageIn,PsfIn,ImageOut,nIter=nIter,ImageOut=ImageOut
;
; INPUTS:
;
; ImageIn: Image data or FITS file with the image to be deconvolved
;          (depending on the type of input - string for FITS, float for image data)
; PsfIn:   Image data or FITS file with the PSF
;          (depending on the type of input - string for FITS, float for image data)
;
; OPTIONAL INPUTS:
;
; nIter: Number of Iteration (default 50)
; GpuCodeDir: Directory containg the GPU executable (overridden by next).
;             Default is /home/pgrigis/machd/GPUStuff/C/bin/darwin/release/
; GpuCodeFile: Filename of the GPU executable (overrides previous) 
;              Default is /home/pgrigis/machd/GPUStuff/C/bin/darwin/release/deconv
; TempDirectory: Temporary directory to save FITS files (only used if the input
;                image and/or PSF is in data format)
;
; KEYWORD PARAMETERS:
;
; verbose: if set, more informative output is given to the IDL session
;
; OUTPUTS:
;
;
;
; OPTIONAL OUTPUTS:
;
; ImageOut: Deconvolved Image
;
; COMMON BLOCKS:
;
;
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
;
;
; EXAMPLE:
;
;
; AUTHOR:
;
; Paolo Grigis, pgrigis@cfa.harvard.edu
;
; MODIFICATION HISTORY:
; 
; 18-JAN-2010 PG written
;
;-

PRO aia_gpurl_wrapper_test

dir='/home/pgrigis/machd/GPUStuff/C/src/richardson_lucy/'
ImIn=dir+'AIA20100905_173349_0171.fits'
PsfIn=dir+'psf_mock.fits'
ImageFitsOut='/tmp/im1.fits'

aia_gpurl_wrapper,ImageFitsIn,PsfFitsIn,ImageFitsOut,/verbose

imin=fltarr(4096,4096)
imin[*,*]=1
psfin=fltarr(4096,4096)
psfin[0:10,0:10]=1
imout=1
dummy=temporary(imout)
aia_gpurl_wrapper,ImIn,PsfIn,ImOut,/verbose


END


PRO aia_gpurl_wrapper,ImageIn, $
                      PsfIn, $
                      ImageOut, $
                      nIter=nIter, $
                      GpuCodeDir=GpuCodeDir, $
                      GpuCodeFile=GpuCodeFile, $
                      TempDirectory=TempDirectory, $
                      verbose=verbose


;temporary directory to save files to
TempDirectory=fcheck(TempDirectory,get_temp_dir()+path_sep())


IF size(ImageIn,/tname) EQ 'STRING' THEN BEGIN 
   IF file_exist(ImageIn) EQ 0 THEN BEGIN 
      print,'This program needs a FITS image file as input.'
      IF exist(ImageFitsIn) THEN print,'File '+string(ImageFitsIn)+' not found. Returning.'
      RETURN 
   ENDIF

   ImageFitsFile=ImageIn

ENDIF $
ELSE BEGIN 
   ImageFitsFile=TempDirectory+'aia_gpurl_wrapper_ImageIn.fits'
   writefits,ImageFitsFile,ImageIn
ENDELSE 

IF size(PsfIn,/tname) EQ 'STRING' THEN BEGIN 
   IF file_exist(PsfIn) EQ 0 THEN BEGIN 
      print,'This program needs a FITS PSF file as input.'
      print,'File '+string(PsfIn)+' not found. Returning.'
      RETURN 
   ENDIF 
   PsfFitsFile=PsfIn
ENDIF $
ELSE BEGIN 
   PsfFitsFile=TempDirectory+'aia_gpurl_wrapper_PsfIn.fits'
   writefits,PsfFitsFile,PsfIn
ENDELSE 


IF size(ImageOut,/tname) NE 'STRING' THEN BEGIN 
   extractImage=1
   ImageFitsOut=TempDirectory+'aia_gpurl_wrapper_ImageOut.fits'
ENDIF $
ELSE BEGIN 
   extractImage=0
   ImageFitsOut=ImageOut
ENDELSE 

nIter=fcheck(nIter,50)
nIterString=strtrim(nIter,2)

verbose=fcheck(verbose,0)

GpuCodeDir =fcheck(GpuCodeDir ,'/home/pgrigis/machd/GPUStuff/C/bin/darwin/release/')
GpuCodeFile=fcheck(GpuCodeFile,string(GpuCodeDir)+path_sep()+'deconv')

IF file_exist(GpuCodeFile) EQ 0 THEN BEGIN 
   print,'This program needs a GPU executable file.'
   print,'File '+GpuCodeFile+' not found. Returning.'
   RETURN 

ENDIF 

;IF file_exist(ImageFitsOut) THEN file_delete,ImageFitsOut

CommandString=GpuCodeFile+ $
              ' --psf='+PsfFitsFile+ $
              ' --img='+ImageFitsFile+ $
              ' --out=\!'+ImageFitsOut+ $
              ' --iters='+nIterString

IF verbose NE 0 THEN BEGIN 
   print,'Now running: '+CommandString
ENDIF 

spawn,CommandString,exit_status=exit_status


IF extractImage EQ 1 THEN BEGIN 
   IF file_exist(ImageFitsOut) EQ 0 THEN BEGIN 
      print,'Could not find file '+ImageFitsOut
      pritn,'Returning.'
      RETURN 
   ENDIF 
   ImageOut=mrdfits(ImageFitsOut)
ENDIF 

;IF verbose NE 0 THEN BEGIN 
;   stop
;   print,'ExitStatus: '+string(exitStatus)
;ENDIF 

;stop

;data=mrdfits(ImageFitsOut)

END


