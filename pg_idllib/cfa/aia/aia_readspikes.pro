;+
; NAME:
;
; aia_readspikes
;
; PURPOSE:
;
; reads the spikes FITS file associated with an AIA image FITS files.
; this assumes the given FITS file is a symbolic link to a SUM directory.
; will not work on stand-alone files
;
; CATEGORY:
;
; AIA utilities
;
; CALLING SEQUENCE:
;
; aiaSpikes=aia_readspikes(aiaImageFileName)
;
; INPUTS:
;
; aiaImageFileName: a FITS filename in the AIA archive 
;
; OPTIONAL INPUTS:
;
; NONE
;
; KEYWORD PARAMETERS:
;
; NONE
;
; OUTPUTS:
;
; aiaSpikes: a Nx3 array with the spike information (if successful)
;            -1 (if not successful)
;
; OPTIONAL OUTPUTS:
;
; NONE
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
; Only works if the FITS filename given is a symbolic link to a SUM directory.
;
; PROCEDURE:
;
; Reads the spikes.fits file in the directory pointed to by the symbolic link
; of the image file
;
; EXAMPLE:
;
; aiaImageFileName='/data/SDO/AIA/level1/2011/02/15/H2000/AIA20110215_200432_0193.fits'
; spikes=aia_readspikes(aiaImageFileName)
;
; AUTHOR:
;
; Paolo Grigis pgrigis@cfa.harvard.edu
;
;
; MODIFICATION HISTORY:
;
;
; 09-MAR-2011 written PG
;-

FUNCTION aia_readspikes,aiaImageFileName

;checks that the file is indeed a symbolik link
isLink=file_test(aiaImageFileName,/symlink)

;if not, abort
IF isLink EQ 0 THEN BEGIN 
   print,'Error: filename given is not a symbolic link. Returning.'
   return,-1
ENDIF 


;reads the linked path
LinkPath=file_readlink(aiaImageFileName)

;extracts the directory where the linked file resides
Directory=file_dirname(LinkPath)+path_Sep()

;spikes files
SpikesFile=Directory+'spikes.fits'

;if files doess not exist, abort
IF file_Exist(SpikesFile) EQ 0 THEN BEGIN 
   print,'Error: file '+SpikesFile+' not found. Returning.'
   return,-1
ENDIF 

read_sdo,aiaImageFileName,index
read_sdo,SpikesFile,index,data,/use_index,/uncomp_delete

return, data

END 

