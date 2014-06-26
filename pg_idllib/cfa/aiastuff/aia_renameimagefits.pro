;+
; NAME:
;
; aia_renameimagefits
;
; PURPOSE:
;
; This program reads in the header of all AIA FTS files in the input directroy
; and renames the images following the "standard" format:
; AIAYYYYMMDD_HHMMSS_WWWW.fits where WWWW identifies the wavelength
; 
;
; CATEGORY:
;
; AIA FITS utilities
;
; CALLING SEQUENCE:
;
; aia_renameimagefits,directory=directory,pattern=pattern,quiet=quiet,DeleteFiles=DeleteFiles
;
; INPUTS:
;
; directory: the directory containing the FITS files to be renamed (if not
;            given, the current dir is used instead)
; pattern: select the pattern of files to be looked for, such as "*.fits" or "aia.lev0.*.fits" 
;
; OPTIONAL INPUTS:
;
;
;
; KEYWORD PARAMETERS:
;
; DeleeFiles: if set, deletes the original files after they have been copied
;
; OUTPUTS:
;
; None
;
; OPTIONAL OUTPUTS:
;
;
;
; COMMON BLOCKS:
;
;
;
; SIDE EFFECTS:
;
; Files may be copied/removed on the disk.
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
; aia_renameimagefits,directory='/home/pgrigis/machd2/aia_data_forflaredet/level0/',pattern='aia.lev0.*.fits',/DeleteFiles
;  
; AUTHOR:
;
; Paolo Grigis
; pgrigis@cfa.harvard.edu
;
; MODIFICATION HISTORY:
;
; 03-MAY-2010 written PG
; 
;-

PRO aia_renameimagefits,directory=directory,pattern=pattern,quiet=quiet,DeleteFiles=DeleteFiles

;source and destination direcotry
directory=fcheck(directory,'.')
PathSep=path_sep()
directory=directory+path_sep()

;pattern: which files to look for?

;pattern=fcheck(pattern,'aia.lev0.*.fits');only JSOC level0 files
pattern=fcheck(pattern,'*.fits')

;finds files matcing pattern
FitsFileList=file_search(directory,pattern)

IF FitsFileList[0] EQ '' THEN BEGIN 
   print,'No FITS files found in dir: '+directory
   print,'Returning.'
   RETURN
ENDIF 


;copying files
FOR i=0,n_elements(FitsFileList)-1 DO BEGIN 

   ;reads header to find image time and channel
   ;mreadfits,FitsFileList[i],h
 
   read_sdo,FitsFileList[i],h
 
   ;stop

   ImageTime=h.date_obs
   ImageChannel=h.wavelnth

   ;construct filenames
   NewFileName=directory+'AIA'+time2file(ImageTime,/seconds)+'_'+string(ImageChannel,format='(I04)')+'.fits' 

   IF keyword_set(quiet) EQ 0 THEN print,'Copying '+FitsFileList[i]+'  to  ',NewFileName

   ;actual copying = only if dest file does not exist already
   IF file_exist(NewFileName) EQ 0 THEN BEGIN 
      file_copy,FitsFileList[i],NewFileName
   ENDIF 
   
   ;deletion of old files, if specified

   IF keyword_set(DeleteFiles) && file_exist(FitsFileList[i]) THEN BEGIN 
      file_delete,FitsFileList[i]
   ENDIF 

ENDFOR



END




