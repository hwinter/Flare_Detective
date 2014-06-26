;+
; NAME:
;
; aia_readfits
;
; PURPOSE:
;
; reads an AIA FITS file into a structure and data
;
; CATEGORY:
;
; SDO/AIA - I/O
;
; CALLING SEQUENCE:
;
; aia_readfits,filename,index,data
;
; INPUTS:
;
; filename: AIA FITS file
;
; OPTIONAL INPUTS:
;
;
;
; KEYWORD PARAMETERS:
;
;
;
; OUTPUTS:
;
; index: a strcuture with the FITS header
; data: the actual data
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
;
;
; RESTRICTIONS:
;
;
;
; PROCEDURE:
;
;  Due to some strange artifacts in the test level data sets to 0 all pixels
;  greater or equal 2^15=32768
;
; EXAMPLE:
;
; 
;
; MODIFICATION HISTORY:
;
; 02-OCT-2009 Paolo Grigis written
;
;
;-

PRO aia_readfits,filename,index,data

ind=where(file_exist(filename) EQ 1,count)

IF count EQ 0 THEN BEGIN 
   print,'No valid filenames specified! Returning...'
   RETURN
ENDIF

mreadfits,filename,index,data

ind=where(data GE 2L^15,count)
IF count GT 0 THEN data[ind]=0

END 

